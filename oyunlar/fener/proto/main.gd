extends Node2D
## Fener Bekçisi — prototip. Aynaya dokun, 90° döner (iki çapraz arasında);
## ışın her karede yeniden hesaplanır. Süre yok, hamle sınırı yok, kaybetme yok.
## Işık bölücü ışını ikiye ayırır; bölüm BÜTÜN tekneler ışık alınca biter.

const Mirror := preload("res://mirror.gd")
const Arka := preload("res://arka.gd")
const IsinKatmani := preload("res://isin_katmani.gd")
const TOWER := preload("res://gorseller/fener_kulesi.png")
const BOAT := preload("res://gorseller/tekne.png")
const ROCK := preload("res://gorseller/kayalik.png")
const TOWER_LAMP := Vector2(252, 109)   # fener_kulesi.png içinde lamba odası (512'lik tuval)
const BOAT_LANTERN := Vector2(298, 226)  # tekne.png içinde tekne feneri
const Levels := preload("res://levels.gd")
const LevelsGen := preload("res://levels_uretilen.gd")  # tools/uretec.py yazar (İŞ 3)
const LevelsGen4 := preload("res://levels_uretilen_4.gd")  # tools/uretec.py ... is4

const SIZE := Vector2(720, 1280)
const PLAY_TOP := 130.0     # ızgaranın ilk satır merkezi en az burada
const PLAY_SPAN := 1040.0   # ilk ve son satır merkezleri arası en fazla
const MAX_SEGMENTS := 80    # bütün kollar toplamı (sonsuz döngü koruması)
const BOAT_RADIUS := 42.0
const FENER_RADIUS := 24.0
const ROCK_RADIUS := 36.0
const SPLIT_RADIUS := 28.0
const EPS := 0.5
const DIRS := {"D": Vector2.DOWN, "U": Vector2.UP, "L": Vector2.LEFT, "R": Vector2.RIGHT}
const SKIP_RECT := Rect2(540, 8, 160, 56)  # alt kenar < 0. satırdaki fener kulesinin tepesi (68)

## Elle 9 · üretilen 10 (İŞ 3) · üretilen 8 (İŞ 4, 8x14, bölücülü) — kurucu karşılaştırması.
static var all_levels: Array = Levels.ALL + LevelsGen.ALL + LevelsGen4.ALL

var level := 0
var cell := 90.0
var k := 1.0  # çizim ölçeği = cell / 90
var fener_pos: Vector2
var fener_dir: Vector2
var boats: Array = []      # Vector2
var splitters: Array = []  # Vector2
var mirrors: Array = []
var rocks: Array = []      # Vector2
var skip_button: Button

var paths: Array = []  # PackedVector2Array, kol başına bir tane
var lit := {}          # ışık alan tekne indeksleri
var hit := false
var completed := false
var can_continue := false
var glow := 0.0  # kutlamada güzergâh boyunca yayılan parlama (0..1)
var boat_scale := 1.0
var time := 0.0

var title_label: Label
var info_label: Label
var beam_layers: Array = []
var lantern := 0.0  # tamamlanınca tekne feneri parlaması (0..1)


func _ready() -> void:
	add_child(Arka.new())
	for add in [true, false]:  # parlama (toplamalı) altta, çekirdek üstte
		var layer := IsinKatmani.new()
		layer.owner_main = self
		layer.additive = add
		add_child(layer)
		beam_layers.append(layer)
	title_label = _make_label(34, Color(0.85, 0.9, 1.0, 0.5), 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.position.x = 24
	info_label = _make_label(36, Color(1.0, 0.93, 0.7), 1200)
	skip_button = Button.new()
	skip_button.position = SKIP_RECT.position
	skip_button.size = SKIP_RECT.size
	skip_button.add_theme_font_size_override("font_size", 30)
	skip_button.focus_mode = Control.FOCUS_NONE
	skip_button.text = tr("ATLA")
	skip_button.pressed.connect(skip)
	add_child(skip_button)
	load_level(0)


## Prototip için: bölümü geç (kurucu üretilen bölümlere hızlı ulaşsın).
func skip() -> void:
	load_level((level + 1) % all_levels.size())


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
	boats.clear()
	splitters.clear()
	var d: Dictionary = all_levels[i]
	fener_dir = DIRS[d["yon"]]
	var rows: Array = d["map"]
	var w: int = (rows[0] as String).length()
	var h: int = rows.size()
	# hücre: genişliğe (kenarda yarım hücre pay) ve oyun alanı yüksekliğine sığan en büyük
	cell = minf(SIZE.x / (w + 1), PLAY_SPAN / (h - 1))
	k = cell / 90.0
	var origin := Vector2((SIZE.x - (w - 1) * cell) / 2.0, PLAY_TOP + (PLAY_SPAN - (h - 1) * cell) / 2.0)
	for y in h:
		var row: String = rows[y]
		for x in row.length():
			var c := row[x]
			var p := origin + Vector2(x, y) * cell
			match c:
				".":
					pass
				"F":
					fener_pos = p
				"T":
					boats.append(p)
				"R":
					rocks.append(p)
				"Y":
					splitters.append(p)
				"M", "N", "b", "s":
					var m := Mirror.new()
					m.position = p
					m.fixed = c == "b" or c == "s"
					m.base = k
					m.scale = Vector2(k, k)
					m.set_step(1 if c == "M" or c == "b" else 3)
					add_child(m)
					mirrors.append(m)
				_:
					push_error("bilinmeyen harita karakteri '%s' bolum %d" % [c, i + 1])
	completed = false
	can_continue = false
	glow = 0.0
	boat_scale = 1.0
	var n_hand := Levels.ALL.size()
	if i < n_hand:
		title_label.text = tr("BOLUM") % (i + 1)
	else:
		title_label.text = tr("URETILEN") % [i - n_hand + 1, d["zorluk"]]
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
	paths = r["paths"]
	lit = r["lit"]
	hit = r["hit"]


## Bütün kolları izler. Bölücü gelen kolu durdurur, merkezinden sağa ve sola
## iki yeni kol çıkarır. → {paths, lit (tekne indeksi → true), hit (hepsi mi)}
func compute_path() -> Dictionary:
	var out: Array = []
	var got := {}
	var emitted := {}  # (bölücü, yön) bir kez
	var stack: Array = [[fener_pos, fener_dir]]
	var budget := MAX_SEGMENTS
	while not stack.is_empty() and budget > 0:
		var beam: Array = stack.pop_back()
		var pos: Vector2 = beam[0]
		var dir: Vector2 = beam[1]
		var pts := PackedVector2Array([pos])
		while budget > 0:
			budget -= 1
			var best_t := _ray_bounds_t(pos, dir)
			var best_m = null
			var kind := ""  # "" kenar/engel · "boat" · "split"
			var idx := -1
			for m in mirrors:
				var seg: Array = m.segment()
				var t := _ray_segment_t(pos, dir, seg[0], seg[1])
				if t > EPS and t < best_t:
					best_t = t
					best_m = m
					kind = ""
			for j in boats.size():
				var tb := _ray_circle_t(pos, dir, boats[j], BOAT_RADIUS * k)
				if tb > EPS and tb < best_t:
					best_t = tb
					best_m = null
					kind = "boat"
					idx = j
			for j in splitters.size():
				var tsp := _ray_circle_t(pos, dir, splitters[j], SPLIT_RADIUS * k)
				if tsp > EPS and tsp < best_t:
					best_t = tsp
					best_m = null
					kind = "split"
					idx = j
			var tf := _ray_circle_t(pos, dir, fener_pos, FENER_RADIUS)
			if tf > EPS and tf < best_t:  # geri dönen ışın fenerde durur
				best_t = tf
				best_m = null
				kind = ""
			for r in rocks:
				var t_rock := _ray_circle_t(pos, dir, r, ROCK_RADIUS * k)
				if t_rock > EPS and t_rock < best_t:
					best_t = t_rock
					best_m = null
					kind = ""
			pos = pos + dir * best_t
			if kind == "split":
				var c: Vector2 = splitters[idx]
				pts.append(c)  # kol görsel olarak merkezde biter
				for nd in [Vector2(dir.y, dir.x), Vector2(-dir.y, -dir.x)]:
					var key := "%d:%d,%d" % [idx, roundi(nd.x), roundi(nd.y)]
					if not emitted.has(key):
						emitted[key] = true
						stack.append([c, nd])
				break
			pts.append(pos)
			if kind == "boat":
				got[idx] = true
				break
			if best_m == null:
				break  # ekran kenarı, kaya ya da fener
			dir = best_m.reflect(dir)
		out.append(pts)
	return {"paths": out, "lit": got, "hit": got.size() == boats.size()}


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
		var last := level == all_levels.size() - 1
		title_label.text = tr("TAMAM")
		info_label.text = tr("SON") if last else tr("DEVAM"))


# --- girdi -------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tap(event.position)


func tap(pos: Vector2) -> void:
	if SKIP_RECT.has_point(pos):
		return  # düğmenin kendisi halleder
	if completed:
		if can_continue:
			skip()
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
	for p in paths:
		for i in p.size() - 1:
			# hale ince: komşu şeritte paralel giden iki kol tek banda karışmasın
			draw_line(p[i], p[i + 1], Color(1.0, 0.85, 0.4, 0.15), 18.0 * k)
			draw_line(p[i], p[i + 1], core, beam_w)
	if glow > 0.0:
		for p in paths:
			_draw_glow(p)

	# kayalık: üç taş
	for r in rocks:
		draw_circle(r + Vector2(-12, 8) * k, 26.0 * k, Color(0.24, 0.22, 0.22))
		draw_circle(r + Vector2(14, 10) * k, 22.0 * k, Color(0.2, 0.19, 0.19))
		draw_circle(r + Vector2(0, -10) * k, 24.0 * k, Color(0.3, 0.28, 0.27))

	# bölücü: elmas prizma (ayna çizgisi, kaya dairesi ve sabit blokla karışmasın)
	for sp in splitters:
		var r := SPLIT_RADIUS * k * 1.15
		var dia := PackedVector2Array([sp + Vector2(0, -r), sp + Vector2(r, 0),
			sp + Vector2(0, r), sp + Vector2(-r, 0)])
		draw_colored_polygon(dia, Color(0.55, 0.85, 0.95, 0.9))
		dia.append(dia[0])
		draw_polyline(dia, Color(0.9, 0.98, 1.0), 3.0)
		draw_line(sp + Vector2(-r, 0) * 0.5, sp + Vector2(r, 0) * 0.5, Color(0.2, 0.35, 0.45), 3.0)
		draw_line(sp + Vector2(0, -r) * 0.5, sp + Vector2(0, r) * 0.5, Color(0.2, 0.35, 0.45), 3.0)

	# fener: kule (ışının tersine) + lamba
	draw_line(fener_pos, fener_pos - fener_dir * 70.0 * k, Color(0.35, 0.38, 0.45), 36.0 * k)
	draw_circle(fener_pos, 40.0 * k, Color(1.0, 0.85, 0.4, 0.2))
	draw_circle(fener_pos, FENER_RADIUS, Color(1.0, 0.92, 0.6))

	# tekneler: ışık alan, bölüm bitmeden de parlar (iki kolda hangisi vardı görünsün)
	var bob := Vector2(0, sin(time * 1.5) * 4.0)
	for j in boats.size():
		var s := boat_scale * k
		var c: Vector2 = boats[j] + bob
		var on := lit.has(j)
		var hull := Color(1.0, 0.7, 0.4) if on else Color(0.75, 0.45, 0.3)
		if on and not completed:
			draw_circle(c, BOAT_RADIUS * k * 1.3, Color(1.0, 0.9, 0.5, 0.12))
		draw_rect(Rect2(c + Vector2(-50, 0) * s, Vector2(100, 26) * s), hull)
		# direk kısa: üst hücredeki kaya (near-miss için sık) bayrağı örtmesin
		draw_line(c, c + Vector2(0, -40) * s, Color(0.85, 0.85, 0.85), 4.0)
		draw_rect(Rect2(c + Vector2(4, -38) * s, Vector2(28, 26) * s), Color(0.9, 0.9, 0.85))
		if completed:
			draw_circle(c, BOAT_RADIUS * k * 1.6 * glow, Color(1.0, 0.9, 0.5, 0.15 * glow))


## Kutlamada parlama her kolda başından sonuna doğru yayılır.
func _draw_glow(p: PackedVector2Array) -> void:
	var total := 0.0
	for i in p.size() - 1:
		total += p[i].distance_to(p[i + 1])
	var left := total * glow
	for i in p.size() - 1:
		var seg_len := p[i].distance_to(p[i + 1])
		if left <= 0.0:
			break
		var b := p[i + 1] if left >= seg_len else p[i].lerp(p[i + 1], left / seg_len)
		draw_line(p[i], b, Color(1.0, 0.95, 0.75, 0.35), 30.0 * k)
		draw_line(p[i], b, Color(1, 1, 1), 10.0)
		left -= seg_len
