extends Node2D
## Kuytu — Prototip A: 8x8 blok yerleştirme. Süre yok, kayıp yok.

const Board := preload("res://board.gd")
const Shapes := preload("res://shapes.gd")
const Block := preload("res://block.gd")
const Piece := preload("res://piece.gd")
const BoardView := preload("res://board_view.gd")

const CELL := 80.0
const TRAY_SCALE := 0.5
const TRAY_SLOT := Vector2(220, 200)
const TRAY_GAP := 70.0  # tahta altı ile havuz merkezi arası ek boşluk
const DRAG_LIFT := 150.0  # parmak parçayı örtmesin
const COLORS := [
	Color(0.91, 0.55, 0.45),  # mercan
	Color(0.92, 0.79, 0.50),  # kum
	Color(0.49, 0.78, 0.70),  # deniz köpüğü
	Color(0.58, 0.67, 0.87),  # lavanta mavisi
]

var board := Board.new()
var rng := RandomNumberGenerator.new()
var seed_override := -1  # prob için sabit tohum
var score := 0

var board_view: Node2D
var blocks := {}  # Vector2i -> Block
var tray: Array = [null, null, null]
var score_label: Label
var combo_label: Label

var _dragging: Piece = null
var _drag_index := -1
var _drag_touch := -1
var _combo_tween: Tween


func _ready() -> void:
	if seed_override >= 0:
		rng.seed = seed_override
	else:
		rng.randomize()
	board_view = BoardView.new()
	board_view.cell_size = CELL
	add_child(board_view)

	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color(0.85, 0.93, 0.95, 0.55))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.size = Vector2(300, 40)
	add_child(score_label)

	combo_label = Label.new()
	combo_label.add_theme_font_size_override("font_size", 52)
	combo_label.add_theme_color_override("font_color", Color(0.97, 0.95, 0.88))
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.size = Vector2(500, 70)
	combo_label.pivot_offset = combo_label.size / 2.0
	combo_label.modulate.a = 0.0
	combo_label.z_index = 20
	add_child(combo_label)

	get_viewport().size_changed.connect(_layout)
	_layout()
	_update_score()
	_refill_tray()


# --- yerleşim ---------------------------------------------------------------

func _board_origin() -> Vector2:
	var s := get_viewport_rect().size
	var total := CELL * Board.SIZE
	var content_h := total + TRAY_GAP + TRAY_SLOT.y
	return Vector2((s.x - total) / 2.0, (s.y - content_h) / 2.0)


func _slot_center(i: int) -> Vector2:
	var s := get_viewport_rect().size
	var o := _board_origin()
	var y := o.y + CELL * Board.SIZE + TRAY_GAP + TRAY_SLOT.y / 2.0
	return Vector2(s.x / 2.0 + (i - 1) * TRAY_SLOT.x, y)


func _layout() -> void:
	var s := get_viewport_rect().size
	var o := _board_origin()
	board_view.position = o
	score_label.position = Vector2(s.x - score_label.size.x - 36, maxf(24.0, o.y - 90))
	combo_label.position = Vector2(s.x / 2.0 - combo_label.size.x / 2.0, o.y - 92)
	for i in tray.size():
		if tray[i] != null and tray[i] != _dragging:
			tray[i].position = _slot_center(i)


# --- havuz -------------------------------------------------------------------

func _refill_tray() -> void:
	for i in tray.size():
		var c := rng.randi_range(0, COLORS.size() - 1)
		var p := Piece.new()
		p.setup(Shapes.random_shape(rng), c, COLORS[c], CELL)
		p.position = _slot_center(i)
		p.scale = Vector2.ONE * TRAY_SCALE * 0.6
		add_child(p)
		tray[i] = p
		create_tween().tween_property(p, "scale", Vector2.ONE * TRAY_SCALE, 0.18) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i * 0.05)


func _tray_empty() -> bool:
	for p in tray:
		if p != null:
			return false
	return true


# --- girdi -------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _dragging == null:
				if press(event.position):
					_drag_touch = event.index
		elif event.index == _drag_touch:
			release()
	elif event is InputEventScreenDrag and event.index == _drag_touch:
		move(event.position)


## Havuzdaki bir parçaya basıldıysa sürüklemeye başlar.
func press(pos: Vector2) -> bool:
	for i in tray.size():
		var p: Piece = tray[i]
		if p == null:
			continue
		if Rect2(_slot_center(i) - TRAY_SLOT / 2.0, TRAY_SLOT).has_point(pos):
			_dragging = p
			_drag_index = i
			p.z_index = 10
			create_tween().tween_property(p, "scale", Vector2.ONE, 0.08)
			move(pos)
			return true
	return false


func move(pos: Vector2) -> void:
	if _dragging == null:
		return
	_dragging.position = pos - Vector2(0, DRAG_LIFT)
	var at := _target_cell()
	if board.can_place(_dragging.shape, at):
		var cells := []
		for off in _dragging.shape:
			cells.append(at + off)
		board_view.set_ghost(cells, COLORS[_dragging.color_idx])
	else:
		board_view.clear_ghost()


func release() -> void:
	if _dragging == null:
		return
	var p := _dragging
	var i := _drag_index
	_dragging = null
	_drag_index = -1
	_drag_touch = -1
	board_view.clear_ghost()
	var at := _target_cell_for(p)
	if board.can_place(p.shape, at):
		_place(i, p, at)
	else:
		p.z_index = 0
		var t := create_tween().set_parallel()
		t.tween_property(p, "position", _slot_center(i), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(p, "scale", Vector2.ONE * TRAY_SCALE, 0.16)


func _target_cell() -> Vector2i:
	return _target_cell_for(_dragging)


## Parçanın sol üst köşesinin düştüğü hücre (ölçek 1 varsayılır — tween ortasında da kararlı).
func _target_cell_for(p: Node2D) -> Vector2i:
	var top_left: Vector2 = p.position - p.pixel_size() / 2.0 - board_view.position
	return Vector2i(roundi(top_left.x / CELL), roundi(top_left.y / CELL))


# --- hamle -------------------------------------------------------------------

func _place(i: int, p: Node2D, at: Vector2i) -> void:
	board.place(p.shape, p.color_idx, at)
	for off in p.shape:
		var cell: Vector2i = at + off
		var b := Block.new()
		b.size = CELL
		b.color = COLORS[p.color_idx]
		b.position = (Vector2(cell) + Vector2(0.5, 0.5)) * CELL
		b.scale = Vector2.ONE * 1.12
		board_view.add_child(b)
		blocks[cell] = b
		create_tween().tween_property(b, "scale", Vector2.ONE, 0.14) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	p.queue_free()
	tray[i] = null
	score += p.shape.size()

	var lines := board.full_lines()
	var n: int = lines.rows.size() + lines.cols.size()
	if n > 0:
		_animate_clear(board.clear_lines(lines), at, 0.08)
		score += 10 * n * n
		if n >= 2:
			_show_combo(n)
	_update_score()

	if _tray_empty():
		_refill_tray()
	_resolve_stuck()


## Hiçbir parça sığmıyorsa en dolu satırı temizle; sığana kadar tekrarla.
## Geçici çözüm — his prototipte ölçülecek.
func _resolve_stuck() -> int:
	var delay := 0.45
	var rows_cleared := 0
	for guard in Board.SIZE:
		if _any_fits():
			break
		var r := board.most_full_row()
		if r < 0:
			break
		_animate_clear(board.clear_row(r), Vector2i(0, r), delay)
		rows_cleared += 1
		delay += 0.3
	return rows_cleared


func _any_fits() -> bool:
	for p in tray:
		if p != null and board.fits_anywhere(p.shape):
			return true
	return false


func _animate_clear(cells: Array, from: Vector2i, delay: float) -> void:
	for cell in cells:
		var b: Node2D = blocks.get(cell)
		if b == null:
			continue
		blocks.erase(cell)
		var d := delay + 0.025 * (Vector2(cell - from).length())
		var t := create_tween().set_parallel()
		t.tween_property(b, "scale", Vector2.ZERO, 0.22).set_delay(d) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.tween_property(b, "modulate:a", 0.0, 0.22).set_delay(d)
		t.chain().tween_callback(b.queue_free)


func _show_combo(n: int) -> void:
	combo_label.text = tr("KOMBO") % n
	if _combo_tween:
		_combo_tween.kill()
	combo_label.scale = Vector2.ONE * 0.8
	combo_label.modulate.a = 0.0
	_combo_tween = create_tween()
	_combo_tween.set_parallel()
	_combo_tween.tween_property(combo_label, "modulate:a", 1.0, 0.15)
	_combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_combo_tween.chain().tween_property(combo_label, "modulate:a", 0.0, 0.4).set_delay(0.7)


func _update_score() -> void:
	score_label.text = tr("SKOR") % score
