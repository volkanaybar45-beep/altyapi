# -*- coding: utf-8 -*-
"""Görsel çakışma denetimi (İŞ 6). Her bölümde nesnelerin sprite alfa
maskelerini hücre ölçeğinde çizer; iki nesnenin bindiği pikselleri sayar.
Oyunu çalıştırmaz, kayıt dosyasına dokunmaz. Boyutlar main.gd ile aynı
tutulmalı (VIS_* sabitleri).

  python tools/cakisma.py            → her bölüm için çakışan çiftler
"""
import re, sys, os
import numpy as np
from PIL import Image

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PX = 40  # hücre başına piksel (denetim çözünürlüğü)

# main.gd / mirror.gd ile aynı (hücre biriminde)
BOAT_W = float(os.environ.get("BOAT_W", 1.7))    # tekne görünür genişliği
TOWER_H = float(os.environ.get("TOWER_H", 2.0))  # kule görünür yüksekliği
ROCK_W = 1.1
PLATE_W = 0.95
ESIK = 0.01  # hücre alanının %1'inden az binme kenar yumuşatmasıdır, sayılmaz


def maske(ad):
    a = np.asarray(Image.open(os.path.join(KOK, "gorseller", ad)).convert("RGBA"))
    return Image.fromarray(((a[..., 3] > 128) * 255).astype(np.uint8))


M = {k: maske(k + ".png") for k in ["tekne", "fener_kulesi", "kayalik", "ayna_plaka", "ayna_taban"]}
# ayna_taban dönmez; kule lamba odası (252,109) hücre merkezinde


def yerlestir(tuval, img, merkez_px, olcek, aci=0.0, capa=None):
    """img'i ölçekle/döndür, capa (img içindeki nokta, varsayılan orta) merkez_px'e."""
    w, h = img.size
    capa = capa or (w / 2, h / 2)
    im = img.resize((max(1, int(w * olcek)), max(1, int(h * olcek))), Image.BILINEAR)
    cx, cy = capa[0] * olcek, capa[1] * olcek
    if aci:
        # döndürmeyi merkez etrafında yap (ayna için capa = orta)
        im = im.rotate(-aci, resample=Image.BILINEAR, expand=True)
        cx, cy = im.size[0] / 2, im.size[1] / 2
    ox, oy = int(merkez_px[0] - cx), int(merkez_px[1] - cy)
    lay = Image.new("L", tuval, 0)
    lay.paste(im, (ox, oy))
    return np.asarray(lay) > 128


def nesneler(harita):
    h, w = len(harita), len(harita[0])
    out = []
    for y, row in enumerate(harita):
        for x, c in enumerate(row):
            if c != ".":
                out.append((c, x, y))
    return w, h, out


def denetle(harita, xs=None, ys=None):
    w, h, obj = nesneler(harita)
    xs = xs or list(range(w))
    ys = ys or list(range(h))
    pad = 3
    tuval = (int((xs[-1] + 2 * pad) * PX), int((ys[-1] + 2 * pad) * PX))
    katman = []
    for c, x, y in obj:
        p = ((xs[x] + pad) * PX, (ys[y] + pad) * PX)
        if c == "T":
            m = yerlestir(tuval, M["tekne"], p, BOAT_W * PX / 490)
        elif c == "F":
            m = yerlestir(tuval, M["fener_kulesi"], p, TOWER_H * PX / 490, capa=(252, 109))
        elif c == "R":
            m = yerlestir(tuval, M["kayalik"], p, ROCK_W * PX / 490)
        elif c == "Y":
            r = 0.358 * PX
            yy, xx = np.mgrid[0:tuval[1], 0:tuval[0]]
            m = (abs(xx - p[0]) + abs(yy - p[1])) <= r
        else:  # ayna: iki durumun birleşimi (döner) ya da tek durum (sabit)
            sc = PLATE_W * PX / 488
            acilar = [45, 135] if c in "MN" else ([45] if c == "b" else [135])
            m = np.zeros((tuval[1], tuval[0]), bool)
            for a in acilar:
                m |= yerlestir(tuval, M["ayna_plaka"], p, sc, a)
            if c in "MN":
                bs = (60 / 90) * PX / 256
                m |= yerlestir(tuval, M["ayna_taban"], p, bs, capa=(128, 30))
        katman.append(((c, x, y), m))
    cift = []
    esik = ESIK * PX * PX
    for i in range(len(katman)):
        for j in range(i + 1, len(katman)):
            n = int((katman[i][1] & katman[j][1]).sum())
            a, b = katman[i][0][0], katman[j][0][0]
            if n > esik and not (a in "MNbs" and b in "MNbs"):
                cift.append((katman[i][0], katman[j][0], round(n / (PX * PX), 2)))
    return cift


def bolumler():
    tum = []
    for f in ["levels.gd", "levels_uretilen.gd", "levels_uretilen_4.gd"]:
        s = open(os.path.join(KOK, f), encoding="utf-8").read()
        for blok in re.findall(r'"map": \[(.*?)\]', s, re.S):
            tum.append(re.findall(r'"([^"]+)"', blok))
    return tum


if __name__ == "__main__":
    toplam = 0
    for i, harita in enumerate(bolumler()):
        c = denetle(harita)
        if c:
            toplam += 1
            print(f"bolum {i + 1}: " + " · ".join(f"{a[0]}{a[1:]}-{b[0]}{b[1:]} {n}" for a, b, n in c))
    print(f"cakisan bolum: {toplam}")
