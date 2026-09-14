extends RefCounted
## Elle kurulan bölümler. Tuval 720x1280. Aynalar hep 0 (yatay) başlar.
## Ayna adımı: 1 → aşağı↔sağ, yukarı↔sol · 3 → aşağı↔sol, yukarı↔sağ
## "cozum" sadece test için; oyunda kullanılmaz.

const ALL := [
	{  # kolay: 2 ayna
		"fener": Vector2(360, 140), "yon": Vector2.DOWN,
		"tekne": Vector2(600, 1130),
		"aynalar": [Vector2(360, 480), Vector2(600, 480)],
		"cozum": [1, 1],
	},
	{  # orta: 4 ayna, merdiven
		"fener": Vector2(150, 140), "yon": Vector2.DOWN,
		"tekne": Vector2(230, 1130),
		"aynalar": [Vector2(150, 400), Vector2(470, 400), Vector2(470, 720), Vector2(230, 720)],
		"cozum": [1, 1, 3, 3],
	},
	{  # şaşırtan: ışın kendi yolunu (450,350)'de kesiyor
		"fener": Vector2(450, 140), "yon": Vector2.DOWN,
		"tekne": Vector2(600, 1130),
		"aynalar": [Vector2(450, 780), Vector2(150, 780), Vector2(150, 350), Vector2(600, 350)],
		"cozum": [3, 1, 3, 1],
	},
]
