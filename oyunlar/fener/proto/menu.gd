extends Node2D
## Ana ekran: oyun adı + Oyna + Ayarlar. Arka plan gece denizi + ay (arka.gd).
## Ayarlar: ses efektleri + ortam sesi (dil ayarı sonraki işler).

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
	b.pressed.connect(_click)
	return b


## Ayarlar: ses efektleri + ortam sesi aç/kapa (İŞ 8). Seçim Ses autoload'unda
## saklanır (user://ayarlar.cfg). Ses yoksa satırlar yine görünür, işlevsiz kalır.
func _make_settings() -> Control:
	var panel := Panel.new()
	panel.position = Vector2(60, 460)
	panel.size = Vector2(600, 460)
	var ses := get_node_or_null("/root/Ses")
	_toggle_row(panel, 50, tr("SES_EFEKT"), ses.sfx_on if ses else true,
		func(on: bool): if ses: ses.set_sfx(on))
	_toggle_row(panel, 170, tr("SES_ORTAM"), ses.ambient_on if ses else true,
		func(on: bool): if ses: ses.set_ambient(on))
	var back := _button(tr("GERI"), 310)
	back.position.x = (600 - BTN.x) / 2.0
	back.pressed.connect(func(): panel.visible = false)
	panel.add_child(back)
	return panel


func _toggle_row(panel: Control, y: float, text: String, on: bool, changed: Callable) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 36)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = Vector2(36, y)
	l.size = Vector2(300, 96)
	panel.add_child(l)
	var b := Button.new()
	b.toggle_mode = true
	b.button_pressed = on
	b.text = tr("ACIK") if on else tr("KAPALI")
	b.position = Vector2(356, y)
	b.size = Vector2(208, 96)
	b.add_theme_font_size_override("font_size", 36)
	b.focus_mode = Control.FOCUS_NONE
	b.toggled.connect(func(v: bool):
		b.text = tr("ACIK") if v else tr("KAPALI")
		changed.call(v)
		_click())
	panel.add_child(b)


func _click() -> void:
	var ses := get_node_or_null("/root/Ses")
	if ses:
		ses.play("dugme")


func _notification(what: int) -> void:
	# Android geri tuşu: panel açıksa kapat; değilse oyundan çık
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if settings_panel.visible:
			settings_panel.visible = false
		else:
			get_tree().quit()
