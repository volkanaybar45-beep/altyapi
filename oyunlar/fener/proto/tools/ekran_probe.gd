extends SceneTree
## Ekran görüntüsü. Argüman: -- <cikti.png> <bolum 1..9> <cozulu 0/1> [mod 45/90]
## --headless KULLANMA (GPU render gerekir). Çözüm kaba kuvvetle bulunur.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0]
	var lv := int(args[1]) - 1
	var solved := args.size() > 2 and args[2] == "1"
	var vp := SubViewport.new()
	vp.size = Vector2i(720, 1280)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var main = load("res://main.tscn").instantiate()
	vp.add_child(main)
	for _i in 3:
		await process_frame
	main.load_level(lv)
	if solved:
		var rot: Array = main.mirrors.filter(func(m): return not m.fixed)
		for k in int(pow(2, rot.size())):
			for j in rot.size():
				rot[j].set_step(3 if (k >> j) & 1 else 1)
			if main.compute_path()["hit"]:
				break
		await create_timer(1.5).timeout  # kutlama tween'i bitsin
	for _i in 10:
		await process_frame
	vp.get_texture().get_image().save_png(out)
	print("yazildi: ", out)
	quit()
