extends Node2D
## Ortak arka plan. Ana ekran ve oyun ikisi de kullanır; en altta (z -10).
## İŞ 10 katman sırası (alttan üste, K1): gökyüzü → ay → deniz shader →
## ay yolu (+ sis) → diyorama levhası. Nesne yansımaları, ışın ve nesneler
## main.gd'de, bunların üstünde.
##
## Diyorama tek PNG levha (yaw -40° / pitch 30° render, iskele kırpılmış,
## tools/is10_varlik.py). Işık kaynağı levhanın kendi feneridir: main.gd
## levhayı ölçekler, gerekirse yatayda aynalar ve kaydırır; lamba pikseli
## kaynak sütununun tam üstüne gelir (lamp_screen()).

const SKY := preload("res://gorseller/gokyuzu.png")
const BG := preload("res://gorseller/arkaplan_gece_denizi.png")
const MOON := preload("res://gorseller/ay.png")
const FOG := preload("res://gorseller/sis_katmani.png")
const DIO := preload("res://gorseller/diyorama_levha.png")

const SIZE := Vector2(720, 1280)
const MOON_SIZE := 140.0
const HOR_F := 517.0 / 1672.0  # arkaplan_gece_denizi.png ufuk satırı (ölçüldü)
## Levha ölçüleri (tools/is10_varlik.py çıktısı, levha pikseli)
const DIO_LAMP := Vector2(751.9, 78.9)  # lamba odası
const DIO_CONTENT_TOP := 12.0           # en üst dolu satır
const DIO_HORIZON := 150.0              # ufuk bu satırın hizasında (köyün arkası)
const DIO_TOWER_H := 123.0              # fener kulesi boyu (tepe → gövde dibi)
const DIO_TOP := 16.0                   # içerik tepesinin ekrandaki y'si
## sis bantları: [merkez y, yükseklik, alfa, hız px/sn]. İŞ 10 K6: denizin en
## açık bandı sisti (tekne/kaya kontrastı 1.0-1.1); alfa 0.40/0.35 → 0.12/0.10
const FOG_BANDS := [
	[420.0, 300.0, 0.12, 9.0],
	[880.0, 360.0, 0.10, -6.0],
]

## Deniz: yavaş yatay/dikey kıpırtı + kayan soluk parıltı bantları (İŞ 7)
const SEA_SHADER := "shader_type canvas_item;
uniform float horizon = 0.31;
void fragment() {
	vec2 uv = UV;
	float depth = max(uv.y - horizon, 0.0);
	uv.x += sin(uv.y * 260.0 / (depth * 3.0 + 0.25) - TIME * 0.9) * 0.0016;
	uv.y += sin(uv.x * 24.0 + TIME * 0.5 + uv.y * 90.0) * 0.0010;
	vec4 c = texture(TEXTURE, uv);
	float band = sin(uv.y * 190.0 / (depth * 3.5 + 0.2) - TIME * 0.6 + sin(uv.x * 7.0 + TIME * 0.25) * 2.2);
	c.rgb += smoothstep(0.88, 1.0, band) * 0.018 * vec3(0.55, 0.72, 1.0);
	COLOR = c;
}"

## Ay (İŞ 12): sert disk kenarı yumuşar ve kenara doğru gök rengine karışır
## (gökyüzüne gömülsün); arkada geniş, çok soluk hale.
const MOON_SHADER := "shader_type canvas_item;
uniform vec3 sky = vec3(0.10, 0.16, 0.32);
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float d = length(UV - vec2(0.5)) * 2.0;  // 0 merkez, 1 kenar
	c.rgb = mix(c.rgb, sky, smoothstep(0.55, 0.95, d) * 0.45);
	c.a *= 1.0 - smoothstep(0.78, 1.0, d);
	COLOR = c;
}"

var moon_pos := Vector2(590, 90)
var moon_size := 90.0
var show_moon := true
## Diyorama yerleşimi (main.gd ayarlar; ana ekranda varsayılan: lamba ortada)
var dio_scale := 0.68
var dio_flip := false
var dio_x := 360.0 - DIO_LAMP.x * 0.68  # levhanın sol kenarı (ekran x)
var t := 0.0
var _layers: Array = []
var _dio_img: Image
var _moon_node: Node2D
var _halo: GradientTexture2D


func _ready() -> void:
	z_index = -10
	var sh := Shader.new()
	sh.code = SEA_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("horizon", HOR_F)
	# sırayla eklenir = sırayla çizilir (K1)
	for f in [_draw_sky, _draw_sea, _draw_path, _draw_dio]:
		var n := Node2D.new()
		n.draw.connect(f.bind(n))
		add_child(n)
		_layers.append(n)
	_layers[1].material = mat
	_dio_img = DIO.get_image()
	# ay: gökyüzü katmanının çocuğu (gökten sonra, denizden önce çizilir, K1)
	_moon_node = Node2D.new()
	var msh := Shader.new()
	msh.code = MOON_SHADER
	var mm := ShaderMaterial.new()
	mm.shader = msh
	_moon_node.material = mm
	_moon_node.draw.connect(_draw_moon)
	_layers[0].add_child(_moon_node)
	var g := Gradient.new()
	g.set_color(0, Color(0.95, 0.9, 0.8, 0.22))
	g.set_color(1, Color(0.8, 0.86, 1.0, 0.0))  # önce uçlar: add_point indeksleri kaydırır
	g.add_point(0.35, Color(0.85, 0.88, 1.0, 0.08))
	_halo = GradientTexture2D.new()
	_halo.gradient = g
	_halo.fill = GradientTexture2D.FILL_RADIAL
	_halo.fill_from = Vector2(0.5, 0.5)
	_halo.fill_to = Vector2(1.0, 0.5)


func _process(delta: float) -> void:
	t += delta
	for n in _layers:
		n.queue_redraw()


func visible_size() -> Vector2:
	# keep_width: uzun telefonda (20:9) görünen yükseklik 1280'den büyük
	return Vector2(SIZE.x, maxf(SIZE.y, get_viewport_rect().size.y))


func dio_y() -> float:
	return DIO_TOP - DIO_CONTENT_TOP * dio_scale


func dio_bottom() -> float:
	return dio_y() + DIO.get_height() * dio_scale


func horizon_y() -> float:
	return dio_y() + DIO_HORIZON * dio_scale


## Lambanın ekrandaki yeri (ışın buradan çıkar, K3).
func lamp_screen() -> Vector2:
	var lx := (DIO.get_width() - DIO_LAMP.x) if dio_flip else DIO_LAMP.x
	return Vector2(dio_x + lx * dio_scale, dio_y() + DIO_LAMP.y * dio_scale)


## Ekrandaki bir noktada levha opak mı (ay yerleşimi için).
func dio_opaque(p: Vector2) -> bool:
	var lx := (p.x - dio_x) / dio_scale
	var ly := (p.y - dio_y()) / dio_scale
	if dio_flip:
		lx = DIO.get_width() - lx
	if lx < 0 or ly < 0 or lx >= _dio_img.get_width() or ly >= _dio_img.get_height():
		return false
	return _dio_img.get_pixel(int(lx), int(ly)).a > 0.2


func _draw_sky(n: Node2D) -> void:
	var hy := horizon_y()
	var s := maxf(SIZE.x / SKY.get_width(), hy / SKY.get_height())
	var sz := Vector2(SKY.get_width(), SKY.get_height()) * s
	n.draw_texture_rect(SKY, Rect2(Vector2((SIZE.x - sz.x) / 2.0, hy - sz.y), sz), false)
	if show_moon:  # geniş soluk hale (ayın kendisi _moon_node'da, yumuşak kenarlı)
		var hs := moon_size * 3.2 * (1.0 + 0.03 * sin(t * 0.8))
		n.draw_texture_rect(_halo, Rect2(moon_pos - Vector2.ONE * hs / 2.0, Vector2.ONE * hs), false)
	_moon_node.queue_redraw()


func _draw_moon() -> void:
	if show_moon:
		_moon_node.draw_texture_rect(MOON, Rect2(moon_pos - Vector2.ONE * moon_size / 2.0, Vector2.ONE * moon_size), false)


## Deniz görselinin yalnız ufuk altı kısmı, ufuk çizgisi diyoramanın ufkunda.
func _draw_sea(n: Node2D) -> void:
	var hy := horizon_y()
	var vis := visible_size()
	var w := float(BG.get_width())
	var h := float(BG.get_height())
	var src_top := HOR_F * h
	var s := maxf(vis.x / w, (vis.y - hy) / (h - src_top))
	var dw := w * s
	n.draw_texture_rect_region(BG, Rect2((vis.x - dw) / 2.0, hy, dw, (h - src_top) * s),
		Rect2(0, src_top, w, h - src_top))


func _draw_path(n: Node2D) -> void:
	if show_moon:
		_moon_path(n, horizon_y(), visible_size().y)
	for band in FOG_BANDS:
		var h: float = band[1]
		var w: float = FOG.get_width() * h / FOG.get_height()
		var off: float = fposmod(t * band[3], w)
		var y: float = band[0] - h / 2.0
		var x := -off
		while x < SIZE.x:
			n.draw_texture_rect(FOG, Rect2(x, y, w, h), false, Color(1, 1, 1, band[2]))
			x += w


func _draw_dio(n: Node2D) -> void:
	var sz := Vector2(DIO.get_width(), DIO.get_height()) * dio_scale
	if dio_flip:  # yatay aynalı (negatif genişlikli dikdörtgen hiç çizilmiyordu → dönüşüm)
		n.draw_set_transform(Vector2(dio_x + sz.x, dio_y()), 0.0, Vector2(-1, 1))
		n.draw_texture_rect(DIO, Rect2(Vector2.ZERO, sz), false)
		n.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		n.draw_texture_rect(DIO, Rect2(Vector2(dio_x, dio_y()), sz), false)


## Ay yolu: ayın altında, ufuktan aşağı titreyen kısa gümüş çizgiler (İŞ 7).
func _moon_path(n: Node2D, hy: float, bottom: float) -> void:
	var length := (bottom - hy) * 0.45
	var y := hy + 2.0
	while y < hy + length:
		var f := (y - hy) / length
		var w := lerpf(0.5, 1.5, f) * moon_size
		var jx := sin(y * 0.11 + t * 1.3) * 6.0 * f + sin(y * 0.047 - t * 0.7) * 10.0 * f
		var fl := (0.5 + 0.5 * sin(y * 0.61 - t * 1.9)) * (0.5 + 0.5 * sin(y * 0.23 + t * 1.1 + sin(y * 0.05) * 3.0))
		var a := (0.05 + 0.30 * fl) * pow(1.0 - f, 1.5)
		var seg := w * (0.3 + 0.7 * fl)
		n.draw_rect(Rect2(moon_pos.x + jx - seg / 2.0, y, seg, 2.0), Color(0.78, 0.86, 1.0, a * 0.5))
		n.draw_rect(Rect2(moon_pos.x + jx - seg / 4.0, y, seg / 2.0, 2.0), Color(0.9, 0.95, 1.0, a))
		y += 3.0 + 3.0 * f
