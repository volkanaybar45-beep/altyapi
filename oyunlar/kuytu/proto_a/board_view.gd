extends Node2D
## Tahta zemini + boş hücreler + yerleştirme gölgesi. Bloklar bunun çocuğu.

const SIZE := 8
const PANEL_PAD := 12.0

var cell_size := 80.0
var panel_color := Color(0.14, 0.27, 0.33)
var empty_color := Color(0.17, 0.32, 0.39)

var _ghost_cells: Array = []
var _ghost_color := Color.WHITE
var _panel := StyleBoxFlat.new()
var _empty := StyleBoxFlat.new()


func _init() -> void:
	_panel.set_corner_radius_all(22)
	_empty.set_corner_radius_all(12)


func set_ghost(cells: Array, color: Color) -> void:
	_ghost_cells = cells
	_ghost_color = color
	queue_redraw()


func clear_ghost() -> void:
	if _ghost_cells.is_empty():
		return
	_ghost_cells = []
	queue_redraw()


func _draw() -> void:
	var total := cell_size * SIZE
	_panel.bg_color = panel_color
	draw_style_box(_panel, Rect2(-PANEL_PAD, -PANEL_PAD, total + PANEL_PAD * 2, total + PANEL_PAD * 2))
	var s := cell_size - 5.0
	_empty.bg_color = empty_color
	for r in SIZE:
		for c in SIZE:
			var center := (Vector2(c, r) + Vector2(0.5, 0.5)) * cell_size
			draw_style_box(_empty, Rect2(center - Vector2(s, s) / 2.0, Vector2(s, s)))
	if _ghost_cells.is_empty():
		return
	_empty.bg_color = Color(_ghost_color, 0.38)
	for cell in _ghost_cells:
		var center := (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size
		draw_style_box(_empty, Rect2(center - Vector2(s, s) / 2.0, Vector2(s, s)))
