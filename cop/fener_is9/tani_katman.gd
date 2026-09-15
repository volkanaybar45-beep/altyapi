extends SceneTree
## Geçici tanı (İŞ 9): tekne fenerindeki koyu diskin hangi katmandan geldiği.
## -- <cikti_onek> ; bölüm 2 çözülür, her katman sırayla gizlenip kare alınır.


func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	var vp := SubViewport.new()
	vp.size = Vector2i(720, 1600)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var main = load("res://main.tscn").instantiate()
	main.auto_advance = false
	vp.add_child(main)
	for _i in 3:
		await process_frame
	main.load_level(1)
	var rot: Array = main.mirrors.filter(func(m): return not m.fixed)
	for k in int(pow(2, rot.size())):
		for j in rot.size():
			rot[j].set_step(3 if (k >> j) & 1 else 1)
		if main.compute_path()["hit"]:
			break
	await create_timer(1.3).timeout
	var layers := {"hepsi": null, "glow": main.glow_layer, "isin0": main.beam_layers[0],
		"isin1": main.beam_layers[1], "su0": main.water_layers[0], "su1": main.water_layers[1]}
	for name in layers:
		var n = layers[name]
		if n:
			n.visible = false
		for _i in 3:
			await process_frame
		var img := vp.get_texture().get_image()
		img.get_region(Rect2i(540, 1220, 180, 160)).save_png("%s_%s.png" % [out, name])
		if n:
			n.visible = true
	quit()
