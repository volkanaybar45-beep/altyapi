extends SceneTree
## Kare hızı ölçümü (İŞ 7). Argüman: -- <bolum 1..> [sn] [su 0/1]
##   su 0: su katmanları (yansıma/halka/parıltı) kapalı — karşılaştırma için
## Pencere açılır, dikey eşitleme kapatılır; ortalama kare hızı ve süresi
## yazılır. PC ölçümüdür, telefonu temsil etmez.
## --headless KULLANMA.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var lv := int(args[0]) - 1 if args.size() > 0 else 0
	var secs := float(args[1]) if args.size() > 1 else 5.0
	var water := not (args.size() > 2 and args[2] == "0")
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.size = Vector2i(720, 1600)
	var main = load("res://main.tscn").instantiate()
	main.auto_advance = false
	root.add_child(main)
	for _i in 3:
		await process_frame
	main.load_level(lv)
	for m in main.water_layers:
		m.visible = water
	for _i in 30:
		await process_frame
	var frames := 0
	var t0 := Time.get_ticks_usec()
	while Time.get_ticks_usec() - t0 < int(secs * 1e6):
		await process_frame
		frames += 1
	var dt := (Time.get_ticks_usec() - t0) / 1e6
	print("bolum %d su=%s: %.0f fps · kare %.2f ms" % [lv + 1, water, frames / dt, dt * 1000.0 / frames])
	quit()
