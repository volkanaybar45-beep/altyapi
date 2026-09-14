extends Node2D
## Ayna: ışık için bir doğru parçası. Döner ayna dokununca 90° döner
## (iki çapraz arasında; kurucu kararı, kilitli). Sabit ayna dönmez; silueti
## farklı: kalın blok + vidalar, hale yok.

const LENGTH := 90.0
const TAP_RADIUS := 70.0

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
	scale = Vector2.ONE * base * 1.25
	create_tween().tween_property(self, "scale", Vector2.ONE * base, 0.15)


func segment() -> Array:
	var half := Vector2(LENGTH * 0.5 * base, 0).rotated(step * PI / 4.0)
	return [global_position - half, global_position + half]


## Yönü aynanın doğrusuna göre yansıtır.
func reflect(d: Vector2) -> Vector2:
	var l := Vector2.RIGHT.rotated(step * PI / 4.0)
	return 2.0 * d.dot(l) * l - d


func _draw() -> void:
	var half := Vector2(LENGTH * 0.5, 0)
	if fixed:
		draw_line(-half, half, Color(0.22, 0.25, 0.32), 22.0)
		draw_line(-half + Vector2(0, -8), half + Vector2(0, -8), Color(0.62, 0.68, 0.78), 5.0)
		for x in [-half.x + 10.0, half.x - 10.0]:
			draw_rect(Rect2(Vector2(x - 5, 0), Vector2(10, 10)), Color(0.1, 0.1, 0.12))
		return
	draw_circle(Vector2.ZERO, TAP_RADIUS * 0.6, Color(1, 1, 1, 0.06))
	draw_arc(Vector2.ZERO, TAP_RADIUS * 0.6, 0.0, TAU, 32, Color(1, 1, 1, 0.12), 2.0)
	draw_line(-half, half, Color(0.78, 0.88, 0.98), 8.0)
	draw_circle(Vector2.ZERO, 7.0, Color(0.5, 0.58, 0.7))
