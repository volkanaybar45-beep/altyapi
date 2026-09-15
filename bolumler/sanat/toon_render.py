# -*- coding: utf-8 -*-
"""
Yaban — 3D boru hattı render testi.
GLB -> toon gölgeli + konturlu 2D sprite -> palete karşı ölçüm.

Bu betik yaban/ koduna DOKUNMAZ. Sadece scratchpad'de çalışır,
çıktıları scratchpad'e yazar. Oyun kaydına/istatistiklerine erişmez.
"""
import sys, io, math
import numpy as np
from PIL import Image
import trimesh

GLB   = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\VolkaGames\Downloads\fantasy tree 3d model.glb"
OUT   = sys.argv[2] if len(sys.argv) > 2 else "agac"
# hangi eksenden bakılıyor: z = -Z'ye bak (X yatay), x = -X'e bak (Z yatay),
# xr = +X'e bak (aynalı — özne diğer yöne bakar)
VIEW  = sys.argv[3] if len(sys.argv) > 3 else "z"
import os
SUPER = int(os.environ.get("TR_SUPER", 1536))   # üst-örnekleme boyu
FINAL = int(os.environ.get("TR_FINAL", 512))    # kaydedilen boy
TILE  = 256           # tahta ikonu boyu (ölçüm bunda da yapılır)
NPTS  = int(os.environ.get("TR_NPTS", 6_000_000))  # yüzey örnek sayısı
# Kamera açısı (derece, isteğe bağlı; Fener İŞ 10 G1: yaw -40, pitch 30).
# Model önce Y ekseninde YAW, sonra X ekseninde PITCH döndürülür, sonra
# görünüm (z) ile ortografik bakılır. Işık kamera uzayında sabit (soldan).
YAW   = float(os.environ.get("TR_YAW", 0))
PITCH = float(os.environ.get("TR_PITCH", 0))
# "-" verilirse doygunluğa dokunulmaz (diyorama gibi çok renkli sahneler)
HEDEF_DOYGUNLUK = (None if len(sys.argv) > 4 and sys.argv[4] in ('', '-')
                   else float(sys.argv[4]) if len(sys.argv) > 4 else 0.311)
# hedef medyan TON (derece). Bos birakilirsa ton dokunulmaz.
HEDEF_TON = float(sys.argv[5]) if len(sys.argv) > 5 and sys.argv[5] not in ('','-') else None
# hedef ortalama PARLAKLIK. Bos birakilirsa dokunulmaz.
HEDEF_PARLAK = float(sys.argv[6]) if len(sys.argv) > 6 and sys.argv[6] not in ('','-') else None

# ----------------------------------------------------------- yükle
scene = trimesh.load(GLB)
mesh  = trimesh.util.concatenate([g for g in scene.geometry.values()]) \
        if hasattr(scene, "geometry") else scene
if YAW or PITCH:
    Ry = trimesh.transformations.rotation_matrix(math.radians(YAW), [0, 1, 0])
    Rx = trimesh.transformations.rotation_matrix(math.radians(PITCH), [1, 0, 0])
    mesh.apply_transform(Rx @ Ry)
tex = mesh.visual.material.baseColorTexture.convert("RGB")
TEX = np.asarray(tex, dtype=np.float32) / 255.0
th, tw = TEX.shape[:2]
uv_all = np.asarray(mesh.visual.uv, dtype=np.float64)

# ------------------------------------------------- yüzeyden örnekle
pts, fidx = trimesh.sample.sample_surface(mesh, NPTS)
tris = mesh.triangles[fidx]
bary = trimesh.triangles.points_to_barycentric(tris, pts)

uv_tri = uv_all[mesh.faces[fidx]]                     # (N,3,2)
uv = (uv_tri * bary[:, :, None]).sum(axis=1)          # (N,2)

vn = mesh.vertex_normals[mesh.faces[fidx]]            # (N,3,3)
nrm = (vn * bary[:, :, None]).sum(axis=1)
nrm /= np.linalg.norm(nrm, axis=1, keepdims=True) + 1e-9

# ------------------------------------------------------ izdüşüm
# Y yukarı, -Z'ye bakan ortografik ön görünüş
lo, hi = mesh.bounds
if VIEW == "z":       # -Z'ye bak: yatay eksen X, derinlik Z
    hax, dax, sgn = 0, 2, -1.0
elif VIEW == "x":     # -X'e bak: yatay eksen Z, derinlik X
    hax, dax, sgn = 2, 0, -1.0
else:                 # "xr" — +X'e bak, yatay eksen ters (ayna)
    hax, dax, sgn = 2, 0, +1.0

hflip = -1.0 if VIEW == "xr" else 1.0
cx = 0.5 * (lo[hax] + hi[hax])
cy = 0.5 * (lo[1] + hi[1])
span = max(hi[hax] - lo[hax], hi[1] - lo[1]) * 1.06    # kenar payı

sx = ((pts[:, hax] - cx) * hflip / span + 0.5) * (SUPER - 1)
sy = (0.5 - (pts[:, 1] - cy) / span) * (SUPER - 1)     # ekran y aşağı
depth = sgn * pts[:, dax]                               # küçük = yakın

px = np.rint(sx).astype(np.int32)
py = np.rint(sy).astype(np.int32)
ok = (px >= 0) & (px < SUPER) & (py >= 0) & (py < SUPER)

# ARKA YÜZ ELEMESİ — bakış yönüne SIRTINI dönen örnekler atılır.
# Bunlar olmadan iç/arka yüzeyler nokta bulutunun seyrek yerlerinden
# sızıp koyu benek kümeleri yapıyordu (ağaçta da kurtta da görüldü).
view = np.zeros(3, dtype=np.float64)
view[dax] = sgn                 # kameradan sahneye doğru bakış vektörü
facing = -(nrm @ view)          # >0 ise yüz bize dönük
ok &= facing > 0.12

px, py, depth, uv, nrm = px[ok], py[ok], depth[ok], uv[ok], nrm[ok]

# --------------------------------------------------- z-buffer
flat = py.astype(np.int64) * SUPER + px
order = np.lexsort((-depth, flat))      # aynı piksel: uzak -> yakın
flat, depth, uv, nrm = flat[order], depth[order], uv[order], nrm[order]

zbuf = np.full(SUPER * SUPER, np.inf, dtype=np.float32)
ubuf = np.zeros((SUPER * SUPER, 2), dtype=np.float32)
nbuf = np.zeros((SUPER * SUPER, 3), dtype=np.float32)
# son yazan kazanır; sıralama uzak->yakın olduğu için en yakın son yazar
zbuf[flat] = depth
ubuf[flat] = uv
nbuf[flat] = nrm

mask = np.isfinite(zbuf).reshape(SUPER, SUPER)
zimg = np.where(np.isfinite(zbuf), zbuf, 0.0).reshape(SUPER, SUPER)
uimg = ubuf.reshape(SUPER, SUPER, 2)
nimg = nbuf.reshape(SUPER, SUPER, 3)

# --------------------------------------------------- doku örnekle
u = np.clip(uimg[..., 0], 0, 1)
v = np.clip(1.0 - uimg[..., 1], 0, 1)      # glTF: v ters
tx = np.clip((u * (tw - 1)).astype(np.int32), 0, tw - 1)
ty = np.clip((v * (th - 1)).astype(np.int32), 0, th - 1)
albedo = TEX[ty, tx]

# --------------------------------------------------- TOON gölge
L = np.array([-0.35, 0.62, 0.70], dtype=np.float32)
L /= np.linalg.norm(L)
ndl = np.clip((nimg * L).sum(axis=2), 0.0, 1.0)

# üç bant — cel gölgeleme, ama bantlar YUMUŞAK (sert cel fazla grafik durur)
band = np.full_like(ndl, 0.84)
band = np.where(ndl > 0.32, 0.94, band)
band = np.where(ndl > 0.66, 1.04, band)
band = band * 0.90 + (0.55 + 0.45 * ndl) * 0.10       # hafif yumuşatma

rgb = np.clip(albedo * band[..., None], 0.0, 1.0)

# --------------------------------------------------- KONTUR
def dilate(m, r=1):
    out = m.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            out |= np.roll(np.roll(m, dy, 0), dx, 1)
    return out

# dış siluet
edge_out = dilate(mask, 2) & (~mask)
# iç derinlik kırılmaları
z = np.where(mask, zimg, np.nan)
gx = np.abs(np.diff(z, axis=1, prepend=z[:, :1]))
gy = np.abs(np.diff(z, axis=0, prepend=z[:1, :]))
grad = np.nan_to_num(np.maximum(gx, gy))
thr = np.nanpercentile(grad[mask], 99.0) if mask.any() else 1.0
edge_in = mask & (grad > thr)

INK = np.array([0.09, 0.07, 0.06], dtype=np.float32)   # sıcak koyu kahve, saf siyah değil
rgb = np.where(edge_in[..., None], INK, rgb)

alpha = mask.astype(np.float32)
# dış konturu alfaya kat
rgb = np.where((edge_out & dilate(mask, 2))[..., None], INK, rgb)
alpha = np.maximum(alpha, (edge_out & dilate(mask, 2)).astype(np.float32))

# ------------------------------------------- RENK DÜZELTME (HSV)
def rgb2hsv(a):
    mx = a.max(axis=-1); mn = a.min(axis=-1); d = mx - mn
    s = np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0.0)
    i = a.argmax(axis=-1); dd = np.maximum(d, 1e-6)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    h = np.where(i == 0, ((g - b) / dd) % 6,
        np.where(i == 1, (b - r) / dd + 2, (r - g) / dd + 4)) * 60.0
    h = np.where(d < 1e-6, 0.0, h)
    return h, s, mx

def hsv2rgb(h, s, v):
    h = np.mod(h, 360.0) / 60.0
    i = np.floor(h).astype(np.int32)
    f = h - i
    p = v * (1 - s); q = v * (1 - s * f); t = v * (1 - s * (1 - f))
    i = i % 6
    out = np.zeros(h.shape + (3,), dtype=np.float32)
    for k, (rr, gg, bb) in enumerate(
            [(v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q)]):
        m = i == k
        out[m] = np.stack([rr[m], gg[m], bb[m]], axis=-1)
    return out

body = alpha > 0.5
H, S, V = rgb2hsv(rgb)
renkli = body & (S > 0.08)

# --- 1) TON: mavi ailesi (170-290°) hedefe doğru SIKIŞTIRILIR.
#
# DÜZ DÖNDÜRME KULLANILMAZ — ölçüldü ve GÖZLE yakalandı: gövde 245°,
# göz 195°'deyken hepsini -37° döndürmek gözü 158°'e, yani YEŞİLE
# düşürüyordu. Sayı hedefi tutturuyor ama görüntü bozuluyor.
#
# Sıkıştırma: yeni_ton = hedef + (ton - medyan) * k.  Medyandan UZAK
# olan çok, YAKIN olan az hareket eder; hiçbir ton hedefin öbür
# tarafına geçmez. Burun/kulak gibi SICAK tonlara hiç dokunulmaz.
TON_SIKISTIRMA = 0.40
ton_once = float(np.median(H[renkli])) if renkli.any() else float("nan")
if HEDEF_TON is not None and renkli.any():
    mavi = renkli & (H > 170.0) & (H < 290.0)
    if mavi.any():
        med = float(np.median(H[mavi]))
        H = np.where(mavi, HEDEF_TON + (H - med) * TON_SIKISTIRMA, H)

# --- 2) DOYGUNLUK: HSV üzerinde ölçekle.
# TEK GEÇİŞ YETMİYOR: ölçekleme sonrası eşiğin (0.08) altındaki bazı
# pikseller eşiği aşıp kümeye KATILIYOR ve düşük değerleriyle
# ortalamayı geri çekiyor. Birkaç tur yakınsatıyor.
s_now = float(S[renkli].mean()) if renkli.any() else 0.0
for _ in range(4 if HEDEF_DOYGUNLUK is not None else 0):
    aktif = body & (S > 0.08)
    if not aktif.any():
        break
    s_cur = float(S[aktif].mean())
    if s_cur <= 1e-6:
        break
    S = np.clip(S * (HEDEF_DOYGUNLUK / s_cur), 0.0, 1.0)

# --- 3) PARLAKLIK: GAMA ile (dogrusal olcek kontrasti ezip
# yikiyor; gama koyulari acar, acik alanlari korur).
parlak_once = float(V[body].mean()) if body.any() else 0.0
if HEDEF_PARLAK is not None and body.any() and parlak_once > 1e-6:
    lo_g, hi_g = 0.2, 3.0
    for _ in range(24):
        g = 0.5 * (lo_g + hi_g)
        m = float(np.power(V[body], g).mean())
        if m > HEDEF_PARLAK:
            lo_g = g
        else:
            hi_g = g
    V = np.clip(np.power(V, 0.5 * (lo_g + hi_g)), 0.0, 1.0)
parlak_sonra = float(V[body].mean()) if body.any() else 0.0

rgb = np.where(body[..., None], hsv2rgb(H, S, V), rgb)
rgb = np.where(edge_in[..., None] | (edge_out & dilate(mask, 2))[..., None],
               INK, rgb)                      # kontur düzeltmeden etkilenmesin

H2, S2, _ = rgb2hsv(rgb)
r2 = body & (S2 > 0.08)
s_after = float(S2[r2].mean()) if r2.any() else 0.0
ton_sonra = float(np.median(H2[r2])) if r2.any() else float("nan")

# --------------------------------------------------- kaydet + ölç
def to_img(arr, a, size):
    im = Image.fromarray(
        np.dstack([np.clip(arr, 0, 1) * 255,
                   np.clip(a, 0, 1) * 255]).astype(np.uint8), "RGBA")
    return im.resize((size, size), Image.LANCZOS)

big = to_img(rgb, alpha, FINAL)
big.save(f"{OUT}_{FINAL}.png")
tile = to_img(rgb, alpha, TILE)
tile.save(f"{OUT}_{TILE}.png")
grey = tile.convert("LA")
grey.save(f"{OUT}_{TILE}_gri.png")

def olc(im):
    a = np.asarray(im.convert("RGBA"), dtype=np.float32) / 255.0
    m = a[..., 3] > 0.5
    if m.sum() == 0:
        return None
    c = a[..., :3][m]
    mx = c.max(axis=1); mn = c.min(axis=1)
    s = np.where(mx > 1e-6, (mx - mn) / np.maximum(mx, 1e-6), 0.0)
    mxi = c.argmax(axis=1); d = np.maximum(mx - mn, 1e-6)
    h = np.where(mxi == 0, ((c[:, 1] - c[:, 2]) / d) % 6,
        np.where(mxi == 1, (c[:, 2] - c[:, 0]) / d + 2,
                           (c[:, 0] - c[:, 1]) / d + 4)) * 60.0
    hv = h[s > 0.08]
    return (float(np.median(hv)) if hv.size else float("nan"),
            float(s.mean()), float(mx.mean()), float(m.mean()))

print(f"ucgen        : {len(mesh.faces):,}")
print(f"ornek        : {NPTS:,}  kapsanan piksel: {int(mask.sum()):,}")
print(f"doygunluk    : {s_now:.3f} -> {s_after:.3f}  (hedef {HEDEF_DOYGUNLUK})")
print(f"ton          : {ton_once:.0f} -> {ton_sonra:.0f}  (hedef {HEDEF_TON})")
print(f"parlaklik    : {parlak_once:.3f} -> {parlak_sonra:.3f}  (hedef {HEDEF_PARLAK})")
for ad, im in ((f"{FINAL}px", big), (f"{TILE}px", tile)):
    r = olc(im)
    if r:
        print(f"{ad:<12} : ton {r[0]:3.0f}  doyg {r[1]:.3f}  parlak {r[2]:.3f}  doluluk %{100*r[3]:.1f}")
print("cikti: " + ", ".join([f"{OUT}_{FINAL}.png", f"{OUT}_{TILE}.png", f"{OUT}_{TILE}_gri.png"]))
