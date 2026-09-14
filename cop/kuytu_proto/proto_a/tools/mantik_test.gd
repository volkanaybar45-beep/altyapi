extends SceneTree
## Mantık testi (headless). Sahte APPDATA ile koş:
##   godot --headless --path . -s tools/mantik_test.gd

const Board := preload("res://board.gd")
const Piece := preload("res://piece.gd")

var fails := 0


func check(cond: bool, name: String) -> void:
	print(("OK   " if cond else "HATA ") + name)
	if not cond:
		fails += 1


func _initialize() -> void:
	_run()


func _run() -> void:
	# 1) satır temizleme
	var b := Board.new()
	for c in 7:
		b.place([Vector2i.ZERO], 0, Vector2i(c, 0))
	check(b.full_lines().rows.is_empty(), "eksik satır dolu sayılmaz")
	b.place([Vector2i.ZERO], 1, Vector2i(7, 0))
	var l := b.full_lines()
	check(l.rows == [0] and l.cols.is_empty(), "dolu satır bulunur")
	check(b.clear_lines(l).size() == 8 and b.filled_in_row(0) == 0, "satır temizlenir")

	# 2) satır + sütun aynı hamlede (kombo 2), kesişim bir kez sayılır
	b.reset()
	for i in 8:
		if i != 3:
			b.place([Vector2i.ZERO], 2, Vector2i(i, 3))
			b.place([Vector2i.ZERO], 2, Vector2i(3, i))
	b.place([Vector2i.ZERO], 2, Vector2i(3, 3))
	l = b.full_lines()
	check(l.rows == [3] and l.cols == [3], "satır+sütun birlikte bulunur")
	check(b.clear_lines(l).size() == 15, "kesişim tekrarsız: 15 hücre")

	# 3) sınır / çakışma
	check(not b.can_place([Vector2i(0, 0), Vector2i(1, 0)], Vector2i(7, 0)), "taşan parça reddedilir")
	b.place([Vector2i.ZERO], 0, Vector2i(5, 5))
	check(not b.can_place([Vector2i.ZERO], Vector2i(5, 5)), "dolu hücreye konmaz")

	# 4) çeviri
	check(tr("SKOR") != "SKOR" and tr("KOMBO") != "KOMBO", "çeviri yüklü: " + tr("SKOR") + " / " + tr("KOMBO"))

	# 5) gerçek sahne: sürükle-bırak yolu
	var main = load("res://main.tscn").instantiate()
	main.seed_override = 3
	root.add_child(main)
	await process_frame
	var p: Piece = main.tray[0]
	var shape: Array = p.shape
	var target := Vector2i(2, 2)
	# parçanın sol üstü hedef hücreye gelecek parmak konumu
	var finger: Vector2 = main.board_view.position + Vector2(target) * main.CELL + p.pixel_size() / 2.0 + Vector2(0, main.DRAG_LIFT)
	check(main.press(main._slot_center(0)), "havuzdaki parçaya basınca sürükleme başlar")
	main.move(finger)
	main.release()
	var all_set := true
	for off in shape:
		if main.board.get_cell(target + off) == Board.EMPTY:
			all_set = false
	check(all_set and main.tray[0] == null, "bırakınca parça hedef hücrelere yerleşir")
	check(main.score == shape.size(), "skor = hücre sayısı (%d)" % main.score)

	# 6) geçersiz bırakma: havuza döner
	var p1: Piece = main.tray[1]
	main.press(main._slot_center(1))
	main.move(Vector2(-500, -500))
	main.release()
	check(main.tray[1] == p1, "geçersiz bırakma parçayı havuzda bırakır")

	# 7) tıkanma: tahta dolu, hiçbir parça sığmıyor -> en dolu satır temizlenir
	# dama deseni: yan yana iki boş yok -> ikili parça sığmaz; satır 2 bir fazla dolu
	main.board.reset()
	for r in 8:
		for c in 8:
			if (r + c) % 2 == 1:
				main.board.cells[r][c] = 1
	main.board.cells[2][0] = 1
	var domino := [Vector2i(0, 0), Vector2i(1, 0)]
	for i in 3:
		if main.tray[i] != null:
			main.tray[i].shape = domino
	check(not main._any_fits(), "kurulum: hiçbir parça sığmıyor")
	var n: int = main._resolve_stuck()
	check(main._any_fits(), "tıkanma sonrası en az bir parça sığar")
	check(n == 1 and main.board.filled_in_row(2) == 0, "en dolu satır (2) temizlendi, %d satır" % n)

	# 8) kombo: satır + sütun aynı anda
	main.board.reset()
	for i in 8:
		if i != 7:
			main.board.cells[7][i] = 0
			main.board.cells[i][7] = 0
	var dot := Piece.new()
	dot.setup([Vector2i.ZERO], 0, Color.WHITE, main.CELL)
	main.add_child(dot)
	var keep = main.tray[2]
	main.tray[2] = dot
	var before: int = main.score
	main._place(2, dot, Vector2i(7, 7))
	main.tray[2] = keep
	check(main.score - before == 1 + 40, "kombo 2: +1 hücre +40")
	check(main.combo_label.text == tr("KOMBO") % 2, "kombo yazısı: " + main.combo_label.text)

	print("SONUC: %s (%d hata)" % ["GECTI" if fails == 0 else "KALDI", fails])
	quit(1 if fails else 0)
