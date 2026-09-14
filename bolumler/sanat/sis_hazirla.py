"""Sis şeridini oyuna hazırlar: saçak temizler, kenarı yumuşatır, yatay tile eder.

Kullanim: python sis_hazirla.py <girdi.png> <cikti.png> [renk_hex] [genislik] [yukseklik]

Neden: uretilen sis PNG'lerinde alfasi dusuk piksellerin RENGI saciyor
(mavi-beyaz sacak) ve ust/alt sinir keskin oluyor. Sis duz renktir, sekli
alfa tasir. Bu yuzden RGB tamamen sabitlenir, alfa yumusatilir.
"""
import sys
from PIL import Image, ImageFilter

girdi, cikti = sys.argv[1], sys.argv[2]
renk = sys.argv[3] if len(sys.argv) > 3 else "5E7C99"
W = int(sys.argv[4]) if len(sys.argv) > 4 else 2160
H = int(sys.argv[5]) if len(sys.argv) > 5 else 540

r, g, b = (int(renk[i:i + 2], 16) for i in (0, 2, 4))

im = Image.open(girdi).convert("RGBA").resize((W, H), Image.LANCZOS)
a = im.split()[3].filter(ImageFilter.GaussianBlur(H * 0.04))  # kenari tuylendir

# dikey sonumleme: ust ve alt kenarda alfa sifira iner
px = a.load()
for y in range(H):
    t = y / (H - 1)
    k = min(t, 1.0 - t) * 2.0          # 0 -> kenar, 1 -> orta
    k = k * k * (3 - 2 * k)            # yumusak gecis
    for x in range(W):
        px[x, y] = int(px[x, y] * k)

# yatay dikissizlik: seridi kendi kaydirilmis kopyasiyla carprazla
kaydir = a.transform(a.size, Image.AFFINE, (1, 0, -W // 2, 0, 1, 0), fillcolor=0)
agirlik = Image.linear_gradient("L").rotate(-90, expand=True).resize((W, H))
a = Image.composite(a, kaydir, agirlik)

sonuc = Image.new("RGBA", (W, H), (r, g, b, 0))
sonuc.putalpha(a)
sonuc.save(cikti)

h = a.histogram()
print(f"{cikti} · {W}x{H} · saydam {h[0]} · ara ton {sum(h[1:255])} · opak {h[255]}")
print("sol/sag kenar farki:", sum(abs(a.getpixel((0, y)) - a.getpixel((W - 1, y))) for y in range(H)) // H)
