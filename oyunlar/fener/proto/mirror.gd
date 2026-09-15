extends Node2D
## Ayna: ışık için bir doğru parçası. Döner ayna dokununca 90° döner
## (iki çapraz arasında; kurucu kararı, kilitli).
## Görsel: döner ayna = dönen plaka + dönmeyen taban + hale.
## Sabit ayna = karartılmış plaka + iki uçta taşan kıskaç, taban ve hale YOK.
## Ayırt etme silüetle (renk körlüğü), karartma sadece destek.

const PLATE := preload("res://gorseller/ayna_plaka.png")
const BASE_TEX := preload("res://gorseller/ayna_taban.png")

const LENGTH := 90.0
const TAP_RADIUS := 70.0
const PLATE_BBOX_W := 488.0  # ayna_plaka.png içindeki görünür genişlik (512'lik tuval)
const PLATE_H := 230.0       # görünür yükseklik
const KNOB_Y := 30.0         # ayna_taban.png: mil topuzunun y'si (256'lık tuval)

## Plaka görselinin yüzü render gürültüsüyle gri/grenli. Gölgelendirici yüzü
## (düşük doygunluklu açık pikseller) pürüzsüz gümüş-mavi degrade + parlak
## çapraz yansıma ile değiştirir, pirinç çerçeveyi altına çeker. Kontur aynen kalır.
## dark = 1 sabit ayna (karartma). lit 0..1: ışık alıyor mu (İŞ 7) — ışık
## alan ayna tam parlak, yüzeyde kayan parlama, çerçevede altın pırıltı;
## ışık almayan ayna sönük ve parlamasız (hangi aynanın yolda olduğu okunsun).
const PLATE_SHADER := "shader_type canvas_item;
uniform float dark = 0.0;
uniform float lit = 0.0;
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float mx = max(t.r, max(t.g, t.b));
	float sat = (mx - min(t.r, min(t.g, t.b))) / max(mx, 0.001);
	vec3 col = t.rgb;
	if (sat < 0.14 && mx > 0.42) {
		vec3 top = vec3(0.96, 0.98, 1.0);
		vec3 bot = vec3(0.60, 0.74, 0.90);
		col = mix(top, bot, smoothstep(0.30, 0.68, UV.y)) * mix(0.66, 1.0, lit);
		float sweep = fract(TIME * 0.42) * 1.9 - 0.45;
		float d = abs(UV.x - sweep + (UV.y - 0.5) * 0.9);
		col += vec3(1.0) * smoothstep(0.08, 0.0, d) * 0.75 * lit * (1.0 - dark * 0.6);
	} else if (sat > 0.2) {
		col = vec3(1.0, 0.80, 0.34) * (0.55 + 0.6 * mx) * mix(0.72, 1.05, lit);
		float s = hash(floor(UV * vec2(56.0, 28.0)) + floor(TIME * 5.0));
		col += step(0.965, s) * lit * vec3(1.0, 0.95, 0.7) * 0.9;
	}
	col = mix(col, col * vec3(0.42, 0.44, 0.52), dark);
	COLOR = vec4(col, t.a);
}"

static var _shader: Shader

var step := 0  # 0..7, her adım 45°
var fixed := false
var base := 1.0  # çizim ölçeği (8x14 ızgarada hücre küçük); fizik etkilenmez
var lit := false  # main.gd her kare yazar
var _lit_amt := 0.0
var _mat: ShaderMaterial
var _plate: Sprite2D


func _ready() -> void:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = PLATE_SHADER
	_mat = ShaderMaterial.new()  # ayna başına: lit her aynada ayrı
	_mat.shader = _shader
	_mat.set_shader_parameter("dark", 1.0 if fixed else 0.0)
	# plaka: görünür genişlik ışık doğrusunun %95'i (8x14'te çapraz komşular binmesin)
	_plate = Sprite2D.new()
	_plate.texture = PLATE
	_plate.scale = Vector2.ONE * LENGTH * 0.95 / PLATE_BBOX_W
	_plate.material = _mat
	_plate.show_behind_parent = fixed  # sabit: kıskaçlar plakanın üstünde
	add_child(_plate)


func _process(delta: float) -> void:
	var target := 1.0 if lit else 0.0
	if _lit_amt != target:
		_lit_amt = move_toward(_lit_amt, target, delta * 4.0)
		_mat.set_shader_parameter("lit", _lit_amt)


## Su hattı: taban dibinin biraz üstü (yerel, ölçek k ile çarpılır).
## Sabit aynanın tabanı yok: kıskaç dibi.
func waterline() -> float:
	if fixed:
		return (PLATE_H * LENGTH * 0.95 / PLATE_BBOX_W + 18.0) * 0.5
	return BASE_SIZE - BASE_SIZE * KNOB_Y / 256.0 - 5.0


## Yansıma için: taban ve plakanın merkeze göre dikdörtgeni (ölçek s).
func base_rect(s: float) -> Rect2:
	return Rect2(Vector2(-BASE_SIZE / 2.0, -BASE_SIZE * KNOB_Y / 256.0) * s, Vector2(BASE_SIZE, BASE_SIZE) * s)


func plate_rect(s: float) -> Rect2:
	var ps := Vector2(PLATE.get_width(), PLATE.get_height()) * LENGTH * 0.95 / PLATE_BBOX_W * s
	return Rect2(-ps / 2.0, ps)


func set_step(s: int) -> void:
	step = posmod(s, 8)
	rotation_degrees = step * 45.0
	queue_redraw()


func turn() -> void:
	if fixed:  # dönmediğini göster: kısa titreme
		var tw := create_tween()
		for a in [6.0, -6.0, 0.0]:
			tw.tween_property(self, "rotation_degrees", step * 45.0 + a, 0.05)
		return
	set_step(step + 2)
	scale = Vector2.ONE * base * 1.15
	create_tween().tween_property(self, "scale", Vector2.ONE * base, 0.15)


func segment() -> Array:
	var half := Vector2(LENGTH * 0.5 * base, 0).rotated(step * PI / 4.0)
	return [global_position - half, global_position + half]


## Yönü aynanın doğrusuna göre yansıtır.
func reflect(d: Vector2) -> Vector2:
	var l := Vector2.RIGHT.rotated(step * PI / 4.0)
	return 2.0 * d.dot(l) * l - d


## Plaka Sprite2D çocuğu çizer; burada taban + hale (döner) ya da kıskaç (sabit).
func _draw() -> void:
	var sc := LENGTH * 0.95 / PLATE_BBOX_W
	if fixed:
		var hx := PLATE_BBOX_W * sc / 2.0
		var ch := PLATE_H * sc + 18.0  # kıskaç plakadan taşar → farklı silüet
		for x in [-hx, hx - 14.0]:
			draw_rect(Rect2(Vector2(x, -ch / 2.0), Vector2(14, ch)), Color(0.12, 0.13, 0.16))
			draw_rect(Rect2(Vector2(x + 3, -ch / 2.0 + 3), Vector2(8, ch - 6)), Color(0.3, 0.32, 0.38))
		return
	# taban dönmez: düğümün dönüşünü geri al
	draw_set_transform(Vector2.ZERO, -rotation, Vector2.ONE)
	var bsz := 60.0
	draw_texture_rect(BASE_TEX, Rect2(Vector2(-bsz / 2.0, -bsz * KNOB_Y / 256.0), Vector2(bsz, bsz)), false)
	draw_arc(Vector2.ZERO, TAP_RADIUS * 0.62, 0.0, TAU, 40, Color(1.0, 0.86, 0.5, 0.30), 2.0)
