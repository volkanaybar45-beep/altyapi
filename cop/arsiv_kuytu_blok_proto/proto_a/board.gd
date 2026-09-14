extends RefCounted
## Izgara mantığı — görselden bağımsız, headless test edilebilir.
## Koordinat: Vector2i(x = sütun, y = satır).

const SIZE := 8
const EMPTY := -1

var cells: Array = []  # cells[satır][sütun] = renk indeksi ya da EMPTY


func _init() -> void:
	reset()


func reset() -> void:
	cells = []
	for r in SIZE:
		var row := []
		row.resize(SIZE)
		row.fill(EMPTY)
		cells.append(row)


func get_cell(cell: Vector2i) -> int:
	return cells[cell.y][cell.x]


func can_place(shape: Array, at: Vector2i) -> bool:
	for off in shape:
		var p: Vector2i = at + off
		if p.x < 0 or p.x >= SIZE or p.y < 0 or p.y >= SIZE:
			return false
		if cells[p.y][p.x] != EMPTY:
			return false
	return true


func fits_anywhere(shape: Array) -> bool:
	for r in SIZE:
		for c in SIZE:
			if can_place(shape, Vector2i(c, r)):
				return true
	return false


func place(shape: Array, color: int, at: Vector2i) -> void:
	assert(can_place(shape, at))
	for off in shape:
		var p: Vector2i = at + off
		cells[p.y][p.x] = color


## Dolu satır ve sütunları döndürür: {"rows": [...], "cols": [...]}
func full_lines() -> Dictionary:
	var rows := []
	var cols := []
	for i in SIZE:
		var row_full := true
		var col_full := true
		for j in SIZE:
			if cells[i][j] == EMPTY:
				row_full = false
			if cells[j][i] == EMPTY:
				col_full = false
		if row_full:
			rows.append(i)
		if col_full:
			cols.append(i)
	return {"rows": rows, "cols": cols}


## Verilen satır/sütunları boşaltır, boşalan hücreleri (tekrarsız) döndürür.
func clear_lines(lines: Dictionary) -> Array:
	var cleared := {}
	for r in lines.get("rows", []):
		for c in SIZE:
			cleared[Vector2i(c, r)] = true
	for c in lines.get("cols", []):
		for r in SIZE:
			cleared[Vector2i(c, r)] = true
	for cell in cleared:
		cells[cell.y][cell.x] = EMPTY
	return cleared.keys()


func filled_in_row(r: int) -> int:
	var n := 0
	for c in SIZE:
		if cells[r][c] != EMPTY:
			n += 1
	return n


## En dolu satır (eşitlikte en alttaki). Tahta boşsa -1.
func most_full_row() -> int:
	var best := -1
	var best_n := 0
	for r in SIZE:
		var n := filled_in_row(r)
		if n > 0 and n >= best_n:
			best = r
			best_n = n
	return best


## Satırdaki dolu hücreleri boşaltır, boşalanları döndürür.
func clear_row(r: int) -> Array:
	var out := []
	for c in SIZE:
		if cells[r][c] != EMPTY:
			cells[r][c] = EMPTY
			out.append(Vector2i(c, r))
	return out
