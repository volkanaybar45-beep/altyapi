extends Node2D
## Fener Bekçisi — prototip. Aynaya dokun, 90° döner (iki çapraz arasında);
## ışın her karede yeniden hesaplanır. Süre yok, hamle sınırı yok, kaybetme yok.

const Mirror := preload("res://mirror.gd")
const Levels := preload("res://levels.gd")
const LevelsGen := preload("res://levels_uretilen.gd")  # tools/uretec.py yazar

const SIZE := Vector2(720, 1280)
const CELL := 90.0
const ORIGIN := Vector2(90, 150)  # ızgara (0,0) hücresinin merkezi
const MAX_BOUNCES := 40
const BOAT_RADIUS := 42.0
const FENER_RADIUS := 24.0
const ROCK_RADIUS := 36.0
const EPS := 0.5
const DIRS := {"D": Vector2.DOWN, "U": Vector2.UP, "L": Vector2.LEFT, "R": Vector2.RIGHT}
const SKIP_RECT := Rect2(540, 12, 160, 64)

## Elle kurulan 9 bölüm, ardından üreteçten 10 bölüm (kurucu karşılaştırması).
static var all_levels: Array = Levels.ALL + LevelsGen.ALL

var level := 0
var fener_pos: Vector2
var fener_dir: Vector2
var boat_pos: Vector2
var mirrors: Array = []
var rocks: Array = []  # Vector2
var mode_button: Button

var path := PackedVector2Array()
var hit := false
var completed := false
var can_continue := false
var glow := 0.0  # kutlamada güzergâh boyunca yayılan parlama (0..1)
var boat_scale := 1.0
var time := 0.0

var title_label: Label
var info_label: Label


func _ready() -> void:
	title_label = _make_label(34, Color(0.85, 0.9, 1.0, 0.5), 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.position.x = 24
	info_label = _make_label(36, Color(1.0, 0.93, 0.7), 1200)
	mode_button = Button.new()
	mode_button.position = MODE_RECT.position
	mode_button.size = MODE_RECT.size
	mode_button.add_theme_font_size_override("font_size", 30)
	mode_button.focus_mode = Control.FOCUS_NONE
	mode_button.pressed.connect(toggle_mode)
	add_child(mode_button)
	load_level(0)


## 45° ↔ 90°. Bölüm baştan kurulur (aynalar başlangıç açısına döner).
func toggle_mode() -> void:
	mode90 = not mode90
	load_level(level)


func _make_label(font_size: int, color: Color, y: float) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, y)
	l.size = Vector2(SIZE.x, 60)
	add_child(l)
	return l


func load_level(i: int) -> void:
	level = i
	for m in mirrors:
		m.queue_free()
	mirrors.clear()
	rocks.clear()
	var d: Dictionary = Levels.ALL[i]
	fener_dir = DIRS[d["yon"]]
	var rows: Array = d["map"]
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var c := row[x]
			var p := ORIGIN + Vector2(x, y) * CELL
			match c:
				".":
					pass
				"F":
					fener_pos = p
				"T":
					boat_pos = p
				"R":
					rocks.append(p)
				"M", "N", "b", "s":
					var m := Mirror.new()
					m.position = p
					m.fixed = c == "b" or c == "s"
					m.inc = 2 if mode90 else 1
					m.set_step(1 if c == "M" or c == "b" else 3)
					add_child(m)
					mirrors.append(m)
				_:
					push_error("bilinmeyen harita karakteri '%s' bolum %d" % [c, i + 1])
	mode_button.text = tr("ACI_90") if mode90 else tr("ACI_45")
	completed = false
	can_continue = false
	glow = 0.0
	boat_scale = 1.0
	title_label.text = tr("BOLUM") % (i + 1)
	info_label.text = ""
	update_ray()


func _process(delta: float) -> void:
	time += delta
	update_ray()
	if hit and not completed:
		_celebrate()
	queue_redraw()


# --- ışın --------------------------------------------------------------------

func update_ray() -> void:
	var r := compute_path()
	path = r["points"]
	hit = r["hit"]


func compute_path() -> Dictionary:
	var pts := PackedVector2Array([fener_pos])
	var pos := fener_pos
	var dir := fener_dir
	for _i in MAX_BOUNCES:
		var best_t := _ray_bounds_t(pos, dir)
		var best_m = null
		var to_boat := false
		for m in mirrors:
			var seg: Array = m.segment()
			var t := _ray_segment_t(pos, dir, seg[0], seg[1])
			if t > EPS and t < best_t:
				best_t = t
				best_m = m
		var tb := _ray_circle_t(pos, dir, boat_pos, BOAT_RADIUS)
		if tb > EPS and tb < best_t:
			best_t = tb
			best_m = null
			to_boat = true
		var tf := _ray_circle_t(pos, dir, fener_pos, FENER_RADIUS)
		if tf > EPS and tf < best_t:  # geri dönen ışın fenerde durur
			best_t = tf
			best_m = null
			to_boat = false
		for r in rocks:
			var tr_ := _ray_circle_t(pos, dir, r, ROCK_RADIUS)
			if tr_ > EPS and tr_ < best_t:
				best_t = tr_
				best_m = null
				to_boat = false
		pos = pos + dir * best_t
		pts.append(pos)
		if to_boat:
			return {"points": pts, "hit": true}
		if best_m == null:
			break  # ekran kenarı ya da fener
		dir = best_m.reflect(dir)
	return {"points": pts, "hit": false}


## Kesişme yoksa -1.
func _ray_segment_t(ro: Vector2, rd: Vector2, p1: Vector2, p2: Vector2) -> float:
	var v1 := ro - p1
	var v2 := p2 - p1
	var v3 := Vector2(-rd.y, rd.x)
	var den := v2.dot(v3)
	if absf(den) < 1e-6:
		return -1.0
	var t := v2.cross(v1) / den
	var s := v1.dot(v3) / den
	if t >= 0.0 and s >= 0.0 and s <= 1.0:
		return t
	return -1.0


func _ray_circle_t(ro: Vector2, rd: Vector2, c: Vector2, r: float) -> float:
	var m := ro - c
	var b := m.dot(rd)
	var cc := m.dot(m) - r * r
	var disc := b * b - cc
	if disc < 0.0:
		return -1.0
	return -b - sqrt(disc)


func _ray_bounds_t(ro: Vector2, rd: Vector2) -> float:
	var t := INF
	if rd.x > 1e-6:
		t = minf(t, (SIZE.x - ro.x) / rd.x)
	elif rd.x < -1e-6:
		t = minf(t, -ro.x / rd.x)
	if rd.y > 1e-6:
		t = minf(t, (SIZE.y - ro.y) / rd.y)
	elif rd.y < -1e-6:
		t = minf(t, -ro.y / rd.y)
	return t


# --- kutlama -----------------------------------------------------------------

func _celebrate() -> void:
	completed = true
	var tw := create_tween()
	tw.tween_property(self, "glow", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "boat_scale", 1.4, 0.15)
	tw.tween_property(self, "boat_scale", 1.0, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_callback(func():
		can_continue = true
		var last := level == Levels.ALL.size() - 1
		title_label.text = tr("TAMAM")
		info_label.text = tr("SON") if last else tr("DEVAM"))


# --- girdi -------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tap(event.position)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_M:
		toggle_mode()


func tap(pos: Vector2) -> void:
	if MODE_RECT.has_point(pos):
		return  # düğmenin kendisi halleder
	if completed:
		if can_continue:
			load_level((level + 1) % Levels.ALL.size())
		return
	var best = null
	var best_d := Mirror.TAP_RADIUS
	for m in mirrors:
		var d: float = m.position.distance_to(pos)
		if d < best_d:
			best_d = d
			best = m
	if best != null:
		best.turn()


# --- çizim -------------------------------------------------------------------

func _draw() -> void:
	# ışın
	var core := Color(1.0, 0.92, 0.6)
	var beam_w := 6.0 + 2.0 * sin(time * 3.0) * 0.5
	for i in path.size() - 1:
		draw_line(path[i], path[i + 1], Color(1.0, 0.85, 0.4, 0.15), 26.0)
		draw_line(path[i], path[i + 1], core, beam_w)
	if glow > 0.0:
		_draw_glow()

	# kayalık: üç taş
	for r in rocks:
		draw_circle(r + Vector2(-12, 8), 26.0, Color(0.24, 0.22, 0.22))
		draw_circle(r + Vector2(14, 10), 22.0, Color(0.2, 0.19, 0.19))
		draw_circle(r + Vector2(0, -10), 24.0, Color(0.3, 0.28, 0.27))

	# fener: kule (ışının tersine) + lamba
	draw_line(fener_pos, fener_pos - fener_dir * 70.0, Color(0.35, 0.38, 0.45), 36.0)
	draw_circle(fener_pos, 40.0, Color(1.0, 0.85, 0.4, 0.2))
	draw_circle(fener_pos, FENER_RADIUS, Color(1.0, 0.92, 0.6))

	# tekne
	var bob := Vector2(0, sin(time * 1.5) * 4.0)
	var s := boat_scale
	var c := boat_pos + bob
	var hull := Color(0.75, 0.45, 0.3) if not completed else Color(1.0, 0.7, 0.4)
	draw_rect(Rect2(c + Vector2(-50, 0) * s, Vector2(100, 26) * s), hull)
	draw_line(c, c + Vector2(0, -60) * s, Color(0.85, 0.85, 0.85), 4.0)
	draw_rect(Rect2(c + Vector2(4, -56) * s, Vector2(32, 36) * s), Color(0.9, 0.9, 0.85))
	if completed:
		draw_circle(c, BOAT_RADIUS * 1.6 * glow, Color(1.0, 0.9, 0.5, 0.15 * glow))


## Kutlamada parlama fenerden tekneye doğru yayılır.
func _draw_glow() -> void:
	var total := 0.0
	for i in path.size() - 1:
		total += path[i].distance_to(path[i + 1])
	var left := total * glow
	for i in path.size() - 1:
		var seg_len := path[i].distance_to(path[i + 1])
		if left <= 0.0:
			break
		var b := path[i + 1] if left >= seg_len else path[i].lerp(path[i + 1], left / seg_len)
		draw_line(path[i], b, Color(1.0, 0.95, 0.75, 0.35), 44.0)
		draw_line(path[i], b, Color(1, 1, 1), 10.0)
		left -= seg_len
