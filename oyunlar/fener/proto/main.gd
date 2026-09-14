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
const RIM_COLOR := Color("#8FA9C9")  # tekne kenarı: ay ışığı; deniz zeminine kontrast ~6
const RIM_W := 3.0
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
var rim_layer: Node2D
var lantern := 0.0  # tamamlanınca tekne feneri parlaması (0..1)


func _ready() -> void:
	add_child(Arka.new())
	for add in [true, false]:  # parlama (toplamalı) altta, çekirdek üstte
		var layer := IsinKatmani.new()
		layer.owner_main = self
		layer.additive = add
		add_child(layer)
		beam_layers.append(layer)
	_make_rim_layer()
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


## Tekne kenar çizgisi: tekne görseli gece denizinde kontrast 1.95 (hedef ≥3.0).
## Görseli değiştirmeden siluetin etrafına ay ışığı renginde ince kenar çizilir
## (alfa maskesi düz renge boyanıp 8 yöne kaydırılarak). Işının üstünde, teknenin altında.
func _make_rim_layer() -> void:
	var sh := Shader.new()
	sh.code = "shader_type canvas_item;\nuniform vec4 rim : source_color;\n" \
		+ "void fragment() { COLOR = vec4(rim.rgb, texture(TEXTURE, UV).a * rim.a); }"
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("rim", RIM_COLOR)
	rim_layer = Node2D.new()
	rim_layer.material = mat
	rim_layer.z_index = -1
	rim_layer.draw.connect(_draw_rims)
	add_child(rim_layer)


func _draw_rims() -> void:
	var bob := Vector2(0, sin(time * 1.5) * 3.0)
	var bsc := _boat_scale_px() * boat_scale
	var sz := Vector2(BOAT.get_width(), BOAT.get_height()) * bsc
	var w := RIM_W * k
	for b in boats:
		var c: Vector2 = b + bob
		for i in 8:
			var off := Vector2.RIGHT.rotated(i * PI / 4.0) * w
			rim_layer.draw_texture_rect(BOAT, Rect2(c - sz / 2.0 + off, sz), false)


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
	lantern = 0.0
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
	for l in beam_layers:
		l.queue_redraw()
	rim_layer.queue_redraw()


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


## Ekran kenarı. Üstte başlık/Atla şeridinin altında biter (yazının üstünden
## geçmesin); altta görünen alanın sonuna kadar (20:9'da 1280'den uzun).
## Izgaranın dışında nesne olmadığından fiziği değiştirmez.
func _ray_bounds_t(ro: Vector2, rd: Vector2) -> float:
	var bottom := maxf(SIZE.y, get_viewport_rect().size.y)
	var t := INF
	if rd.x > 1e-6:
		t = minf(t, (SIZE.x - ro.x) / rd.x)
	elif rd.x < -1e-6:
		t = minf(t, -ro.x / rd.x)
	if rd.y > 1e-6:
		t = minf(t, (bottom - ro.y) / rd.y)
	elif rd.y < -1e-6:
		t = minf(t, (BEAM_TOP - ro.y) / rd.y)
	return t


# --- kutlama -----------------------------------------------------------------

func _celebrate() -> void:
	completed = true
	for b in boats:
		_sparkle(b)
	create_tween().tween_property(self, "lantern", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
	var tw := create_tween()
	tw.tween_property(self, "glow", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "boat_scale", 1.4, 0.15)
	tw.tween_property(self, "boat_scale", 1.0, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_callback(func():
		can_continue = true
		var last := level == all_levels.size() - 1
		title_label.text = tr("TAMAM")
		info_label.text = tr("SON") if last else tr("DEVAM"))


## Sakin, kısa parçacık: tekne fenerinden yukarı süzülen birkaç sıcak kıvılcım.
func _sparkle(boat: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = _lantern_pos(boat)
	p.one_shot = true
	p.explosiveness = 0.6
	p.amount = 14
	p.lifetime = 1.4
	p.direction = Vector2.UP
	p.spread = 70.0
	p.gravity = Vector2(0, -12)
	p.initial_velocity_min = 18.0
	p.initial_velocity_max = 45.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 4.5
	var g := Gradient.new()
	g.set_color(0, Color(1.0, 0.93, 0.66, 0.9))
	g.set_color(1, Color(1.0, 0.8, 0.45, 0.0))
	p.color_ramp = g
	p.z_index = 3
	add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


func _lantern_pos(boat: Vector2) -> Vector2:
	return boat + (BOAT_LANTERN - Vector2(256, 256)) * _boat_scale_px()


func _boat_scale_px() -> float:
	return cell * 1.25 / 490.0  # tekne görünür genişliği 1.25 hücre (bbox 490)


# --- girdi -------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tap(event.position)
	elif event.is_action_pressed("ui_cancel"):
		_to_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # Android geri tuşu
		_to_menu()


func _to_menu() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


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
# Işın ayrı katmanlarda (isin_katmani.gd). Burada: kaya, bölücü, fener, tekne.

func _draw() -> void:
	# kayalık
	var rs := cell * 1.1 / 490.0  # görünür genişlik 1.1 hücre (bbox 490)
	for r in rocks:
		var sz := Vector2(ROCK.get_width(), ROCK.get_height()) * rs
		draw_texture_rect(ROCK, Rect2(r - sz / 2.0, sz), false)

	# bölücü: elmas prizma (ayna plakası, kaya ve sabit kıskaçla karışmasın)
	for sp in splitters:
		var r := SPLIT_RADIUS * k * 1.15
		var dia := PackedVector2Array([sp + Vector2(0, -r), sp + Vector2(r, 0),
			sp + Vector2(0, r), sp + Vector2(-r, 0)])
		draw_colored_polygon(dia, Color(0.55, 0.85, 0.95, 0.9))
		dia.append(dia[0])
		draw_polyline(dia, Color(0.9, 0.98, 1.0), 3.0)
		draw_line(sp + Vector2(-r, 0) * 0.5, sp + Vector2(r, 0) * 0.5, Color(0.2, 0.35, 0.45), 3.0)
		draw_line(sp + Vector2(0, -r) * 0.5, sp + Vector2(0, r) * 0.5, Color(0.2, 0.35, 0.45), 3.0)

	# fener: lamba odası ışının çıktığı hücre merkezinde, kule hep dik
	var ts := cell * 1.25 / 490.0  # kule görünür yüksekliği 1.25 hücre
	draw_texture_rect(TOWER, Rect2(fener_pos - TOWER_LAMP * ts, Vector2(TOWER.get_width(), TOWER.get_height()) * ts), false)
	draw_circle(fener_pos, 30.0 * k, Color(1.0, 0.9, 0.6, 0.25))

	# tekneler: ışık alan, bölüm bitmeden de parlar (iki kolda hangisi vardı görünsün)
	var bob := Vector2(0, sin(time * 1.5) * 3.0)
	var bsc := _boat_scale_px() * boat_scale
	for j in boats.size():
		var c: Vector2 = boats[j] + bob
		var on := lit.has(j)
		if on:
			draw_circle(c, BOAT_RADIUS * k * 1.3, Color(1.0, 0.9, 0.55, 0.14))
		var sz := Vector2(BOAT.get_width(), BOAT.get_height()) * bsc
		draw_texture_rect(BOAT, Rect2(c - sz / 2.0, sz), false)
		# tekne feneri: ışık alınca yanar, tamamlanınca iyice parlar
		var lp := c + (BOAT_LANTERN - Vector2(256, 256)) * bsc
		var a := (0.35 if on else 0.0) + 0.45 * lantern
		if a > 0.0:
			draw_circle(lp, 22.0 * k * (1.0 + lantern), Color(1.0, 0.85, 0.45, a * 0.35))
			draw_circle(lp, 7.0 * k, Color(1.0, 0.95, 0.75, a))
