extends SceneTree
## İŞ 10 ölçümü (headless olabilir): her bölüm için K3 (lamba ↔ kaynak sütunu,
## ışının ilk noktası) ve K4 (ızgara diyoramanın altında mı), hücre boyu,
## diyorama ölçeği, fener boyu. Argüman: -- <yukseklik 1280|1600>


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var h := int(args[0]) if args.size() > 0 else 1280
	root.size = Vector2i(720, h)
	var main = load("res://main.tscn").instantiate()
	main.auto_advance = false
	root.add_child(main)
	await process_frame
	var Arka = main.Arka
	var worst_k3 := 0.0
	var worst_gap := INF
	var min_cell := INF
	for i in main.all_levels.size():
		main.load_level(i)
		main.update_ray()
		var lamp: Vector2 = main.arka.lamp_screen()
		var start: Vector2 = main.paths[0][0]
		var k3 := maxf(absf(lamp.x - main.fener_pos.x), start.distance_to(lamp))
		# en üst nesnenin tepesi (yığın 0.385 hücre) ya da üst satır hücre kenarı
		var row0_top: float = main.fener_pos.y - 0.5 * main.cell
		for m in main.mirrors + main.boats + main.rocks:
			var p: Vector2 = m.position if m is Node2D else m
			row0_top = minf(row0_top, p.y - 0.4 * main.cell)
		var gap: float = row0_top - main.arka.dio_bottom()
		worst_k3 = maxf(worst_k3, k3)
		worst_gap = minf(worst_gap, gap)
		min_cell = minf(min_cell, main.cell)
		print("bolum %2d: hucre=%.1f diyorama_olcek=%.2f alt=%.0f ust_nesne=%.0f bosluk=%.0f lamba=(%.1f,%.1f) F.x=%.1f K3=%.2f aynali=%s" % [
			i + 1, main.cell, main.arka.dio_scale, main.arka.dio_bottom(), row0_top, gap,
			lamp.x, lamp.y, main.fener_pos.x, k3, main.arka.dio_flip])
	print("OZET %d: en kucuk hucre=%.1f · fener boyu=%.1f px · en kotu K3=%.2f px · en dar K4 boslugu=%.0f px" % [
		h, min_cell, Arka.DIO_TOWER_H * main.arka.dio_scale, worst_k3, worst_gap])
	quit()
