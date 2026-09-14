extends Node2D
## Havuzdaki / sürüklenen parça. Düğüm konumu = parçanın merkezi.

const Block := preload("res://block.gd")
const Shapes := preload("res://shapes.gd")

var shape: Array = []
var color_idx := 0
var cell_size := 80.0
var _bounds := Vector2i.ONE


func setup(p_shape: Array, p_color_idx: int, color: Color, p_cell_size: float) -> void:
	shape = p_shape
	color_idx = p_color_idx
	cell_size = p_cell_size
	_bounds = Shapes.bounds(shape)
	var half := pixel_size() / 2.0
	for off in shape:
		var b := Block.new()
		b.size = cell_size
		b.color = color
		b.position = (Vector2(off) + Vector2(0.5, 0.5)) * cell_size - half
		add_child(b)


## Ölçeksiz piksel boyutu.
func pixel_size() -> Vector2:
	return Vector2(_bounds) * cell_size
