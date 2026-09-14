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

var step := 0  # 0..7, her adım 45°
var fixed := false
var base := 1.0  # çizim ölçeği (8x14 ızgarada hücre küçük); fizik etkilenmez


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


func _draw() -> void:
	# plaka: görünür genişliği ışık doğrusundan biraz uzun
	var sc := LENGTH * 1.1 / PLATE_BBOX_W
	var ps := Vector2(PLATE.get_width(), PLATE.get_height()) * sc
	if fixed:
		draw_texture_rect(PLATE, Rect2(-ps / 2.0, ps), false, Color(0.42, 0.44, 0.52))
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
	draw_arc(Vector2.ZERO, TAP_RADIUS * 0.62, 0.0, TAU, 40, Color(0.85, 0.93, 1.0, 0.22), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect(PLATE, Rect2(-ps / 2.0, ps), false)
