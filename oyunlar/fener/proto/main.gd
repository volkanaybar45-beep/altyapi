extends Node2D
## Fener Bekçisi — prototip. Aynaya dokun, 90° döner (iki çapraz arasında);
## ışın her karede yeniden hesaplanır. Süre yok, hamle sınırı yok, kaybetme yok.
## Işık bölücü ışını ikiye ayırır; bölüm BÜTÜN tekneler ışık alınca biter.

const Mirror := preload("res://mirror.gd")
const Arka := preload("res://arka.gd")
const IsinKatmani := preload("res://isin_katmani.gd")
const SuKatmani := preload("res://su_katmani.gd")
const BOAT := preload("res://gorseller/tekne.png")
const ROCK := preload("res://gorseller/kaya_engel.png")
## İŞ 10 geometri (G1-G3). Sprite'lar diyorama kamerasıyla (yaw -40, pitch 30)
## render edildi; ölçüler 512'lik render pikseli (tools/is10_varlik.py).
## Her nesnenin ALT ORTASI hücrenin su noktasına oturur: hücre merkezi + WP
## hücre. Su noktasından yukarı toplam boy ≤ 0.985 hücre → dikey komşu binmez.
## tools/cakisma.py aynı sabitleri kullanır; biri değişirse öteki de.
const WP := 0.6               # su noktası: hücre merkezinin 0.6 hücre altı
const ROW_SCALE_TOP := 0.85   # G2: en üst satır, en alt satırın %85'i
const BOAT_W := 1.1           # tekne genişliği (hücre); görünür genişlik 483 px
const BOAT_CUT := 440.0       # tekne su hattı (altı çizilmez) → boy 0.97 hücre
const BOAT_AX := 255.5        # sprite alt orta x
const BOAT_LANTERN := Vector2(185, 73)  # tekne.png içinde direk feneri
const ROCK_W := 0.95          # engel kayası genişliği → boy 0.75 hücre
const ROCK_CUT := 420.0
const ROCK_AX := 255.5
const GAP := 0.4      # tekne ile komşusu arasına eklenen boşluk
## Ekran yerleşimi (E1): 9:16'da hücre ≥ 60, fener ≥ 80 px
const INFO_H := 80.0          # altta "bitti" yazısı şeridi
const UNITS_MAX := 12.8       # en uzun ızgara (hücre, üst 0.4 + alt 0.6 pay dahil)
const CELL_GOAL := 66.0       # diyorama ölçeği bu hücreyi hedefler
const DIO_S_MIN := 0.68       # fener 123 px × 0.68 = 83.6 px (≥ 80)
const DIO_S_MAX := 1.0
const Levels := preload("res://levels.gd")
const LevelsGen := preload("res://levels_uretilen_11.gd")  # tools/uretec.py ... is11 yazar

const SIZE := Vector2(720, 1280)
const MAX_SEGMENTS := 80    # bütün kollar toplamı (sonsuz döngü koruması)
const BOAT_RADIUS := 42.0
const ROCK_RADIUS := 36.0
const SPLIT_RADIUS := 28.0
const EPS := 0.5
const DIRS := {"D": Vector2.DOWN, "U": Vector2.UP, "L": Vector2.LEFT, "R": Vector2.RIGHT}
const SKIP_RECT := Rect2(540, 8, 160, 56)  # alt kenar < 0. satırdaki fener kulesinin tepesi (68)

## İŞ 11: elle 5 (öğretme) · üretilen 20 (10 orta + 10 zor, 7x12, kaynak üstte).
static var all_levels: Array = Levels.ALL + LevelsGen.ALL

var level := 0
var cell := 90.0
var k := 1.0  # çizim ölçeği = cell / 90
var fener_pos: Vector2
var fener_dir: Vector2
var boats: Array = []      # Vector2
var splitters: Array = []  # Vector2
var mirrors: Array = []
var rocks: Array = []      # Vector2
var row_scale := {}        # hücre merkezi y → G2 ölçeği
var objects: Node2D        # kaya/ayna/tekne/bölücü düğümleri, y'ye göre sıralı (ressam sırası)
var boat_nodes: Array = []
var skip_button: Button

var paths: Array = []  # PackedVector2Array, kol başına bir tane
var lit := {}          # ışık alan tekne indeksleri
var hit := false
var completed := false
var can_continue := false
## Otomatik devam (İŞ 8). Prob/test betikleri kapatır (çözülmüş ekran görüntüsü
## alırken bölüm kendiliğinden değişmesin).
var auto_advance := true
const AUTO_WAIT := 0.6       # kutlama bittikten sonra geçişe kadar
const AUTO_WAIT_LAST := 2.2  # son bölüm: "bitti" yazısı okunsun, sonra ana ekran
var transitioning := false
var fade_rect: ColorRect
var _loaded := false  # bölüm yüklenirken ilk ışın hesabında çan/korna çalmasın
## Tekne karşılığı (İŞ 9), tekne indeksine göre:
const BOAT_GLIDE := 0.15    # ışık alınca ışığa doğru süzülme (hücre)
const HORN_DELAY := 0.35    # çandan sonra korna
const HORN_COOLDOWN := 3.0  # aynı tekne ışığı kaybedip bulunca korna tekrarı en erken
var boat_resp: Array = []   # 0..1 ışık alınca yavaşça 1'e (süzülme, sıcak renk, fener)
var boat_flash: Array = []  # ışığı ilk alış parlaması, söner
var boat_dir: Array = []    # teknenin ışığı aldığı yön (son)
var _horn_cd: Array = []
var _prev_lit := {}
var _glow_tex: GradientTexture2D
var glow := 0.0  # kutlamada güzergâh boyunca yayılan parlama (0..1)
var time := 0.0

var title_label: Label
var info_label: Label
var beam_layers: Array = []
var arka: Node2D
var water_layers: Array = []
var lit_mirrors := {}  # ışık alan aynalar (ayna → true); ayna parlaması için
var glow_layer: Node2D  # fener lambası + tekne feneri parıltısı (toplamalı, nesnelerin üstünde)
var lantern := 0.0  # tamamlanınca tekne feneri parlaması (0..1)


func _ready() -> void:
	arka = Arka.new()
	add_child(arka)
	for refl in [true, false]:  # yansıma, sonra dip halkaları + suda ışın parıltısı
		var su := SuKatmani.new()
		su.owner_main = self
		su.reflect = refl
		add_child(su)
		water_layers.append(su)
	for add in [true, false]:  # parlama (toplamalı) altta, çekirdek üstte
		var layer := IsinKatmani.new()
		layer.owner_main = self
		layer.additive = add
		add_child(layer)
		beam_layers.append(layer)
	# nesneler ışının üstünde (K1); y'ye göre sıralı: alt satır üst satırı örter
	objects = Node2D.new()
	objects.y_sort_enabled = true
	objects.z_index = 5
	add_child(objects)
	glow_layer = Node2D.new()
	var gm := CanvasItemMaterial.new()
	gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow_layer.material = gm
	glow_layer.z_index = 10
	glow_layer.draw.connect(_draw_glows)
	add_child(glow_layer)
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
	# geçiş perdesi: her şeyin üstünde, dokunuşu yutmaz
	var cl := CanvasLayer.new()
	cl.layer = 10
	add_child(cl)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.01, 0.03, 0.08, 0.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.size = Vector2(SIZE.x, 4000.0)  # uzun telefonda da kaplasın
	cl.add_child(fade_rect)
	load_level(0)


## Fener lambası ve tekne fenerleri: sıcak sarı, toplamalı. Tekne feneri hep
## yanar (tekne en net okunan nesne), ışık alınca ve bölüm bitince güçlenir.
func _draw_glows() -> void:
	# diyoramanın lamba odası (tek fener, K2): sıcak parıltı + dönen iki ışık kolu
	var lamp: Vector2 = arka.lamp_screen()
	var ds: float = arka.dio_scale
	var fl := 0.85 + 0.15 * sin(time * 2.0) * sin(time * 3.7)
	_soft_glow(lamp, 40.0 * ds, Color(1.0, 0.6, 0.2, 0.45 * fl))
	_soft_glow(lamp, 16.0 * ds, Color(1.0, 0.85, 0.5, 0.7 * fl))
	for i in 2:
		var d := Vector2.RIGHT.rotated(time * 1.3 + i * PI)
		var n := d.orthogonal() * 3.5 * ds
		var tip := lamp + d * 48.0 * ds
		var side := absf(d.x)  # yandan bakınca (kol yatayken) daha parlak
		glow_layer.draw_colored_polygon(PackedVector2Array([lamp + n, tip, lamp - n]),
			Color(1.0, 0.9, 0.6, 0.10 + 0.22 * side))
	for j in boats.size():
		var lp := _lantern_at(j)
		# bekleyen: sönük kor · ışık alan: tam yanar · ilk an: kısa parlama.
		# Yumuşak radyal doku + doygun turuncu: düz daire mavi zeminde gri disk oluyordu
		var e := _ease(boat_resp[j])
		var f: float = boat_flash[j]
		var a := 0.15 + 0.6 * e + 0.25 * lantern
		_soft_glow(lp, 40.0 * k * (1.0 + 0.4 * lantern + 1.0 * f), Color(1.0, 0.55, 0.15, 0.5 * a + 0.4 * f))
		_soft_glow(lp, 16.0 * k, Color(1.0, 0.8, 0.4, 0.8 * a + 0.3 * f))


## Toplamalı, kenarı yumuşak parıltı (r: dış yarıçap).
func _soft_glow(c: Vector2, r: float, col: Color) -> void:
	if _glow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.4, Color(1, 1, 1, 0.35))
		_glow_tex = GradientTexture2D.new()
		_glow_tex.gradient = g
		_glow_tex.fill = GradientTexture2D.FILL_RADIAL
		_glow_tex.fill_from = Vector2(0.5, 0.5)
		_glow_tex.fill_to = Vector2(1.0, 0.5)
	glow_layer.draw_texture_rect(_glow_tex, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false, col)


## Teknenin anlık yeri ve açısı: [merkez, açı]. Bekleme: yavaş yalpa + iniş-çıkış
## (her tekne farklı evrede). Işık alınca (boat_resp) ışığın geldiği yöne biraz
## süzülür — ışının ucu gövdede kalır — ve yalpası yatışır. Fizik konumu değişmez.
func _boat_pose(j: int) -> Array:
	var ph := j * 1.7
	var e := _ease(boat_resp[j])
	var c: Vector2 = boats[j] + Vector2(0, sin(time * 1.5 + ph) * 3.0 * k) - boat_dir[j] * cell * BOAT_GLIDE * e
	var ang := sin(time * 0.9 + ph) * deg_to_rad(3.0) * (1.0 - 0.5 * e)
	return [c, ang]


func _lantern_at(j: int) -> Vector2:
	var pose := _boat_pose(j)
	var f := _boat_f(boats[j])
	return pose[0] + (Vector2(0, WP * cell) + (BOAT_LANTERN - Vector2(BOAT_AX, BOAT_CUT)) * f).rotated(pose[1])


## Sprite pikselinden ekrana ölçek (G2 satır ölçeği dahil).
func _boat_f(p: Vector2) -> float:
	return BOAT_W * cell * _rs(p) / 483.0


func _rock_f(p: Vector2) -> float:
	return ROCK_W * cell * _rs(p) / 483.0


func _rs(p: Vector2) -> float:
	return row_scale.get(roundi(p.y), 1.0)


func _ease(x: float) -> float:
	return x * x * (3.0 - 2.0 * x)


## Prototip için: bölümü geç (kurucu üretilen bölümlere hızlı ulaşsın). Son bölümde ana ekrana.
func skip() -> void:
	sfx("dugme")
	_advance()


## Efekt çal. Ses autoload'u yoksa (test, eksik kurulum) sessizce geçer.
func sfx(key: String) -> void:
	var s := get_node_or_null("/root/Ses")
	if s != null:
		s.play(key)


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
	for o in objects.get_children():
		o.queue_free()
	mirrors.clear()
	rocks.clear()
	boats.clear()
	boat_nodes.clear()
	splitters.clear()
	row_scale.clear()
	var d: Dictionary = all_levels[i]
	fener_dir = DIRS[d["yon"]]
	var rows: Array = d["map"]
	var w: int = (rows[0] as String).length()
	var h: int = rows.size()
	var sp := _spacing(rows)
	var xs: Array = sp[0]
	var ys: Array = sp[1]
	var fx := 0
	var last := 0
	for y in h:
		var row: String = rows[y]
		if row.contains("F"):
			fx = row.find("F")
		if row.strip_edges(true, true).replace(".", "") != "":
			last = y
	# E1: diyorama ekranın üstünde, iskele kırpılmış. Ölçek ekrana göre: 9:16'da
	# 0.68 (fener 83.6 px), uzun ekranda büyür (en çok 1.0)
	var vis_h := maxf(SIZE.y, get_viewport_rect().size.y)
	var dio_h: float = Arka.DIO.get_height() - Arka.DIO_CONTENT_TOP
	arka.dio_scale = clampf((vis_h - INFO_H - Arka.DIO_TOP - UNITS_MAX * CELL_GOAL) / dio_h, DIO_S_MIN, DIO_S_MAX)
	# K4: ızgara diyoramanın altındaki açık denizde, dikeyde ortalı
	var area_top: float = arka.dio_bottom() + 6.0
	var area_h: float = vis_h - INFO_H - area_top
	var units: float = ys[last] - ys[0] + 0.4 + 0.6  # üst yığın payı 0.385 · alt su noktası 0.6
	cell = minf(SIZE.x / (xs[w - 1] + 2.0), area_h / units)
	k = cell / 90.0
	var origin := Vector2((SIZE.x - xs[w - 1] * cell) / 2.0, area_top + 0.4 * cell + (area_h - units * cell) / 2.0)
	info_label.position.y = vis_h - INFO_H
	# E2: levha kaynak sütununa kaydırılır; iki yönden ekranı daha çok kaplayan seçilir
	var fxp: float = origin.x + xs[fx] * cell
	var best_cov := -INF
	for flip in [false, true]:
		var lx: float = (Arka.DIO.get_width() - Arka.DIO_LAMP.x) if flip else Arka.DIO_LAMP.x
		var dx: float = fxp - lx * arka.dio_scale
		var cov := minf(SIZE.x, dx + Arka.DIO.get_width() * arka.dio_scale) - maxf(0.0, dx)
		if cov > best_cov:
			best_cov = cov
			arka.dio_flip = flip
			arka.dio_x = dx
	for y in h:
		row_scale[roundi(origin.y + ys[y] * cell)] = lerpf(ROW_SCALE_TOP, 1.0, ys[y] / maxf(1.0, ys[last]))
	for y in h:
		var row: String = rows[y]
		for x in row.length():
			var c := row[x]
			var p := origin + Vector2(xs[x], ys[y]) * cell
			match c:
				".":
					pass
				"F":
					fener_pos = p  # boş su: ışın buradan aşağı, lamba bunun tam üstünde
				"T":
					boats.append(p)
					boat_nodes.append(_obj_node(p, _draw_boat.bind(boats.size() - 1)))
				"R":
					rocks.append(p)
					_obj_node(p, _draw_rock)
				"Y":
					splitters.append(p)
					_obj_node(p, _draw_splitter)
				"M", "N", "b", "s":
					var m := Mirror.new()
					m.position = p
					m.fixed = c == "b" or c == "s"
					m.base = k
					m.row_scale = _rs(p)
					m.scale = Vector2(k, k)
					m.set_step(1 if c == "M" or c == "b" else 3)
					objects.add_child(m)
					mirrors.append(m)
				_:
					push_error("bilinmeyen harita karakteri '%s' bolum %d" % [c, i + 1])
	completed = false
	can_continue = false
	glow = 0.0
	lantern = 0.0
	var nb := boats.size()
	boat_resp = _zeros(nb, 0.0)
	boat_flash = _zeros(nb, 0.0)
	_horn_cd = _zeros(nb, 0.0)
	boat_dir = _zeros(nb, Vector2.ZERO)
	var n_hand := Levels.ALL.size()
	if i < n_hand:
		title_label.text = tr("BOLUM") % (i + 1)
	else:
		title_label.text = tr("URETILEN") % [i - n_hand + 1, d["zorluk"]]
	info_label.text = ""
	_place_moon()
	_loaded = false  # yükleme anında çan çalmasın
	update_ray()
	_loaded = true


func _zeros(n: int, v) -> Array:
	var a: Array = []
	a.resize(n)
	a.fill(v)
	return a


## Ay gökte (ufkun üstü): başlık/Atla şeridine ve diyoramaya en az binen aday.
func _place_moon() -> void:
	var hy: float = arka.horizon_y()
	var sz := clampf(hy * 0.62, 50.0, 110.0)
	arka.moon_size = sz
	var ui := [Rect2(0, 0, 400, 64), SKIP_RECT.grow(6)]
	var best := INF
	for c in [Vector2(630, 0.55), Vector2(90, 0.55), Vector2(470, 0.5), Vector2(250, 0.5)]:
		var p := Vector2(c.x, maxf(sz * 0.5 + 4.0, hy * c.y))
		var r := Rect2(p - Vector2.ONE * sz / 2.0, Vector2.ONE * sz)
		var cost := 0.0
		for u in ui:
			cost += r.intersection(u).get_area() / r.get_area() * 3.0
		for gx in 5:
			for gy in 5:
				if arka.dio_opaque(r.position + r.size * Vector2(gx + 0.5, gy + 0.5) / 5.0):
					cost += 1.0 / 25.0
		if cost < best:
			best = cost
			arka.moon_pos = p
	arka.show_moon = best < 0.6  # yarıdan çoğu örtülüyorsa hiç çizme


## Suya oturan her nesne için: su hattı (wl = su noktası), dip halkası (rw) ve
## yansıma parçaları. Parça dikdörtgenleri center'a göre (+ açı, kaynak bölge).
## Çizimle aynı ölçüler; su_katmani.gd okur (G3: yansıma su noktasından).
func water_items() -> Array:
	var out: Array = []
	for r in rocks:
		var f := _rock_f(r)
		var wp := Vector2(0, WP * cell)
		out.append({"center": r, "wl": r.y + WP * cell, "rw": cell * 0.5 * _rs(r), "tex": ROCK,
			"rect": Rect2(wp - Vector2(ROCK_AX, ROCK_CUT) * f, Vector2(512, ROCK_CUT) * f),
			"region": Rect2(0, 0, 512, ROCK_CUT)})
	for j in boats.size():
		var pose := _boat_pose(j)
		var c: Vector2 = pose[0]
		var f := _boat_f(boats[j])
		var e := _ease(boat_resp[j])
		var wp := Vector2(0, WP * cell)
		out.append({"center": c, "wl": c.y + WP * cell, "rw": cell * 0.6 * _rs(boats[j]), "tex": BOAT,
			"rect": Rect2(wp - Vector2(BOAT_AX, BOAT_CUT) * f, Vector2(512, BOAT_CUT) * f),
			"region": Rect2(0, 0, 512, BOAT_CUT), "angle": pose[1], "wake": boat_dir[j] * e})
	for m in mirrors:
		var ps: Array = m.parts()
		var wl: float = m.position.y + m.waterline() * k
		for q in ps.size():
			var part: Dictionary = ps[q]
			var r2: Rect2 = part["rect"]
			var it := {"center": m.position, "wl": wl, "rw": cell * 0.4 * m.row_scale, "ring": q == 0,
				"tex": part["tex"], "rect": Rect2(r2.position * k, r2.size * k)}
			if part.has("region"):
				it["region"] = part["region"]
			out.append(it)
	for sp in splitters:
		out.append({"center": sp, "wl": sp.y + SPLIT_RADIUS * k * 1.15, "rw": cell * 0.3})
	return out


## Nesne düğümü: y'ye göre sıralı katmanda, hücre merkezinde; çizimi drawer yapar.
func _obj_node(p: Vector2, drawer: Callable) -> Node2D:
	var n := Node2D.new()
	n.position = p
	n.draw.connect(drawer.bind(n))
	objects.add_child(n)
	return n


## Sütun ve satır merkezleri (hücre biriminde). Büyük nesne komşusuna binmesin
## diye aralarına boşluk eklenir: tekne ile yatay/dikey komşusu arasına GAP.
## (İŞ 10: kule ızgarada değil, kule kuralları kalktı.)
## Işın hep satır/sütun merkezinden geçtiği için fizik değişmez.
## tools/cakisma.py aralik() ile aynı kural; biri değişirse öteki de.
func _spacing(rows: Array) -> Array:
	var w: int = (rows[0] as String).length()
	var h: int = rows.size()
	var gx: Array = []
	var gy: Array = []
	gx.resize(w)
	gx.fill(0.0)
	gy.resize(h)
	gy.fill(0.0)
	var at := func(x: int, y: int) -> String:
		if x < 0 or y < 0 or x >= w or y >= h:
			return "."
		return (rows[y] as String)[x]
	for y in h:
		for x in w:
			var c: String = at.call(x, y)
			if c == "T":
				for dx in [-1, 1]:
					if at.call(x + dx, y) not in [".", "F"]:
						gx[mini(x, x + dx)] = maxf(gx[mini(x, x + dx)], GAP)
				for dy in [-1, 1]:
					if at.call(x, y + dy) not in [".", "F"]:
						gy[mini(y, y + dy)] = maxf(gy[mini(y, y + dy)], GAP)
	var xs: Array = []
	var ys: Array = []
	var a := 0.0
	for i in w:
		xs.append(i + a)
		a += gx[i]
	a = 0.0
	for i in h:
		ys.append(i + a)
		a += gy[i]
	return [xs, ys]


func _process(delta: float) -> void:
	time += delta
	update_ray()
	for j in boats.size():
		# karşılık ~1.4 sn'de tamamlanır; ışık kaybolursa ~0.8 sn'de geri döner
		var up := lit.has(j)
		boat_resp[j] = move_toward(boat_resp[j], 1.0 if up else 0.0, delta / (1.4 if up else 0.8))
		boat_flash[j] = maxf(0.0, boat_flash[j] - delta * 1.6)
		_horn_cd[j] = maxf(0.0, _horn_cd[j] - delta)
	if hit and not completed:
		_celebrate()
	queue_redraw()
	for l in beam_layers + water_layers:
		l.queue_redraw()
	for m in mirrors:
		m.lit = lit_mirrors.has(m)
	glow_layer.queue_redraw()


# --- ışın --------------------------------------------------------------------

func update_ray() -> void:
	var r := compute_path()
	paths = r["paths"]
	# K3: ilk kol lamba odası pikselinden başlar (lamba F sütununun tam üstünde)
	if not paths.is_empty():
		var p0: PackedVector2Array = paths[0]
		p0[0] = arka.lamp_screen()
		paths[0] = p0
	lit = r["lit"]
	hit = r["hit"]
	lit_mirrors = r["mirrors"]
	var dirs: Dictionary = r["boat_dirs"]
	for j in lit:
		boat_dir[j] = dirs[j]
		# yeni ışık alan tekne karşılık verir: fener parlar, çan, biraz sonra korna
		if _loaded and not _prev_lit.has(j):
			boat_flash[j] = 1.0
			sfx("isin")
			if _horn_cd[j] <= 0.0:
				_horn_cd[j] = HORN_COOLDOWN
				get_tree().create_timer(HORN_DELAY).timeout.connect(sfx.bind("korna"))
	_prev_lit = lit


## Bütün kolları izler. Bölücü gelen kolu durdurur, merkezinden sağa ve sola
## iki yeni kol çıkarır. → {paths, lit (tekne indeksi → true), hit (hepsi mi)}
func compute_path() -> Dictionary:
	var out: Array = []
	var got := {}
	var mhit := {}  # ışığın yansıdığı aynalar
	var bdir := {}  # tekne indeksi → ışığın geliş yönü
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
			# İŞ 11: kaynak ızgaranın üstünde; F hücresi boş su, ışın geçer (uretec.py ile aynı)
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
				bdir[idx] = dir
				break
			if best_m == null:
				break  # ekran kenarı, kaya ya da fener
			mhit[best_m] = true
			dir = best_m.reflect(dir)
		out.append(pts)
	return {"paths": out, "lit": got, "hit": got.size() == boats.size(), "mirrors": mhit, "boat_dirs": bdir}


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


## Ekran kenarı. Yukarı giden ışın diyoramanın alt kenarında biter (kaynağa
## geri döner); altta görünen alanın sonuna kadar (20:9'da 1280'den uzun).
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
	for j in boats.size():
		_sparkle(j)
	create_tween().tween_property(self, "lantern", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
	var tw := create_tween()
	tw.tween_property(self, "glow", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	# tekne süzülmesi (boat_resp, ~1.4 sn) görünsün diye bekle; eski "büyüyüp küçülme" kalktı
	tw.tween_interval(0.8)
	# çan (0 sn) ve korna (HORN_DELAY) update_ray'de; "bölüm tamam" kornadan sonra
	create_tween().tween_callback(sfx.bind("tamam")).set_delay(1.1)
	tw.tween_callback(func():
		can_continue = true
		var last := level == all_levels.size() - 1
		title_label.text = tr("TAMAM")
		info_label.text = tr("SON") if last else ""
		if auto_advance:  # kutlama bitti: kendiliğinden sonraki bölüm (dokunmak beklemeyi keser)
			get_tree().create_timer(AUTO_WAIT_LAST if last else AUTO_WAIT).timeout.connect(_advance))


## Sonraki bölüme (son bölümden sonra ana ekrana) kısa kararma/açılmayla geç.
## Tekrar çağrılırsa (dokunuş + zamanlayıcı) bir kez geçer.
func _advance() -> void:
	if transitioning or not is_inside_tree():
		return
	transitioning = true
	var last := level == all_levels.size() - 1
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.25)
	tw.tween_callback(func():
		if last:
			_to_menu()
			return
		load_level(level + 1)
		var tin := create_tween()
		tin.tween_property(fade_rect, "color:a", 0.0, 0.3)
		tin.tween_callback(func(): transitioning = false))


## Sakin, kısa parçacık: tekne fenerinden yukarı süzülen birkaç sıcak kıvılcım.
func _sparkle(j: int) -> void:
	var p := CPUParticles2D.new()
	p.position = _lantern_at(j)
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


func _boat_scale_px() -> float:
	return cell * BOAT_W / 490.0  # tekne görünür genişliği BOAT_W hücre (bbox 490)


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
		_advance()  # beklemeden geç
		return
	if transitioning:
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
		sfx("ayna")


# --- çizim -------------------------------------------------------------------
# Işın ayrı katmanlarda (isin_katmani.gd). Burada: kaya, bölücü, fener, tekne.

func _draw() -> void:
	# kayalık: yarı batık — ROCK_CUT satırının altı suyun içinde, çizilmez
	var rs := cell * 1.1 / 490.0  # görünür genişlik 1.1 hücre (bbox 490)
	for r in rocks:
		draw_texture_rect_region(ROCK, Rect2(r - Vector2(256, 256) * rs, Vector2(512, ROCK_CUT) * rs),
			Rect2(0, 0, 512, ROCK_CUT))

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

	# fener: lamba odası ışının çıktığı hücre merkezinde, kule hep dik ve büyük
	# (gövdesi alttaki hücrelere iner; _spacing çakışmayı önler). Parıltı: _draw_glows
	# kule bir kayalık adacığın üstünde durur (adacığın altı suda)
	var isl := _islet_geom()
	var is_s: float = isl[1]
	draw_texture_rect_region(ROCK, Rect2(isl[0] - ISLET_ANCHOR * is_s, Vector2(512, ISLET_CUT) * is_s),
		Rect2(0, 0, 512, ISLET_CUT))
	var ts := cell * TOWER_H / 490.0
	draw_texture_rect(TOWER, Rect2(fener_pos - TOWER_LAMP * ts, Vector2(TOWER.get_width(), TOWER.get_height()) * ts), false)

	# tekneler: bekleyen sakin yalpalar, feneri sönük; ışık alan sıcak renge
	# bürünür, feneri parlar, ışığa doğru süzülür (_boat_pose). Gövdenin altı suda
	var bsc := _boat_scale_px()
	for j in boats.size():
		var pose := _boat_pose(j)
		var e := _ease(boat_resp[j])
		var tint := Color(1, 1, 1).lerp(Color(1.16, 1.06, 0.9), e)
		draw_set_transform(pose[0], pose[1], Vector2.ONE)
		draw_texture_rect_region(BOAT, Rect2(Vector2(-256, -256) * bsc, Vector2(512, BOAT_CUT) * bsc),
			Rect2(0, 0, 512, BOAT_CUT), tint)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var lc := Color(0.75, 0.68, 0.5).lerp(Color(1.0, 0.95, 0.72), maxf(e, boat_flash[j]))
		draw_circle(_lantern_at(j), 5.0 * k, lc)
