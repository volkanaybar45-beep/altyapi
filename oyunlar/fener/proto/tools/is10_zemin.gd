extends SceneTree
## K6 için saf deniz karesi: bölüm yüklenir, nesneler/ışın/yansıma/parıltı
## gizlenir; zemin (gök, ay, deniz shader, ay yolu, sis, diyorama) kalır.
## Argüman: -- <cikti_onek> <bolum 1..> <yukseklik> [kare 3] [aralik 0.7]
## --headless KULLANMA (GPU render gerekir).


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var out: String = a[0]
	var lv := int(a[1]) - 1
	var h := int(a[2])
	var frames := int(a[3]) if a.size() > 3 else 3
	var gap := float(a[4]) if a.size() > 4 else 0.7
	var vp := SubViewport.new()
	vp.size = Vector2i(720, h)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var main = load("res://main.tscn").instantiate()
	main.auto_advance = false
	vp.add_child(main)
	for _i in 3:
		await process_frame
	main.load_level(lv)
	for n in [main.objects, main.glow_layer] + main.beam_layers + main.water_layers:
		n.visible = false
	for l in [main.title_label, main.info_label, main.skip_button]:
		l.visible = false
	for f in frames:
		await create_timer(gap).timeout
		vp.get_texture().get_image().save_png("%s_%d.png" % [out, f])
	print("alan_ust=%.0f alan_alt=%.0f" % [main.arka.dio_bottom(), h - main.INFO_H])
	quit()
