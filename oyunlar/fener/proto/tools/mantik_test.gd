extends SceneTree
## Her bölüm: başlangıçta çözülmemiş mi, çözümle tekneye ulaşıyor mu?
## Çalıştır: --headless --path . -s tools/mantik_test.gd

const Levels := preload("res://levels.gd")


func _initialize() -> void:
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var ok := true
	for i in Levels.ALL.size():
		main.load_level(i)
		var start: bool = main.compute_path()["hit"]
		var sol: Array = Levels.ALL[i]["cozum"]
		for j in sol.size():  # gerçek dokunma yolu: aynaya sol[j] kez dokun
			for _k in sol[j]:
				main.tap(main.mirrors[j].position + Vector2(10, 10))
		var r: Dictionary = main.compute_path()
		var pass_i: bool = (not start) and r["hit"]
		ok = ok and pass_i
		print("bolum %d: baslangic_cozulu=%s cozum_ulasti=%s nokta=%d %s" % [i + 1, start, r["hit"], r["points"].size(), "OK" if pass_i else "HATA"])
	print("SONUC: ", "OK" if ok else "HATA")
	quit(0 if ok else 1)
