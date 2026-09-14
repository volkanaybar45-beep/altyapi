"""Saydam PNG'nin kenarindaki renk sacagini temizler (premultiply guvenli).

Kullanim: python sacak_temizle.py <girdi.png> <cikti.png> <hedef_hex> [esik]

Neden: uretilen saydam gorsellerde alfasi dusuk piksellerin RENGI rastgele
kaliyor (camgobegi/yesil benek). Ekranda alfa carpildiginda bu renkler
kenarda kir olarak goruluyor; mipmap kucultmesi de komsuya bulastiriyor.
Cozum: alfa dustukce rengi hedef tona cek, alfasi sifir olani tamamen boya.
"""
import sys
from PIL import Image

girdi, cikti, hedef = sys.argv[1], sys.argv[2], sys.argv[3].lstrip("#")
esik = int(sys.argv[4]) if len(sys.argv) > 4 else 250  # bu alfanin altinda karistir

hr, hg, hb = (int(hedef[i:i + 2], 16) for i in (0, 2, 4))

im = Image.open(girdi).convert("RGBA")
px = im.load()
W, H = im.size
degisen = 0
for y in range(H):
    for x in range(W):
        r, g, b, a = px[x, y]
        if a >= esik:
            continue
        k = a / esik                      # alfa dustukce hedefe yaklas
        yr = int(r * k + hr * (1 - k))
        yg = int(g * k + hg * (1 - k))
        yb = int(b * k + hb * (1 - k))
        if (yr, yg, yb) != (r, g, b):
            degisen += 1
        px[x, y] = (yr, yg, yb, a)
im.save(cikti)
print(f"{cikti} · {W}x{H} · duzeltilen piksel: {degisen}")
