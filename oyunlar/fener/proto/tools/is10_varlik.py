# -*- coding: utf-8 -*-
"""İŞ 10 varlık hazırlığı (tekrar üretilebilir). Girdi: toon_render.py
çıktıları (yaw -40, pitch 30) + diyorama_deneme/ düz resimleri. Çıktı:
proto/gorseller/ (oyun) ve gorseller/render/ (asıl render'lar).

  python tools/is10_varlik.py <render_klasoru>

Render komutları (bolumler/sanat/toon_render.py, "-" = doygunluğa dokunma):
  TR_YAW=-40 TR_PITCH=30 TR_NPTS=14000000 TR_SUPER=2600 TR_FINAL=1300 \
      toon_render.py diyorama_liman.glb diyorama_y-40_p30 z -
  TR_YAW=<θ-40> TR_PITCH=30 toon_render.py ayna.glb ayna_p66_t<θ> z - - 0.66   θ = 336.6 103.4 156.6 283.4
  TR_YAW=-40 TR_PITCH=30 toon_render.py tekne.glb tekne_p70 z - - 0.70
  TR_YAW=-40 TR_PITCH=30 toon_render.py kaya_engel_sivri.glb engel_p64 z - - 0.64
  TR_YAW=-40 TR_PITCH=30 toon_render.py kaya_taban_duz.glb taban_p50 z - - 0.50
  (parlaklık hedefleri K6 kontrastı için; açı G1 aynı)
Oyun sabitleri (main.gd / arka.gd) bu betiğin yazdırdığı ölçülerle aynı olmalı.
"""
import os, shutil, sys
import numpy as np
from PIL import Image

R = sys.argv[1]
KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # proto
OYUN = os.path.join(KOK, "gorseller")
ASIL = os.path.join(KOK, "..", "gorseller")
DD = os.path.join(ASIL, "diyorama_deneme")

# --- diyorama levhası: iskele kırpılır (E1) -----------------------------------
Y0, Y1, FEATHER = 90, 670, 24   # 1300'lük render'da; y1'in altı iskele
d = Image.open(os.path.join(R, "diyorama_y-40_p30_1300.png")).convert("RGBA")
a = np.asarray(d).copy()
al = a[..., 3] > 20
ys, xs = np.where(al)
X0, X1 = int(xs.min()), int(xs.max()) + 1
lev = a[Y0:Y1, X0:X1].copy()
ramp = np.linspace(1.0, 0.0, FEATHER)[:, None]
lev[-FEATHER:, :, 3] = (lev[-FEATHER:, :, 3] * ramp).astype(np.uint8)
# modelin kendi su plakası (koyu, mavi baskın) oyunun denizinin üstünde düz bir
# levha gibi duruyordu → yarı saydam. Köy ışığının sudaki sıcak yansımaları
# (parlak / kırmızı baskın) dokunulmadan kalır.
rgb = lev[..., :3].astype(float) / 255.0
lum = rgb @ np.array([0.2126, 0.7152, 0.0722])
su = (rgb[..., 2] > rgb[..., 0] + 0.03) & (lum < 0.16)
yumusak = np.clip((0.16 - lum) / 0.06, 0, 1) * su
lev[..., 3] = (lev[..., 3] * (1.0 - 0.75 * yumusak)).astype(np.uint8)
print("su plakası: %d piksel yarı saydam" % int((yumusak > 0.5).sum()))
Image.fromarray(lev).save(os.path.join(OYUN, "diyorama_levha.png"))
d.save(os.path.join(ASIL, "render", "diyorama_y-40_p30_1300.png"))
# lamba: fener tepesindeki sıcak parlak pikseller (render'da 700-900 x, 100-260 y)
sub = a[100:260, 700:900, :3].astype(int)
warm = (sub[..., 0] > 200) & (sub[..., 1] > 150) & (sub[..., 2] < 150)
wy, wx = np.where(warm)
lamp = (wx.mean() + 700 - X0, wy.mean() + 100 - Y0)
# kule boyu: lamba sütununda (±15 px) alfalı en üst satır → gövde bitimi (parlaklık düşüşü)
colL = int(wx.mean() + 700)
tower_top = int(np.where(a[:, colL - 15:colL + 15, 3].max(1) > 20)[0].min())
lum = a[:, colL - 15:colL + 15, :3].mean((1, 2))
tower_bot = next(y for y in range(tower_top + 60, 400) if lum[y] < 35)
print("LEVHA boyu %dx%d · render kırpma x %d-%d y %d-%d" % (X1 - X0, Y1 - Y0, X0, X1, Y0, Y1))
print("LAMBA levhada (%.1f, %.1f) · kule y %d-%d (boy %d px, render ölçeğinde)" % (
    lamp[0], lamp[1], tower_top, tower_bot, tower_bot - tower_top))
print("içerik tepesi levhada y=%d" % (ys.min() - Y0))

# --- sprite'lar ------------------------------------------------------------------
for i, t in enumerate(("336.6", "103.4", "156.6", "283.4")):
    shutil.copy(os.path.join(R, "ayna_p66_t%s_512.png" % t), os.path.join(OYUN, "ayna_%d.png" % i))
    shutil.copy(os.path.join(R, "ayna_p66_t%s_512.png" % t), os.path.join(ASIL, "render", "ayna_p66_t%s_512.png" % t))
for src, dst in (("taban_p50", "kaya_taban"), ("engel_p64", "kaya_engel"), ("tekne_p70", "tekne")):
    shutil.copy(os.path.join(R, "%s_512.png" % src), os.path.join(OYUN, dst + ".png"))
    shutil.copy(os.path.join(R, "%s_512.png" % src), os.path.join(ASIL, "render", "%s_y-40_p30_512.png" % src))
b = np.asarray(Image.open(os.path.join(OYUN, "tekne.png"))).astype(int)
w = (b[..., 0] > 220) & (b[..., 1] > 170) & (b[..., 2] < 150) & (b[..., 3] > 200)
wy, wx = np.where(w[:110])
print("TEKNE feneri (%.0f, %.0f)" % (wx.mean(), wy.mean()))

# --- gökyüzü: ufkun üstü; ay: yarı saydam piksellerin rengi tek sıcak tona -------
g = Image.open(os.path.join(DD, "gokyuzu_panorama.png")).convert("RGB")
ga = np.asarray(g).astype(float).mean(2)
row = ga.mean(1)
hor = int(np.argmax(np.abs(np.diff(row[400:900]))) + 400)  # gök→deniz en keskin geçiş
g.crop((0, 0, g.size[0], hor)).save(os.path.join(OYUN, "gokyuzu.png"))
print("GÖK ufuk satırı %d (%dx%d → %dx%d)" % (hor, g.size[0], g.size[1], g.size[0], hor))
m = np.asarray(Image.open(os.path.join(DD, "ay.png")).convert("RGBA")).astype(float)
tgt = np.array([242, 227, 192], float)  # #F2E3C0 sıcak hale
k = np.clip(m[..., 3] / 250.0, 0, 1)[..., None]
m[..., :3] = np.where(m[..., 3:4] < 250, m[..., :3] * k + tgt * (1 - k), m[..., :3])
Image.fromarray(m.astype(np.uint8)).resize((512, 512), Image.LANCZOS).save(os.path.join(OYUN, "ay.png"))
print("AY temizlendi: %d yarı saydam piksel hale tonuna çekildi" % int((m[..., 3] < 250).sum()))
