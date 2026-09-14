extends Node2D
## Ayna: dokununca 45° döner. Işık için bir doğru parçası.

const LENGTH := 90.0
const TAP_RADIUS := 70.0

var step := 0  # 0..7, her adım 45°


func set_step(s: int) -> void:
	step = posmod(s, 8)
	rotation_degrees = step * 45.0
	queue_redraw()


func turn() -> void:
	set_step(step + 1)
	scale = Vector2(1.25, 1.25)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.15)


func segment() -> Array:
	var half := Vector2(LENGTH * 0.5, 0).rotated(rotation)
	return [global_position - half, global_position + half]


## Yönü aynanın doğrusuna göre yansıtır.
func reflect(d: Vector2) -> Vector2:
	var l := Vector2.RIGHT.rotated(rotation)
	return 2.0 * d.dot(l) * l - d


func _draw() -> void:
	draw_circle(Vector2.ZERO, TAP_RADIUS * 0.6, Color(1, 1, 1, 0.05))
	var half := Vector2(LENGTH * 0.5, 0)
	draw_line(-half, half, Color(0.78, 0.88, 0.98), 8.0)
	draw_line(-half + Vector2(0, 6), half + Vector2(0, 6), Color(0.3, 0.35, 0.45), 4.0)
	draw_circle(Vector2.ZERO, 7.0, Color(0.5, 0.58, 0.7))
