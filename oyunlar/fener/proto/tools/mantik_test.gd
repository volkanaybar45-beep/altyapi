extends SceneTree
## Her bölüm (elle 9 + üretilen 10), 90°: başlangıçta çözülmemiş mi, çözüm var mı?
## Bulunan ilk çözüm gerçek dokunma yoluyla (tap) tekrar verilip doğrulanır.
## Çalıştır: --headless --path . -s tools/mantik_test.gd

const Main := preload("res://main.gd")


func _initialize() -> void:
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var ok := true
	for i in Main.all_levels.size():
		main.load_level(i)
		var rot: Array = main.mirrors.filter(func(m): return not m.fixed)
		var start: Array = rot.map(func(m): return m.step)
		var start_hit: bool = main.compute_path()["hit"]
		var count := 0
		var first = null
		var total := 1 << rot.size()
		for k in total:
			var combo := []
			for j in rot.size():
				combo.append(3 if (k >> j) & 1 else 1)
				rot[j].set_step(combo[j])
			if main.compute_path()["hit"]:
				count += 1
				if first == null:
					first = combo
		# ilk çözümü baştan, dokunarak ver
		var tap_ok := false
		if first != null:
			for j in rot.size():
				rot[j].set_step(start[j])
			for j in rot.size():
				if rot[j].step % 4 != first[j]:
					main.tap(rot[j].position + Vector2(10, 10))
			tap_ok = main.compute_path()["hit"]
		var pass_i: bool = not start_hit and count > 0 and tap_ok
		ok = ok and pass_i
		var ad := "bolum %d" % (i + 1) if i < 9 else "uretilen %d" % (i - 8)
		print("%s: ayna=%d baslangic_cozulu=%s cozum=%d/%d dokunma=%s %s" % [
			ad, rot.size(), start_hit, count, total, tap_ok, "OK" if pass_i else "HATA"])
	print("SONUC: ", "OK" if ok else "HATA")
	quit(0 if ok else 1)
