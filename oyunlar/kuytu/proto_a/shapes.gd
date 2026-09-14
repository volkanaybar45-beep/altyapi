extends RefCounted
## Parça şekilleri (tetris benzeri, en fazla 4 hücre). Vector2i(x = sütun, y = satır).

const BASES := [
	[Vector2i(0, 0)],
	[Vector2i(0, 0), Vector2i(1, 0)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)],
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)],
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(0, 2)],
]


static func rotated(shape: Array) -> Array:
	var out := []
	for p in shape:
		out.append(Vector2i(-p.y, p.x))
	return normalized(out)


static func normalized(shape: Array) -> Array:
	var min_x := 99
	var min_y := 99
	for p in shape:
		min_x = mini(min_x, p.x)
		min_y = mini(min_y, p.y)
	var out := []
	for p in shape:
		out.append(Vector2i(p.x - min_x, p.y - min_y))
	return out


static func bounds(shape: Array) -> Vector2i:
	var b := Vector2i.ZERO
	for p in shape:
		b.x = maxi(b.x, p.x + 1)
		b.y = maxi(b.y, p.y + 1)
	return b


static func random_shape(rng: RandomNumberGenerator) -> Array:
	var s: Array = BASES[rng.randi_range(0, BASES.size() - 1)]
	for i in rng.randi_range(0, 3):
		s = rotated(s)
	return s
