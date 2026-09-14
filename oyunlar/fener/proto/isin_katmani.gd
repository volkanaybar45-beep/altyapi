extends Node2D
## Işın çizimi. İki örnek kullanılır: `additive = true` parlama (toplamalı
## karışım), `false` çekirdek (#FFE7A3, ≥16 px, normal karışım — kontrast
## ölçümü buna yapılır). Veriyi sahibinden (main.gd) okur: paths, glow, k.

const CORE := Color("#FFE7A3")
const CORE_W := 16.0

var owner_main: Node2D
var additive := false


func _ready() -> void:
	if additive:
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = m
	# nesnelerin ALTINDA: ayna plakasının açısı, kule ve tekne ışının üstünde okunsun
	z_index = -1


func _draw() -> void:
	var paths: Array = owner_main.paths
	var glow: float = owner_main.glow
	var k: float = owner_main.k
	var pulse := 0.5 + 0.5 * sin(owner_main.time * 3.0)
	for p in paths:
		if additive:
			# dar tutuldu: komşu şeritte paralel iki kol tek banda karışmasın
			_line(p, Color(1.0, 0.8, 0.45, 0.16 + 0.04 * pulse), 44.0 * k)
			_line(p, Color(1.0, 0.88, 0.6, 0.30), 26.0 * k)
		else:
			_line(p, CORE, CORE_W)
			_line(p, Color(1, 1, 0.95), 5.0)
	if glow > 0.0:
		for p in paths:
			_draw_glow(p, glow, k)


func _line(p: PackedVector2Array, c: Color, w: float) -> void:
	for i in p.size() - 1:
		draw_line(p[i], p[i + 1], c, w)
	for i in range(1, p.size() - 1):  # köşeler yuvarlak (aynada kırılma)
		draw_circle(p[i], w / 2.0, c)


## Kutlamada parlama her kolda başından sonuna doğru yayılır.
func _draw_glow(p: PackedVector2Array, glow: float, k: float) -> void:
	var total := 0.0
	for i in p.size() - 1:
		total += p[i].distance_to(p[i + 1])
	var left := total * glow
	for i in p.size() - 1:
		var seg_len := p[i].distance_to(p[i + 1])
		if left <= 0.0:
			break
		var b := p[i + 1] if left >= seg_len else p[i].lerp(p[i + 1], left / seg_len)
		if additive:
			draw_line(p[i], b, Color(1.0, 0.9, 0.6, 0.35), 40.0 * k)
		else:
			draw_line(p[i], b, Color(1, 1, 0.97), CORE_W * 0.6)
		left -= seg_len
