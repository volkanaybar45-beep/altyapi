extends Node2D
## Ortak arka plan: gece denizi + ay + yavaş kayan sis. Ana ekran ve oyun
## ikisi de kullanır. En altta çizilir (z_index -10); ışın ve nesneler üstte,
## böylece ışın sisin içinden geçerken kaybolmaz.
##
## İŞ 7: deniz shader'la yavaşça dalgalanır; ay yumuşak haleli, suda titreyen
## gümüş ay yolu var. Oyunda ufuk (horizon_y) ızgaranın üstüne alınır: bütün
## nesneler suda durur, gökte (havada) nesne kalmaz.

const BG := preload("res://gorseller/arkaplan_gece_denizi.png")
const MOON := preload("res://gorseller/ay.png")
const FOG := preload("res://gorseller/sis_katmani.png")

const SIZE := Vector2(720, 1280)
const MOON_SIZE := 140.0
const HOR_F := 517.0 / 1672.0  # arkaplan görselinde ufuk satırı (ölçüldü)
## sis bantları: [merkez y, yükseklik, alfa, hız px/sn]; alfa %35-50 (iş emri)
const FOG_BANDS := [
	[420.0, 300.0, 0.40, 9.0],
	[880.0, 360.0, 0.35, -6.0],
]

## Deniz: ufkun altında yavaş yatay/dikey kıpırtı + kayan soluk parıltı
## bantları. Genlik küçük: sahne sakin kalsın, sallanmasın.
const SEA_SHADER := "shader_type canvas_item;
uniform float horizon = 0.31;
void fragment() {
	vec2 uv = UV;
	float sea = smoothstep(horizon + 0.002, horizon + 0.02, uv.y);
	float depth = max(uv.y - horizon, 0.0);
	uv.x += sea * sin(uv.y * 260.0 / (depth * 3.0 + 0.25) - TIME * 0.9) * 0.0016;
	uv.y += sea * sin(uv.x * 24.0 + TIME * 0.5 + uv.y * 90.0) * 0.0010;
	vec4 c = texture(TEXTURE, uv);
	float band = sin(uv.y * 190.0 / (depth * 3.5 + 0.2) - TIME * 0.6 + sin(uv.x * 7.0 + TIME * 0.25) * 2.2);
	c.rgb += sea * smoothstep(0.88, 1.0, band) * 0.028 * vec3(0.55, 0.72, 1.0);
	COLOR = c;
}"

var moon_pos := Vector2(590, 190)
var moon_size := MOON_SIZE
var show_moon := true  # oyunda nesnelerle çakışan yer yoksa main.gd kapatır
var horizon_y := -1.0  # < 0: görselin kendi ufku (ana ekran)
var t := 0.0
var _sea: Node2D
var _halo: GradientTexture2D


func _ready() -> void:
	z_index = -10
	_sea = Node2D.new()
	_sea.show_behind_parent = true  # ay, ay yolu ve sis denizin üstünde
	var sh := Shader.new()
	sh.code = SEA_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("horizon", HOR_F)
	_sea.material = mat
	_sea.draw.connect(func(): _sea.draw_texture_rect(BG, bg_rect(), false))
	add_child(_sea)
	var g := Gradient.new()
	g.set_color(0, Color(0.85, 0.92, 1.0, 0.38))
	g.set_color(1, Color(0.85, 0.92, 1.0, 0.0))
	g.add_point(0.35, Color(0.85, 0.92, 1.0, 0.16))
	_halo = GradientTexture2D.new()
	_halo.gradient = g
	_halo.fill = GradientTexture2D.FILL_RADIAL
	_halo.fill_from = Vector2(0.5, 0.5)
	_halo.fill_to = Vector2(1.0, 0.5)
	_halo.width = 128
	_halo.height = 128


func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	_sea.queue_redraw()


func visible_size() -> Vector2:
	# keep_width: uzun telefonda (20:9) görünen yükseklik 1280'den büyük
	return Vector2(SIZE.x, maxf(SIZE.y, get_viewport_rect().size.y))


## Zemin görselinin ekrandaki yeri. Görünen alanı kaplar; horizon_y verilmişse
## görselin ufku o y'ye gelecek şekilde ölçeklenir/kaydırılır (yanlar kırpılır).
func bg_rect() -> Rect2:
	var vis := visible_size()
	var w := float(BG.get_width())
	var h := float(BG.get_height())
	var s := maxf(vis.x / w, vis.y / h)
	var top := 0.0
	if horizon_y > 0.0:
		s = maxf(s, maxf(horizon_y / (HOR_F * h), (vis.y - horizon_y) / ((1.0 - HOR_F) * h)))
		top = horizon_y - HOR_F * h * s
	return Rect2(Vector2((vis.x - w * s) / 2.0, top), Vector2(w, h) * s)


func horizon_screen_y() -> float:
	var r := bg_rect()
	return r.position.y + HOR_F * r.size.y


func _draw() -> void:
	var vis := visible_size()
	var hy := horizon_screen_y()
	if show_moon:
		_moon_path(hy, vis.y)
		var pulse := 1.0 + 0.04 * sin(t * 0.8)
		var hs := moon_size * 2.6 * pulse
		draw_texture_rect(_halo, Rect2(moon_pos - Vector2.ONE * hs / 2.0, Vector2.ONE * hs), false)
		draw_texture_rect(MOON, Rect2(moon_pos - Vector2.ONE * moon_size / 2.0, Vector2.ONE * moon_size), false)
	# sis: yatay döşenir, kayar (görsel kenarları eşleşik)
	for band in FOG_BANDS:
		var h: float = band[1]
		var w: float = FOG.get_width() * h / FOG.get_height()
		var off: float = fposmod(t * band[3], w)
		var y: float = band[0] - h / 2.0
		var x := -off
		while x < SIZE.x:
			draw_texture_rect(FOG, Rect2(x, y, w, h), false, Color(1, 1, 1, band[2]))
			x += w


## Ay yolu: ayın altında, ufuktan aşağı titreyen kısa gümüş çizgiler.
## Aşağı indikçe genişler ve söner (denizin üst %45'i).
func _moon_path(hy: float, bottom: float) -> void:
	var length := (bottom - hy) * 0.45
	var y := hy + 3.0
	while y < hy + length:
		var f := (y - hy) / length
		var w := lerpf(6.0, 90.0, f) * (moon_size / MOON_SIZE + 0.3)
		var jx := sin(y * 0.11 + t * 1.3) * 7.0 * f + sin(y * 0.047 - t * 0.7) * 12.0 * f
		var fl := 0.5 + 0.5 * sin(y * 0.93 + t * 2.6 + sin(y * 0.31 - t) * 2.0)
		var a := pow(fl, 3.0) * 0.34 * (1.0 - f)
		if a > 0.01:
			var seg := w * (0.35 + 0.65 * fl)
			draw_rect(Rect2(moon_pos.x + jx - seg / 2.0, y, seg, 2.0 + 2.0 * f), Color(0.82, 0.9, 1.0, a))
		y += 4.0 + 5.0 * f
