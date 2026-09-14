extends Node2D
## Tek kare. Merkezden çizilir ki ölçek tween'i ortadan büyüsün/küçülsün.

const GAP := 5.0
const RADIUS := 12

var size := 80.0:
	set(v):
		size = v
		queue_redraw()
var color := Color.WHITE:
	set(v):
		color = v
		_style.bg_color = v
		queue_redraw()

var _style := StyleBoxFlat.new()


func _init() -> void:
	_style.set_corner_radius_all(RADIUS)
	_style.bg_color = color


func _draw() -> void:
	var s := size - GAP
	draw_style_box(_style, Rect2(-s / 2.0, -s / 2.0, s, s))
