extends Node2D
## Ortak arka plan: gece denizi + ay + yavaş kayan sis. Ana ekran ve oyun
## ikisi de kullanır. En altta çizilir (z_index -10); ışın ve nesneler üstte,
## böylece ışın sisin içinden geçerken kaybolmaz.

const BG := preload("res://gorseller/arkaplan_gece_denizi.png")
const MOON := preload("res://gorseller/ay.png")
const FOG := preload("res://gorseller/sis_katmani.png")

const SIZE := Vector2(720, 1280)
const MOON_SIZE := 140.0
## sis bantları: [merkez y, yükseklik, alfa, hız px/sn]; alfa %35-50 (iş emri)
const FOG_BANDS := [
	[420.0, 300.0, 0.40, 9.0],
	[880.0, 360.0, 0.35, -6.0],
]

var moon_pos := Vector2(590, 190)
var show_moon := true  # oyunda nesnelerle çakışan yer yoksa main.gd kapatır
var t := 0.0


func _ready() -> void:
	z_index = -10


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	# zemin: görünen alanı kaplasın. keep_width: uzun telefonda (20:9) görünen
	# yükseklik 1280'den büyük, oyun üste yaslı; zemin aşağıya kadar uzar
	var vis := Vector2(SIZE.x, maxf(SIZE.y, get_viewport_rect().size.y))
	var s := maxf(vis.x / BG.get_width(), vis.y / BG.get_height())
	var bs := Vector2(BG.get_width(), BG.get_height()) * s
	draw_texture_rect(BG, Rect2(Vector2((vis.x - bs.x) / 2.0, 0), bs), false)
	if show_moon:
		draw_texture_rect(MOON, Rect2(moon_pos - Vector2.ONE * MOON_SIZE / 2.0, Vector2.ONE * MOON_SIZE), false)
	# sis: yatay döşenir, kayar (görsel kenarları eşleşik)
	for band in FOG_BANDS:
		var h: float = band[1]
		var w: float = FOG.get_width() * h / FOG.get_height()
		var off: float = fposmod(t * band[3], w)
		var y: float = band[0] - h / 2.0
		var x := -off
		while x < SIZE.x:
			draw_texture_rect(FOG, Rect2(x, y, w, h), false, Color(1, 1, 1, band[2]))
			x += w
