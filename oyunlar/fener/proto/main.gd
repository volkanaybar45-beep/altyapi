extends Node2D
## Fener Bekçisi — prototip. Aynaya dokun, 45° döner; ışın her karede
## yeniden hesaplanır. Süre yok, hamle sınırı yok, kaybetme yok.

const Mirror := preload("res://mirror.gd")
const Levels := preload("res://levels.gd")

const SIZE := Vector2(720, 1280)
const MAX_BOUNCES := 24
const BOAT_RADIUS := 42.0
const FENER_RADIUS := 24.0
const EPS := 0.5

var level := 0
var fener_pos: Vector2
var fener_dir: Vector2
var boat_pos: Vector2
var mirrors: Array = []

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
	load_level(0)


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
	var d: Dictionary = Levels.ALL[i]
	fener_pos = d["fener"]
	fener_dir = (d["yon"] as Vector2).normalized()
	boat_pos = d["tekne"]
	for p in d["aynalar"]:
		var m := Mirror.new()
		m.position = p
		m.set_step(0)
		add_child(m)
		mirrors.append(m)
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
		info_label.text = tr("TAMAM") + "\n" + (tr("SON") if last else tr("DEVAM")))


# --- girdi -------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tap(event.position)


func tap(pos: Vector2) -> void:
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

	# fener: kule + lamba
	draw_rect(Rect2(fener_pos + Vector2(-22, -120), Vector2(44, 110)), Color(0.35, 0.38, 0.45))
	draw_circle(fener_pos, 40.0, Color(1.0, 0.85, 0.4, 0.2))
	draw_circle(fener_pos, 24.0, Color(1.0, 0.92, 0.6))

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
