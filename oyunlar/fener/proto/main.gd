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
	glow_layer = Node2D.new()
	var gm := CanvasItemMaterial.new()
	gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow_layer.material = gm
	glow_layer.z_index = 1
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
	var fl := 0.85 + 0.15 * sin(time * 2.0) * sin(time * 3.7)
	_soft_glow(fener_pos, 52.0 * k, Color(1.0, 0.6, 0.2, 0.45 * fl))
	_soft_glow(fener_pos, 22.0 * k, Color(1.0, 0.85, 0.5, 0.7 * fl))
	# lamba odasında dönen parıltı: iki ince, uca doğru sivrilen ışık kolu
	for i in 2:
		var d := Vector2.RIGHT.rotated(time * 1.3 + i * PI)
		var n := d.orthogonal() * 5.0 * k
		var tip := fener_pos + d * 62.0 * k
		var side := absf(d.x)  # yandan bakınca (kol yatayken) daha parlak
		glow_layer.draw_colored_polygon(PackedVector2Array([fener_pos + n, tip, fener_pos - n]),
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
	return pose[0] + ((BOAT_LANTERN - Vector2(256, 256)) * _boat_scale_px()).rotated(pose[1])


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
	var sp := _spacing(rows)
	var xs: Array = sp[0]
	var ys: Array = sp[1]
	# uzun telefonda (20:9) görünen yükseklik 1280'den fazla: fazlası oyun alanına
	var vis_h := maxf(SIZE.y, get_viewport_rect().size.y)
	var span := PLAY_SPAN + (vis_h - SIZE.y)
	# dikeyde DOLU satırlar ortalanır (haritaların alt satırları çoğu kez boş);
	# üst/alt pay: nesnenin yarısı; kule + adacık lambadan ~1.9 hücre aşağı iner
	var top := INF
	var bot := -INF
	for y in h:
		for x in w:
			var ch := (rows[y] as String)[x]
			if ch != ".":
				top = minf(top, ys[y] - 0.6)
				bot = maxf(bot, ys[y] + (1.9 if ch == "F" else 0.6))
	# hücre: genişliğe (kenarda yarım hücre pay) ve oyun alanı yüksekliğine sığan en büyük
	cell = minf(SIZE.x / (xs[w - 1] + 2.0), span / (bot - top))
	k = cell / 90.0
	var origin := Vector2((SIZE.x - xs[w - 1] * cell) / 2.0,
		PLAY_TOP + (span - (bot - top) * cell) / 2.0 - top * cell)
	info_label.position.y = vis_h - 80.0
	for y in h:
		var row: String = rows[y]
		for x in row.length():
			var c := row[x]
			var p := origin + Vector2(xs[x], ys[y]) * cell
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
	# ufuk ilk dolu satırın biraz üstünde: bütün nesneler suda durur
	arka.horizon_y = origin.y + (top + 0.6 - 0.3) * cell
	_place_moon()
	_loaded = false  # yükleme anında çan çalmasın
	update_ray()
	_loaded = true


func _zeros(n: int, v) -> Array:
	var a: Array = []
	a.resize(n)
	a.fill(v)
	return a


## Ay ufkun üstündeki gökte, başlık şeridinin altında; boyu gök yüksekliğine
## göre. Kule tepesi ya da ufku aşan nesneyle çakışırsa sıradaki x denenir,
## hepsi doluysa ay o bölümde çizilmez.
func _place_moon() -> void:
	var hy: float = arka.horizon_y
	var sz := clampf((hy - 72.0) * 0.8, 44.0, Arka.MOON_SIZE)
	var y := (68.0 + hy) * 0.5
	var r := sz * 0.5 + cell * 0.45
	var objs: Array = boats + rocks + splitters
	for m in mirrors:
		objs.append(m.position)
	for i in 5:  # kule gövdesi lambanın biraz üstünden aşağı iner
		objs.append(fener_pos + Vector2(0, cell * (0.4 * i - 0.3)))
	arka.moon_size = sz
	for x in [600.0, 460.0, 320.0]:
		var cand := Vector2(x, y)
		# ay yolu teknenin altından geçmesin (tekne/zemin kontrastı düşer)
		var free_col: bool = boats.all(func(b): return absf(b.x - x) > cell * 0.9 + 45.0)
		if free_col and objs.all(func(p): return p.distance_to(cand) > r):
			arka.moon_pos = cand
			arka.show_moon = true
			return
	arka.show_moon = false


## Suya oturan her nesne için: su hattı (wl), dip halkası yarıçapı (rw) ve
## yansıması çizilecekse doku + (center'a göre) dikdörtgen [+ açı, kaynak bölge].
## Çizimle (_draw) aynı ölçüler; su_katmani.gd okur.
func water_items() -> Array:
	var out: Array = []
	var ts := cell * TOWER_H / 490.0
	var isl := _islet_geom()
	out.append({"center": isl[0], "wl": isl[2], "rw": cell * 0.62, "tex": ROCK,
		"rect": Rect2(-ISLET_ANCHOR * isl[1], Vector2(512, ISLET_CUT) * isl[1]),
		"region": Rect2(0, 0, 512, ISLET_CUT)})
	out.append({"center": fener_pos, "wl": isl[2], "rw": 0.0, "ring": false, "tex": TOWER,
		"rect": Rect2(-TOWER_LAMP * ts, Vector2(512, 512) * ts)})
	var rs := cell * 1.1 / 490.0
	for r in rocks:
		out.append({"center": r, "wl": r.y + (ROCK_CUT - 256) * rs, "rw": cell * 0.55, "tex": ROCK,
			"rect": Rect2(Vector2(-256, -256) * rs, Vector2(512, ROCK_CUT) * rs),
			"region": Rect2(0, 0, 512, ROCK_CUT)})
	var bsc := _boat_scale_px()
	for j in boats.size():
		var pose := _boat_pose(j)
		var c: Vector2 = pose[0]
		var e := _ease(boat_resp[j])
		# yansıma teknenin yalpasıyla birlikte sallanır (aynı açı); süzülürken arkada iz
		out.append({"center": c, "wl": c.y + (BOAT_CUT - 256) * bsc, "rw": cell * 0.75, "tex": BOAT,
			"rect": Rect2(Vector2(-256, -256) * bsc, Vector2(512, BOAT_CUT) * bsc),
			"region": Rect2(0, 0, 512, BOAT_CUT), "angle": pose[1], "wake": boat_dir[j] * e})
	for m in mirrors:
		var wl: float = m.position.y + m.waterline() * k
		if not m.fixed:
			out.append({"center": m.position, "wl": wl, "rw": cell * 0.32, "tex": Mirror.BASE_TEX,
				"rect": m.base_rect(k)})
		out.append({"center": m.position, "wl": wl, "rw": 0.0, "ring": m.fixed, "tex": Mirror.PLATE,
			"rect": m.plate_rect(k), "angle": m.rotation})
	for sp in splitters:
		out.append({"center": sp, "wl": sp.y + SPLIT_RADIUS * k * 1.15, "rw": cell * 0.3})
	return out


## Kule adacığı: [kayalık görselinin çizim merkezi, ölçek, su hattı y].
## Kule dibi adacığın üst yarısına oturur; adacığın altı suyun içinde kalır.
func _islet_geom() -> Array:
	var ts := cell * TOWER_H / 490.0
	var s := cell * ISLET_W / 490.0
	var foot := fener_pos.y + (TOWER_FOOT - TOWER_LAMP.y) * ts
	var c := Vector2(fener_pos.x, foot - 4.0 * k)  # kayalık görselinde ISLET_ANCHOR buraya
	return [c, s, c.y + (ISLET_CUT - ISLET_ANCHOR.y) * s]


## Sütun ve satır merkezleri (hücre biriminde). Büyük nesne komşusuna binmesin
## diye aralarına boşluk eklenir: tekne ile yatay/dikey komşusu arasına GAP,
## kulenin hemen altındaki nesneyle arasına GAP (tekneyse GAP_TOWER_BOAT).
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
					if at.call(x + dx, y) != ".":
						gx[mini(x, x + dx)] = maxf(gx[mini(x, x + dx)], GAP)
				for dy in [-1, 1]:
					if at.call(x, y + dy) != ".":
						gy[mini(y, y + dy)] = maxf(gy[mini(y, y + dy)], GAP)
			elif c == "F":
				var below: String = at.call(x, y + 1)
				if below != ".":
					gy[y] = maxf(gy[y], GAP_TOWER_BOAT if below == "T" else GAP)
				if at.call(x, y + 2) != ".":  # kule adacığı iki satır aşağı uzanır
					gy[y + 1] = maxf(gy[y + 1], GAP)
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
