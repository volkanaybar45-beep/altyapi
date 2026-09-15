extends Node2D
## Ayna: ışık için bir doğru parçası. Döner ayna dokununca 90° döner
## (iki çapraz arasında; kurucu kararı, kilitli).
##
## İŞ 10 görünüş: pirinç çerçeveli yuvarlak ayna, düz tepeli taban kayasının
## üstünde. Sprite'lar diyorama kamerasıyla (yaw -40°, pitch 30°) render edildi
## (G1); düğüm DÖNDÜRÜLMEZ, adım başına ayrı sprite gösterilir. 4 yön render'la
## doğrulandı: diskin mil ekseni ekranda 135.2° / 45.1° / 135.1° / 45.0°
## (adım 1 "\" · 3 "/" · 5 "\" arka yüz · 7 "/" arka yüz).
## Sabit ayna: aynı sprite karartılmış + diskin üstünde X biçimli demir kilit
## (silüetten ayrılır, renk körlüğü).
##
## Yerel ölçü: 1 hücre = 90 birim (düğüm ölçeği k = hücre/90). Su noktası
## hücre merkezinin WP_Y altında; taban kayasının alt ortası oraya oturur (G3).

const TEX := [preload("res://gorseller/ayna_0.png"), preload("res://gorseller/ayna_1.png"),
	preload("res://gorseller/ayna_2.png"), preload("res://gorseller/ayna_3.png")]
const ISLET := preload("res://gorseller/kaya_taban.png")

const LENGTH := 90.0
const TAP_RADIUS := 70.0
const WP_Y := 54.0          # su noktası: hücre merkezi + 0.6 hücre
## Ölçüler (512'lik render pikseli, tools/is10_varlik.py ile ölçüldü)
const ISLET_W := 0.9        # taban kayası genişliği (hücre); görünür genişlik 483 px
const ISLET_CUT := 260.0    # bu satırın altı suda (çizilmez)
const ISLET_TOP := 118.0    # düz tepenin orta noktası
const ISLET_AX := 255.5
const MIRROR_H := 0.72      # ayna boyu (hücre); görünür boy 483 px, alt 497
const MIRROR_AX := [263.0, 263.0, 261.0, 256.0]  # sprite alt orta x

const PLATE_SHADER := "shader_type canvas_item;
uniform float dark = 0.0;
uniform float lit = 0.0;
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float mx = max(t.r, max(t.g, t.b));
	float sat = (mx - min(t.r, min(t.g, t.b))) / max(mx, 0.001);
	vec3 col = t.rgb * mix(0.62, 1.05, lit);
	if (sat < 0.16 && mx > 0.5) {  // gümüş yüz: ışık alınca soldan sağa kayan parlama
		float sweep = fract(TIME * 0.42) * 1.9 - 0.45;
		float d = abs(UV.x - sweep + (UV.y - 0.35) * 0.6);
		col += vec3(1.0) * smoothstep(0.06, 0.0, d) * 0.7 * lit * (1.0 - dark * 0.6);
	} else if (sat > 0.35 && t.r > t.b) {  // pirinç: altın pırıltı
		float s = hash(floor(UV * vec2(64.0, 64.0)) + floor(TIME * 5.0));
		col += step(0.975, s) * lit * vec3(1.0, 0.92, 0.65) * 0.9;
	}
	col = mix(col, col * vec3(0.42, 0.44, 0.52), dark);
	COLOR = vec4(col, t.a);
}"

static var _shader: Shader

var step := 0  # 0..7, her adım 45°
var fixed := false
var base := 1.0  # çizim ölçeği k (hücre/90); fizik etkilenmez
var row_scale := 1.0  # G2: üst satır 0.85, alt satır 1.0
var lit := false  # main.gd her kare yazar
var _lit_amt := 0.0
var _mat: ShaderMaterial
var _vis: Node2D  # ayna sprite'ı (gölgelendiricili); taban kayası bu düğümde


func _ready() -> void:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = PLATE_SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = _shader
	_mat.set_shader_parameter("dark", 1.0 if fixed else 0.0)
	_vis = Node2D.new()
	_vis.material = _mat
	_vis.draw.connect(_draw_mirror)
	add_child(_vis)


func _process(delta: float) -> void:
	var target := 1.0 if lit else 0.0
	if _lit_amt != target:
		_lit_amt = move_toward(_lit_amt, target, delta * 4.0)
		_mat.set_shader_parameter("lit", _lit_amt)


func sprite_index() -> int:
	return ((step - 1) / 2) % 4  # adım 1,3,5,7 → 0,1,2,3


## Su hattı (yerel y, ölçek k ile çarpılır).
func waterline() -> float:
	return WP_Y


func _islet_f() -> float:
	return ISLET_W * 90.0 * row_scale / 483.0


func _mirror_f() -> float:
	return MIRROR_H * 90.0 * row_scale / 483.0


## Çizim parçaları (yerel): [{tex, rect, region?}] — yansıma da bunları kullanır.
func parts() -> Array:
	var fi := _islet_f()
	var wp := Vector2(0, WP_Y)
	var out: Array = [{"tex": ISLET, "rect": Rect2(wp - Vector2(ISLET_AX, ISLET_CUT) * fi, Vector2(512, ISLET_CUT) * fi),
		"region": Rect2(0, 0, 512, ISLET_CUT)}]
	var top := wp - Vector2(0, (ISLET_CUT - ISLET_TOP) * fi)
	var fm := _mirror_f()
	var i := sprite_index()
	out.append({"tex": TEX[i], "rect": Rect2(top - Vector2(MIRROR_AX[i], 497.0) * fm, Vector2(512, 512) * fm)})
	return out


func set_step(s: int) -> void:
	step = posmod(s, 8)
	queue_redraw()
	if _vis:
		_vis.queue_redraw()


func turn() -> void:
	if fixed:  # dönmediğini göster: kısa titreme
		var tw := create_tween()
		for a in [4.0, -4.0, 0.0]:
			tw.tween_property(self, "rotation_degrees", a, 0.05)
		return
	set_step(step + 2)
	scale = Vector2.ONE * base * 1.12
	create_tween().tween_property(self, "scale", Vector2.ONE * base, 0.15)


func segment() -> Array:
	var half := Vector2(LENGTH * 0.5 * base, 0).rotated(step * PI / 4.0)
	return [global_position - half, global_position + half]


## Yönü aynanın doğrusuna göre yansıtır.
func reflect(d: Vector2) -> Vector2:
	var l := Vector2.RIGHT.rotated(step * PI / 4.0)
	return 2.0 * d.dot(l) * l - d


## Taban kayası (gölgelendiricisiz: yosun altına dönmesin).
func _draw() -> void:
	var p: Dictionary = parts()[0]
	draw_texture_rect_region(p["tex"], p["rect"], p["region"])


func _draw_mirror() -> void:
	var p: Dictionary = parts()[1]
	_vis.draw_texture_rect(p["tex"], p["rect"], false)
	var r: Rect2 = p["rect"]
	var c := r.position + Vector2(r.size.x * 0.5, r.size.y * 0.3)  # disk merkezi
	# yön çizgisi: diskin mil ekseni (render'da 135°/45° ölçüldü) boyunca ince
	# altın çizgi — küçük ekranda "\" / "/" okunsun (bulmaca okunurluğu, G kuralı)
	var e := r.size.x * 0.2
	var ax := Vector2(e, e) if sprite_index() % 2 == 0 else Vector2(e, -e)
	_vis.draw_line(c - ax, c + ax, Color(1.0, 0.86, 0.45, 0.55 + 0.4 * _lit_amt), 2.5, true)
	if fixed:  # X kilit: diskin ortasından iki kalın demir bant
		for d in [Vector2(e, e), Vector2(e, -e)]:
			_vis.draw_line(c - d, c + d, Color(0.1, 0.1, 0.12), 7.0)
			_vis.draw_line(c - d, c + d, Color(0.35, 0.36, 0.4), 3.0)
