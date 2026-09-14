extends SceneTree
## Ekran görüntüsü. Argüman: -- <cikti.png> <bolum 1..3> <cozulu 0/1>
## --headless KULLANMA (GPU render gerekir).

const Levels := preload("res://levels.gd")


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
		var sol: Array = Levels.ALL[lv]["cozum"]
		for j in sol.size():
			main.mirrors[j].set_step(sol[j])
		await create_timer(1.5).timeout  # kutlama tween'i bitsin
	for _i in 10:
		await process_frame
	vp.get_texture().get_image().save_png(out)
	print("yazildi: ", out)
	quit()
