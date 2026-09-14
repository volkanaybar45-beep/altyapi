extends Node2D
## Ana ekran: oyun adı + Oyna + Ayarlar. Arka plan gece denizi + ay (arka.gd).
## Ayarlar şimdilik boş panel (ses/dil ayarı sonraki işler).

const Arka := preload("res://arka.gd")

const SIZE := Vector2(720, 1280)
const BTN := Vector2(360, 110)

var settings_panel: Control


func _ready() -> void:
	var arka := Arka.new()
	arka.moon_pos = Vector2(540, 250)
	add_child(arka)

	var ui := Control.new()
	ui.size = SIZE
	add_child(ui)

	var title := Label.new()
	title.text = tr("OYUN_ADI")
	title.add_theme_font_size_override("font_size", 76)
	title.add_theme_color_override("font_color", Color("#FFE7A3"))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_y", 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 400)
	title.size = Vector2(SIZE.x, 110)
	ui.add_child(title)

	var play := _button(tr("OYNA"), 700)
	play.pressed.connect(func(): get_tree().change_scene_to_file("res://main.tscn"))
	ui.add_child(play)
	var settings := _button(tr("AYARLAR"), 840)
	settings.pressed.connect(func(): settings_panel.visible = true)
	ui.add_child(settings)

	settings_panel = _make_settings()
	settings_panel.visible = false
	ui.add_child(settings_panel)


func _button(text: String, y: float) -> Button:
	var b := Button.new()
	b.text = text
	b.position = Vector2((SIZE.x - BTN.x) / 2.0, y)
	b.size = BTN
	b.add_theme_font_size_override("font_size", 44)
	b.focus_mode = Control.FOCUS_NONE
	return b


func _make_settings() -> Control:
	var panel := Panel.new()
	panel.position = Vector2(80, 480)
	panel.size = Vector2(560, 420)
	var msg := Label.new()
	msg.text = tr("AYAR_YOK")
	msg.add_theme_font_size_override("font_size", 38)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.position = Vector2(0, 90)
	msg.size = Vector2(560, 60)
	panel.add_child(msg)
	var back := _button(tr("GERI"), 250)
	back.position.x = (560 - BTN.x) / 2.0
	back.pressed.connect(func(): panel.visible = false)
	panel.add_child(back)
	return panel


func _notification(what: int) -> void:
	# Android geri tuşu: panel açıksa kapat; değilse oyundan çık
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if settings_panel.visible:
			settings_panel.visible = false
		else:
			get_tree().quit()
