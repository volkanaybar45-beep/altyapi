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
	COLOR = vec4(c.rgb, c.a * 0.35 * fade);  // G3: alfa 0.35, aşağı doğru söner
}"

const REFL_H := 0.6  # G3: yansıma yüksekliği gövdenin %60'ı

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
		if it.has("wake") and it["wake"].length() > 0.02:
			_wake(Vector2(it["center"].x, it["wl"]), it["wake"], it["rw"], t)
	_glints(owner_main.paths, t, k, owner_main.arka.horizon_y())


## Su noktasına (wl) göre dikey aynalanmış çizim (G3): dikey kayma 0, boy
## gövdenin %60'ı. Yalpalayan tekne için açı da aynalanır: önce nesnenin
## dönüşümü, sonra aynalama. y' = wl - 0.6·(y - wl)
func _reflection(it: Dictionary) -> void:
	if not it.has("tex"):
		return
	var wl: float = it["wl"]
	var flip := Transform2D(Vector2(1, 0), Vector2(0, -REFL_H), Vector2(0, (1.0 + REFL_H) * wl))
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


## Karşılık veren teknenin köpük izi. Sahne yandan görüldüğü için iz su
## hattında yatay: kıçtan (tekne sağa bakar, kıç solda) geriye uzanan titrek
## çizgiler + pruvada küçük dalga. back: süzülme miktarı (uzunluğu 0..1).
func _wake(c: Vector2, back: Vector2, rw: float, t: float) -> void:
	var s := back.length()
	var stern := c.x - rw * 0.85
	for i in 3:
		var y := c.y + 1.0 + i * 3.5
		var len := rw * (0.5 + 0.9 * s) * (1.0 - i * 0.2)
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for q in 9:
			var f := q / 8.0
			pts.append(Vector2(stern - len * f, y + sin(t * 4.0 + f * 7.0 + i) * 1.2))
			cols.append(Color(0.85, 0.92, 1.0, 0.35 * s * (1.0 - f)))
		draw_polyline_colors(pts, cols, 2.0, true)
	var bow := c.x + rw * 0.85
	draw_arc(Vector2(bow, c.y + 2.0), rw * 0.18 * (0.8 + 0.2 * sin(t * 5.0)), PI * 0.15, PI * 0.85, 8,
		Color(0.85, 0.92, 1.0, 0.3 * s), 2.0, true)


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
