extends SceneTree
## İŞ 8 davranış testi (headless olabilir; sahte APPDATA ile koştur):
##  1) çözülen bölüm kendiliğinden sonrakine geçer
##  2) kutlama sırasında dokunuş hemen geçirir
##  3) son bölümden sonra ana ekrana dönülür
##  4) ses ayarı kaydedilir / geri okunur; bozuk ayar dosyası varsayılana düşer
##  5) eksik ses dosyası çökme değil null


func _solve(main) -> void:
	var rot: Array = main.mirrors.filter(func(m): return not m.fixed)
	for k in int(pow(2, rot.size())):
		for j in rot.size():
			rot[j].set_step(3 if (k >> j) & 1 else 1)
		if main.compute_path()["hit"]:
			return


func _initialize() -> void:
	var ok := true
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	# 1) otomatik devam
	main.load_level(0)
	_solve(main)
	await create_timer(3.0).timeout
	var r1: bool = main.level == 1 and not main.completed
	print("otomatik devam: bolum ", main.level + 1, " ", "OK" if r1 else "HATA")
	ok = ok and r1
	# 2) kutlamada dokunuş
	_solve(main)
	await create_timer(0.3).timeout
	main.tap(Vector2(10, 700))
	await create_timer(0.8).timeout
	var r2: bool = main.level == 2
	print("dokununca hemen gecis: bolum ", main.level + 1, " ", "OK" if r2 else "HATA")
	ok = ok and r2
	# 3) son bölüm → ana ekran
	main.load_level(main.all_levels.size() - 1)
	_solve(main)
	await create_timer(4.5).timeout
	var cur = current_scene
	var r3: bool = cur != null and cur.scene_file_path == "res://menu.tscn"
	print("son bolum sonrasi ana ekran: ", cur.scene_file_path if cur else "yok", " ", "OK" if r3 else "HATA")
	ok = ok and r3
	# 4) ayar kaydı
	var ses = root.get_node_or_null("Ses")
	ses.set_sfx(false)
	ses.set_ambient(false)
	ses.sfx_on = true
	ses.ambient_on = true
	ses._load_settings()
	var r4: bool = ses.sfx_on == false and ses.ambient_on == false
	var f := FileAccess.open(ses.SETTINGS_PATH, FileAccess.WRITE)
	f.store_string("[ses]\nefekt=\"evet\"\nortam=[1,2]\n@@@bozuk")
	f.close()
	ses._load_settings()
	var r5: bool = ses.sfx_on == true and ses.ambient_on == true
	print("ayar kaydi: ", "OK" if r4 else "HATA", " · bozuk dosya varsayilan: ", "OK" if r5 else "HATA")
	ses.set_sfx(true)
	ses.set_ambient(true)
	ok = ok and r4 and r5
	# 4b) ses gerçekten çalıyor mu (pencereli koşuda gerçek ses sürücüsü)
	var amb: Array = ses._ambient
	var p0: float = amb[0].get_playback_position()
	await create_timer(1.0).timeout
	var r7: bool = amb[0].playing and amb[1].playing and amb[0].get_playback_position() != p0
	ses.play("ayna")
	await process_frame
	var r8: bool = ses._voices.any(func(v): return v.playing)
	print("ortam caliyor: ", "OK" if r7 else "HATA", " (", AudioServer.get_driver_name(), ") · efekt caliyor: ", "OK" if r8 else "HATA")
	ok = ok and r7 and r8
	# 5) eksik dosya
	var r6: bool = ses._load("res://sesler/yok.ogg") == null
	ses.play("olmayan_anahtar")
	print("eksik ses dosyasi: ", "OK" if r6 else "HATA")
	ok = ok and r6
	print("SONUC: ", "OK" if ok else "HATA")
	quit()
