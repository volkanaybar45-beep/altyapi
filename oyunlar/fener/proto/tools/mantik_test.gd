extends SceneTree
## Her bölüm, iki modda: başlangıçta çözülmemiş mi, çözüm var mı, kaç tane?
## Bulunan ilk çözüm gerçek dokunma yoluyla (tap) tekrar verilip doğrulanır.
## Çalıştır: --headless --path . -s tools/mantik_test.gd

const Levels := preload("res://levels.gd")


func _initialize() -> void:
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var ok := true
	for m90 in [false, true]:
		main.mode90 = m90
		for i in Levels.ALL.size():
			main.load_level(i)
			var rot: Array = main.mirrors.filter(func(m): return not m.fixed)
			var start: Array = rot.map(func(m): return m.step)
			var start_hit: bool = main.compute_path()["hit"]
			var opts: Array = [1, 3] if m90 else [0, 1, 2, 3]
			var count := 0
			var first = null
			var total := int(pow(opts.size(), rot.size()))
			for k in total:
				var kk := k
				var combo := []
				for m in rot:
					combo.append(opts[kk % opts.size()])
					kk /= opts.size()
				for j in rot.size():
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
					while rot[j].step % 4 != first[j]:
						main.tap(rot[j].position + Vector2(10, 10))
				tap_ok = main.compute_path()["hit"]
			var pass_i: bool = not start_hit and count > 0 and tap_ok
			ok = ok and pass_i
			print("%s bolum %d: ayna=%d baslangic_cozulu=%s cozum=%d/%d dokunma=%s %s" % [
				"90" if m90 else "45", i + 1, rot.size(), start_hit, count, total, tap_ok,
				"OK" if pass_i else "HATA"])
	print("SONUC: ", "OK" if ok else "HATA")
	quit(0 if ok else 1)
