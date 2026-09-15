extends Node2D
## Su katmanı (İŞ 7): nesneler suya otursun. İki örnek kullanılır:
## `reflect = true`  → her nesnenin suda titrek yansıması (dikey aynalı,
##                     soluk, yatayda kayan bozulma — shader)
## `reflect = false` → dipte genişleyen halkalar, köpük, ışının geçtiği yerde
##                     suda parıltı (toplamalı)
## Veriyi sahibinden (main.gd) okur: water_items(), paths, k, time.
## Zeminin üstünde, ışının ve nesnelerin altında.

const REFLECT_SHADER := "shader_type canvas_item;
void fragment() {
	vec2 uv = UV;
	uv.x += sin(uv.y * 38.0 + TIME * 2.4) * 0.018 + sin(uv.y * 91.0 - TIME * 3.1) * 0.006;
	vec4 c = texture(TEXTURE, uv);
	c.rgb = mix(c.rgb, vec3(0.16, 0.26, 0.42), 0.45);
	// aynalandığı için görselin ALTI su hattında: su hattından uzaklaştıkça söner
	float fade = smoothstep(0.15, 0.95, uv.y);
	COLOR = vec4(c.rgb, c.a * 0.30 * fade);
}"

var owner_main: Node2D
var reflect := false


func _ready() -> void:
	z_index = -2
	var mat: Material
	if reflect:
		var sh := Shader.new()
		sh.code = REFLECT_SHADER
		mat = ShaderMaterial.new()
		mat.shader = sh
	else:
		mat = CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat


func _draw() -> void:
	var items: Array = owner_main.water_items()
	if reflect:
		for it in items:
			_reflection(it)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	var t: float = owner_main.time
	var k: float = owner_main.k
	for i in items.size():
		var it: Dictionary = items[i]
		if it.get("ring", true):
			_rings(it["center"].x, it["wl"], it["rw"], t, i)
	_glints(owner_main.paths, t, k, owner_main.arka.horizon_screen_y())


## Su hattına (wl) göre dikey aynalanmış çizim. Döndürülmüş nesne (ayna
## plakası) için açı da aynalanır: önce nesnenin dönüşümü, sonra aynalama.
func _reflection(it: Dictionary) -> void:
	if not it.has("tex"):
		return
	var wl: float = it["wl"]
	var flip := Transform2D(Vector2(1, 0), Vector2(0, -1), Vector2(0, 2.0 * wl))
	var xf := flip * Transform2D(it.get("angle", 0.0), it["center"])
	draw_set_transform_matrix(xf)
	var r: Rect2 = it["rect"]
	if it.has("region"):
		draw_texture_rect_region(it["tex"], r, it["region"])
	else:
		draw_texture_rect(it["tex"], r, false)


## Nesne dibinde yavaşça genişleyip sönen iki yassı halka + sabit köpük hattı.
func _rings(cx: float, wl: float, rw: float, t: float, seed: int) -> void:
	_ellipse(Vector2(cx, wl), rw, rw * 0.16, Color(0.75, 0.85, 1.0, 0.16 + 0.05 * sin(t * 1.7 + seed)), 2.0, true)
	for j in 2:
		var p := fposmod(t * 0.28 + j * 0.5 + seed * 0.37, 1.0)
		var rx := rw * (0.9 + 0.8 * p)
		_ellipse(Vector2(cx, wl + 2.0), rx, rx * 0.17, Color(0.7, 0.82, 1.0, 0.22 * (1.0 - p)), 1.5, false)


func _ellipse(c: Vector2, rx: float, ry: float, col: Color, w: float, front_only: bool) -> void:
	var pts := PackedVector2Array()
	var n := 28
	var a0 := 0.0 if front_only else 0.0
	var a1 := PI if front_only else TAU
	for i in n + 1:
		var a := lerpf(a0, a1, float(i) / n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, col, w, true)


## Işının geçtiği yerde suda seyrek, sıcak, göz kırpan parıltılar (gökte yok).
func _glints(paths: Array, t: float, k: float, hy: float) -> void:
	for p in paths:
		for i in p.size() - 1:
			var a: Vector2 = p[i]
			var b: Vector2 = p[i + 1]
			var len := a.distance_to(b)
			if len < 1.0:
				continue
			var dir := (b - a) / len
			var n := dir.orthogonal()
			var s := 10.0
			while s < len:
				var h := fposmod(sin((a.x + s * dir.x) * 12.99 + (a.y + s * dir.y) * 78.23) * 43758.5, 1.0)
				var tw := pow(maxf(0.0, sin(t * (1.6 + h * 1.8) + h * 40.0)), 8.0)
				var off := (h - 0.5) * 2.0 * 26.0 * k
				var c := a + dir * s + n * off
				if tw > 0.05 and c.y > hy + 6.0:
					# suda yatay, yassı ışık pulu
					var sz := (4.0 + 6.0 * h) * k
					draw_line(c - Vector2(sz, 0), c + Vector2(sz, 0), Color(1.0, 0.82, 0.5, 0.4 * tw), 2.5)
					draw_line(c - Vector2(sz * 0.4, 0), c + Vector2(sz * 0.4, 0), Color(1.0, 0.95, 0.8, 0.5 * tw), 1.5)
				s += 16.0 + 14.0 * h
