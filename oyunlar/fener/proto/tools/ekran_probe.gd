extends SceneTree
## Ekran görüntüsü. Argüman: -- <cikti.png> <bolum 0..28> <cozulu 0/1> [yukseklik] [bekle_sn] [kare] [aralik_sn]
##   bolum -1 = Ayarlar paneli · 0 = ana ekran · 10-19 = üretilen (İŞ 3) · 20-27 = üretilen (İŞ 4)
##   yukseklik: 1280 (9:16) · 1600 (20:9, çoğu güncel telefon). Genişlik hep 720.
##   bekle_sn: çözüldükten sonra bekleme (0.5 → kutlamanın ortası, 1.5 → sonu)
## --headless KULLANMA (GPU render gerekir). Çözüm kaba kuvvetle bulunur.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0]
	var lv := int(args[1]) - 1
	var solved := args.size() > 2 and args[2] == "1"
	var h := int(args[3]) if args.size() > 3 else 1280
	var wait := float(args[4]) if args.size() > 4 else 1.5
	var vp := SubViewport.new()
	vp.size = Vector2i(720, h)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.transparent_bg = false
	root.add_child(vp)
	var scene: String = "res://menu.tscn" if lv < 0 else "res://main.tscn"
	var main = load(scene).instantiate()
	if lv >= 0:
		main.auto_advance = false  # çözülmüş kare alınırken bölüm değişmesin
	vp.add_child(main)
	for _i in 3:
		await process_frame
	if lv == -2:  # bolum -1 = ana ekranda Ayarlar paneli açık
		main.settings_panel.visible = true
	if lv >= 0:
		main.load_level(lv)
		if solved:
			var rot: Array = main.mirrors.filter(func(m): return not m.fixed)
			for k in int(pow(2, rot.size())):
				for j in rot.size():
					rot[j].set_step(3 if (k >> j) & 1 else 1)
				if main.compute_path()["hit"]:
					break
			await create_timer(wait).timeout
	for _i in 10:
		await process_frame
	vp.get_texture().get_image().save_png(out)
	print("yazildi: ", out)
	# hareket karşılaştırması: [kare_sayisi] [aralik_sn] → cikti_2.png, cikti_3.png ...
	var frames := int(args[5]) if args.size() > 5 else 1
	var gap := float(args[6]) if args.size() > 6 else 0.4
	for f in range(2, frames + 1):
		await create_timer(gap).timeout
		var o := out.get_basename() + "_%d.png" % f
		vp.get_texture().get_image().save_png(o)
		print("yazildi: ", o)
	quit()
