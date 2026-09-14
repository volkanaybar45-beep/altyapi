extends RefCounted
## ÜRETİLDİ — elle düzenleme. Yeniden yazmak için (proto klasöründen):
##   python tools/uretec.py 40000 1 is4
## Harita harfleri levels.gd ile aynı.

const ALL := [
	{"yon": "U", "zorluk": 0.80, "sinif": "bölücüsüz", "map": [
		# solution_toggles=7 · solution_reflections=8 · relevant_mirrors=8 · irrelevant_mirrors=0 · expanded_states=15 · max_backtrack=5 · near_misses=2 · beam_crossings=0 · aha=True
		"........",
		"M.M....N",
		"........",
		"........",
		"M.N.M...",
		".....T.F",
		"N...N...",
		"........",
		"........",
		"........",
		"....NM..",
		"........",
		"........",
		".....N..",
	]},
	{"yon": "D", "zorluk": 0.85, "sinif": "bölücüsüz", "map": [
		# solution_toggles=6 · solution_reflections=7 · relevant_mirrors=7 · irrelevant_mirrors=0 · expanded_states=17 · max_backtrack=8 · near_misses=2 · beam_crossings=1 · aha=True
		".M.NF...",
		"........",
		"........",
		"........",
		".N..M..M",
		"N..N...N",
		"........",
		"........",
		".....T.N",
		"....M...",
		"........",
		"........",
		"........",
		"........",
	]},
	{"yon": "U", "zorluk": 0.97, "sinif": "bölücüsüz", "map": [
		# solution_toggles=6 · solution_reflections=8 · relevant_mirrors=7 · irrelevant_mirrors=0 · expanded_states=19 · max_backtrack=8 · near_misses=3 · beam_crossings=0 · aha=True
		".Mb.....",
		"........",
		"........",
		"..N.N...",
		"........",
		".NN..M..",
		"....NM..",
		"..F.....",
		"........",
		".M......",
		".....T..",
		"........",
		"........",
		"........",
	]},
	{"yon": "U", "zorluk": 1.00, "sinif": "bölücüsüz", "map": [
		# solution_toggles=7 · solution_reflections=8 · relevant_mirrors=8 · irrelevant_mirrors=0 · expanded_states=21 · max_backtrack=9 · near_misses=2 · beam_crossings=1 · aha=True
		"........",
		"N..M..N.",
		"........",
		"N....NNN",
		"T.......",
		".....N.M",
		"...F....",
		"........",
		"........",
		"........",
		"........",
		"........",
		"........",
		"........",
	]},
]
