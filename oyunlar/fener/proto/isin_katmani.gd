extends Node2D
## Işın çizimi. İki örnek kullanılır: `additive = true` hale (toplamalı
## karışım), `false` çekirdek (#FFE7A3, normal karışım — kontrast ölçümü
## buna yapılır). Veriyi sahibinden (main.gd) okur: paths, glow, k, time.
##
## Görünüş (İŞ 6): ince parlak çekirdek + geniş yumuşak hale (çekirdek ≤
## halenin 1/3'ü) · her kırılma noktasında küçük parlak düğüm · uzunluk
## boyunca hafif sönümlenme · sis bantlarından geçerken hale hafif yayılır.

const Arka := preload("res://arka.gd")

const CORE := Color("#FFE7A3")
const CORE_W := 10.0    # çekirdek (× k)
const CORE_MIN := 6.5   # İŞ 12: çekirdek tabanı (px) — mesafeden BAĞIMSIZ, uzakta ip gibi incelmez
const HALO_W := 48.0    # en dış hale (× k); en az çekirdeğin 3.2 katı
const HALO_MIN_X := 3.2
const FADE_LEN := 1800.0  # bu kadar yolda hale %65'e iner; ÇEKİRDEK SÖNMEZ (İŞ 12)


## Çekirdek kalınlığı (px): hücreye göre, tabanın altına inmez.
func core_px(k: float) -> float:
	return maxf(CORE_MIN, CORE_W * k)
const CHUNK := 24.0       # sönüm/sis için parça boyu (px)

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
	# kolların hepsi fenerden başlar; bölücüden çıkan kol yolu kaldığı yerden sayar
	var start_d := {}
	for p in paths:
		var d0: float = start_d.get(p[0], 0.0)
		var d := d0
		for i in p.size() - 1:
			d += p[i].distance_to(p[i + 1])
		start_d[p[p.size() - 1]] = d
		if additive:
			_halo(p, d0, k, pulse)
		else:
			_core(p, d0, k)
		_nodes(p, d0, k)
	if glow > 0.0:
		for p in paths:
			_draw_glow(p, glow, k)


## Yol boyunca parça parça: (başlangıç, bitiş, parçanın yoldaki uzaklığı).
func _chunks(p: PackedVector2Array, d0: float) -> Array:
	var out: Array = []
	var d := d0
	for i in p.size() - 1:
		var a := p[i]
		var b := p[i + 1]
		if a.distance_to(b) < 1.0:
			continue  # sıfır boylu parça dörtgeni bozar (üçgenleme hatası)
		var n := maxi(1, ceili(a.distance_to(b) / CHUNK))
		for j in n:
			var s := a.lerp(b, float(j) / n)
			var e := a.lerp(b, float(j + 1) / n)
			out.append([s, e, d])
			d += s.distance_to(e)
	return out


func _fade(d: float, lo: float) -> float:
	return lerpf(1.0, lo, clampf(d / FADE_LEN, 0.0, 1.0))


## Sis bandının içinde 0..1 (bant merkezinde 1). Bantlar arka.gd'den.
func _fog(y: float) -> float:
	var f := 0.0
	for band in Arka.FOG_BANDS:
		f = maxf(f, 1.0 - clampf(absf(y - band[0]) / (band[1] * 0.5), 0.0, 1.0))
	return smoothstep(0.0, 1.0, f)


## Hale: üç kat, dörtgen parçalar (toplamalı karışımda üst üste binmesin diye
## daire/uç kapağı yok; köşeyi düğüm örter).
func _halo(p: PackedVector2Array, d0: float, k: float, pulse: float) -> void:
	# beş kat: kenarı basamaklı değil yumuşak görünsün
	var layers := [[HALO_W, Color(1.0, 0.76, 0.40, 0.035 + 0.015 * pulse)],
		[HALO_W * 0.8, Color(1.0, 0.80, 0.46, 0.045)],
		[HALO_W * 0.6, Color(1.0, 0.85, 0.55, 0.06)],
		[HALO_W * 0.44, Color(1.0, 0.89, 0.64, 0.08)],
		[HALO_W * 0.3, Color(1.0, 0.93, 0.72, 0.12)]]
	for c in _chunks(p, d0):
		var a: Vector2 = c[0]
		var b: Vector2 = c[1]
		var f := _fade(c[2], 0.65)
		var fog := _fog((a.y + b.y) * 0.5)
		var n := (b - a).normalized().orthogonal()
		for L in layers:
			var w: float = L[0] * k * (1.0 + 0.45 * fog) * 0.5
			var col: Color = L[1]
			col.a *= f * (1.0 - 0.25 * fog)  # yayılınca seyrelir: toplam ışık aynı kalsın
			draw_colored_polygon(PackedVector2Array([a + n * w, b + n * w, b - n * w, a - n * w]), col)


func _core(p: PackedVector2Array, d0: float, k: float) -> void:
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var hot := PackedColorArray()
	for c in _chunks(p, d0):
		pts.append(c[0])
		var f := _fade(c[2], 0.8)
		cols.append(Color(CORE.r, CORE.g, CORE.b, f))
		hot.append(Color(1, 1, 0.96, f))
	pts.append(p[p.size() - 1])
	cols.append(cols[cols.size() - 1])
	hot.append(hot[hot.size() - 1])
	# çok hafif nefes (flicker): kalınlık ±%7
	var tm: float = owner_main.time
	var br := 1.0 + 0.07 * sin(tm * 7.3) * sin(tm * 3.1 + 1.0)
	draw_polyline_colors(pts, cols, maxf(6.0, CORE_W * k * br), true)
	draw_polyline_colors(pts, hot, maxf(2.5, CORE_W * 0.35 * k * br), true)


## Kırılma noktalarında (ayna, bölücü) küçük parlak düğüm; köşe kare kalmaz.
func _nodes(p: PackedVector2Array, d0: float, k: float) -> void:
	var d := d0
	for i in range(1, p.size()):
		d += p[i - 1].distance_to(p[i])
		if i == p.size() - 1:
			break  # kolun sonu: tekne/kaya/kenar, düğüm yok
		var f := _fade(d, 0.6)
		if additive:
			draw_circle(p[i], 22.0 * k, Color(1.0, 0.85, 0.55, 0.10 * f))
			draw_circle(p[i], 13.0 * k, Color(1.0, 0.92, 0.72, 0.22 * f))
			# küçük kıvılcım: dönen, nabız atan dört kollu yıldız
			var tm: float = owner_main.time
			var ph := tm * 2.2 + i * 1.7
			var len := (16.0 + 7.0 * sin(ph * 1.6)) * k
			for j in 2:
				var arm := Vector2.RIGHT.rotated(ph * 0.5 + j * PI / 2.0) * len
				draw_line(p[i] - arm, p[i] + arm, Color(1.0, 0.95, 0.8, 0.45 * f), 2.0)
		else:
			draw_circle(p[i], 7.0 * k, Color(1, 1, 0.96, f))


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
		if additive and p[i].distance_to(b) >= 1.0:
			var n := (b - p[i]).normalized().orthogonal() * 16.0 * k
			draw_colored_polygon(PackedVector2Array([p[i] + n, b + n, b - n, p[i] - n]), Color(1.0, 0.9, 0.6, 0.22))
		else:
			draw_line(p[i], b, Color(1, 1, 0.97), CORE_W * 0.5 * k)
		left -= seg_len
