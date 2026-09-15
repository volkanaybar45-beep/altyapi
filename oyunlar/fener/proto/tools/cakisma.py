# -*- coding: utf-8 -*-
"""Görsel çakışma denetimi. Her bölümde nesnelerin sprite alfa maskelerini
hücre ölçeğinde çizer; iki nesnenin bindiği pikselleri sayar. Oyunu
çalıştırmaz, kayıt dosyasına dokunmaz. (İŞ 6-7 sürümü: cop/fener_is10/)

İŞ 10 geometrisi (main.gd / mirror.gd ile AYNI sabitler; biri değişirse öteki):
  - her sprite'ın alt ortası hücrenin su noktasında: merkez + WP hücre (G3)
  - satır ölçeği: üst satır 0.85 → alt satır 1.0 (G2)
  - ayna = taban kayası (düz tepe, ISLET_CUT altı suda) + ayna sprite'ı
    (döner aynada 4 yönün birleşimi), engel = sivri kaya, tekne yeni render
  - kule ızgarada YOK (diyoramanın feneri); F hücresi boş su

  python tools/cakisma.py            → aralık kuralıyla çakışan bölümler
"""
import re, os
import numpy as np
from PIL import Image

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PX = 40          # hücre başına piksel (denetim çözünürlüğü)
ESIK = 0.01      # hücre alanının %1'inden az binme kenar yumuşatmasıdır, sayılmaz

WP = 0.6
ROW_SCALE_TOP = 0.85
GAP = 0.4
BOAT_W, BOAT_CUT, BOAT_AX = 1.1, 440, 255.5
ROCK_W, ROCK_CUT, ROCK_AX = 0.95, 420, 255.5
SIZE_K = 1.3     # İŞ 12: ayna (kaya + ayna) 1.3 kat (mirror.gd SIZE_K)
GAP_MM = 0.3     # üst üste iki ayna arası (main.gd GAP_MM)
ISLET_W, ISLET_CUT, ISLET_TOP, ISLET_AX = 0.9 * SIZE_K, 260, 118, 255.5
MIRROR_H, MIRROR_AX = 0.72 * SIZE_K, [263, 263, 261, 256]
SPLIT_R = 28 * 1.15 / 90


def maske(ad):
    a = np.asarray(Image.open(os.path.join(KOK, "gorseller", ad)).convert("RGBA"))
    return a[..., 3] > 128


M = {k: maske(k + ".png") for k in ["tekne", "kaya_engel", "kaya_taban", "ayna_0", "ayna_1", "ayna_2", "ayna_3"]}


def koy(tuval, m, alt_orta, f, capa, kes=None):
    """m maskesini f ölçeğiyle, capa (sprite pikseli) alt_orta'ya gelecek şekilde
    tuvale basar; kes verilirse o satırın altı atılır."""
    if kes is not None:
        m = m[:int(kes)]
    im = Image.fromarray((m * 255).astype(np.uint8))
    w, h = im.size
    im = im.resize((max(1, int(w * f)), max(1, int(h * f))), Image.BILINEAR)
    ox, oy = int(alt_orta[0] - capa[0] * f), int(alt_orta[1] - capa[1] * f)
    lay = Image.new("L", (tuval.shape[1], tuval.shape[0]), 0)
    lay.paste(im, (ox, oy))
    return np.asarray(lay) > 128


def nesneler(harita):
    out = []
    for y, row in enumerate(harita):
        for x, c in enumerate(row):
            if c not in ".F":
                out.append((c, x, y))
    return len(harita[0]), len(harita), out


def aralik(harita):
    """main.gd _spacing ile aynı: tekne ile yatay/dikey komşusu arasına GAP,
    üst üste iki ayna arasına GAP_MM."""
    w, h, obj = nesneler(harita)
    dolu = {(x, y): c for c, x, y in obj}
    gx, gy = [0.0] * w, [0.0] * h
    for (x, y), c in dolu.items():
        if c == "T":
            for dx in (-1, 1):
                if (x + dx, y) in dolu:
                    gx[min(x, x + dx)] = max(gx[min(x, x + dx)], GAP)
            for dy in (-1, 1):
                if (x, y + dy) in dolu:
                    gy[min(y, y + dy)] = max(gy[min(y, y + dy)], GAP)
        elif c in "MNbs" and dolu.get((x, y + 1), ".") in "MNbs" and (x, y + 1) in dolu:
            gy[y] = max(gy[y], GAP_MM)
    xs, ys, a = [], [], 0.0
    for i in range(w):
        xs.append(i + a); a += gx[i]
    a = 0.0
    for i in range(h):
        ys.append(i + a); a += gy[i]
    return xs, ys


def denetle(harita):
    w, h, obj = nesneler(harita)
    xs, ys = aralik(harita)
    last = max(y for _, _, y in obj)
    pad = 3
    tuval = np.zeros((int((ys[-1] + 2 * pad) * PX), int((xs[-1] + 2 * pad) * PX)), bool)
    katman = []
    for c, x, y in obj:
        rs = ROW_SCALE_TOP + (1 - ROW_SCALE_TOP) * ys[y] / max(1.0, ys[last])
        cx, cy = (xs[x] + pad) * PX, (ys[y] + pad) * PX
        wp = (cx, cy + WP * PX)
        if c == "T":
            m = koy(tuval, M["tekne"], wp, BOAT_W * PX * rs / 483, (BOAT_AX, BOAT_CUT), BOAT_CUT)
        elif c == "R":
            m = koy(tuval, M["kaya_engel"], wp, ROCK_W * PX * rs / 483, (ROCK_AX, ROCK_CUT), ROCK_CUT)
        elif c == "Y":
            r = SPLIT_R * PX
            yy, xx = np.mgrid[0:tuval.shape[0], 0:tuval.shape[1]]
            m = (abs(xx - cx) + abs(yy - cy)) <= r
        else:
            fi = ISLET_W * PX * rs / 483
            m = koy(tuval, M["kaya_taban"], wp, fi, (ISLET_AX, ISLET_CUT), ISLET_CUT)
            top = (wp[0], wp[1] - (ISLET_CUT - ISLET_TOP) * fi)
            fm = MIRROR_H * PX * rs / 483
            idx = [0, 1, 2, 3] if c in "MN" else ([0] if c == "b" else [1])
            for i in idx:
                m |= koy(tuval, M["ayna_%d" % i], top, fm, (MIRROR_AX[i], 497))
        katman.append(((c, x, y), m))
    cift = []
    esik = ESIK * PX * PX
    for i in range(len(katman)):
        for j in range(i + 1, len(katman)):
            n = int((katman[i][1] & katman[j][1]).sum())
            if n > esik:
                cift.append((katman[i][0], katman[j][0], round(n / (PX * PX), 3)))
    return cift


def bolumler():
    tum = []
    for f in ["levels.gd", "levels_uretilen_11.gd"]:
        s = open(os.path.join(KOK, f), encoding="utf-8").read()
        for blok in re.findall(r'"map": \[(.*?)\]', s, re.S):
            tum.append(re.findall(r'"([^"]+)"', blok))
    return tum


if __name__ == "__main__":
    toplam = 0
    hepsi = bolumler()
    for i, harita in enumerate(hepsi):
        c = denetle(harita)
        if c:
            toplam += 1
            print(f"bolum {i + 1}: " + " · ".join(f"{a[0]}{a[1:]}-{b[0]}{b[1:]} {n}" for a, b, n in c))
    print(f"cakisan bolum: {toplam}/{len(hepsi)}")
