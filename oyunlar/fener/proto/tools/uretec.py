#!/usr/bin/env python3
"""Fener bölüm üreteci (tersine kurulum) + zorluk ölçer. Dönüş 90° (kilitli).

Şartname: oyunlar/fener/tasarim_notlari.md bölüm 3 ve 4 · DURUM.md İŞ 3, İŞ 4.
  GÜZEL IŞIK YOLU → yem ayna → yanlış kolu derinleştir → kestirmeye kaya →
  aynaları yanlış çevir → çözücüyle doğrula → zorluk + kalite ölç → ELE / TUT

Çalıştır (proto klasöründen):
  python tools/uretec.py <deneme> <tohum>        → İŞ 3: 7x12, 10 bölüm, levels_uretilen.gd
  python tools/uretec.py <deneme> <tohum> is4    → İŞ 4: 8x14, bölücü, 8 bölüm, levels_uretilen_4.gd
  python tools/uretec.py <deneme> <tohum> is11   → İŞ 11: 7x12, kaynak üstte/aşağı, 20 bölüm, levels_uretilen_11.gd
Harita harfleri levels.gd ile aynı: F T R M N b s Y .  (Y = ışık bölücü)

NOT: İŞ 4'te çözücü çok kollu oldu; metrikler İŞ 3 bölümlerinde birebir aynı
çıkıyor (doğrulandı), ama ölü kolların sırası değiştiği için İŞ 3 komutu
kurucunun oynadığı levels_uretilen.gd'yi artık birebir üretmiyor. O dosyanın
aslı git'te (commit 60580e4); üzerine yazma.
"""
import math
import random
import sys

W, H = 7, 12  # İŞ 4 modunda 8x14
# İŞ 11: kaynak ızgaranın ÜSTÜNDE (diyorama feneri); F hücresi boş su, ışın geçer.
# Kaynak hep üst satır, yön aşağı; sütun TOP_COLS içinden (levha ±2 hücre kayar).
TOP_SOURCE = False
TOP_COLS = range(1, 6)
DIRS = {'D': (0, 1), 'U': (0, -1), 'L': (-1, 0), 'R': (1, 0)}


def refl(step, dx, dy):
    """step 1 = '\\' , 3 = '/' (mirror.gd ile aynı)."""
    return (dy, dx) if step == 1 else (-dy, -dx)


def step_for(dx, dy, ndx, ndy):
    for s in (1, 3):
        if refl(s, dx, dy) == (ndx, ndy):
            return s
    raise ValueError('dönüş değil')


def inside(x, y):
    return 0 <= x < W and 0 <= y < H


def near(p, q):
    return max(abs(p[0] - q[0]), abs(p[1] - q[1])) == 1


# --- çözücü + zorluk ölçer ----------------------------------------------------
# Işın çok kollu olabilir: bölücü (Y) gelen ışını durdurur, sağına ve soluna
# iki kol çıkarır. Bölüm, BÜTÜN tekneler ışık alınca biter.

class Level:
    def __init__(self, grid, fener, yon, boats):
        self.grid = grid      # {(x,y): harf}
        self.fener = fener
        self.yon = yon
        self.boats = list(boats)

    def rotatables(self):
        return [p for p, c in self.grid.items() if c in 'MN']

    def has_split(self):
        return 'Y' in self.grid.values()

    def start(self):
        return {p: (1 if self.grid[p] == 'M' else 3) for p in self.rotatables()}

    def trace(self, assign):
        """Tam atama ile tüm kolları izler → (bütün_tekneler, iz)."""
        seen, trail, lit = set(), [], set()
        dx, dy = DIRS[self.yon]
        stack = [(self.fener[0], self.fener[1], dx, dy)]
        while stack:
            x, y, dx, dy = stack.pop()
            while True:
                x += dx; y += dy
                if not inside(x, y) or (x, y, dx, dy) in seen:
                    break
                seen.add((x, y, dx, dy))
                trail.append((x, y, dx, dy))
                c = self.grid.get((x, y), '.')
                if c == 'T':
                    lit.add((x, y)); break
                if c == 'R' or (c == 'F' and not TOP_SOURCE):
                    break
                if c == 'Y':
                    stack.append((x, y, dy, dx)); stack.append((x, y, -dy, -dx)); break
                if c in 'bs':
                    dx, dy = refl(1 if c == 'b' else 3, dx, dy)
                elif c in 'MN':
                    dx, dy = refl(assign[(x, y)], dx, dy)
        return lit == set(self.boats), trail

    def solve(self):
        """İnsan gibi ışını takip eden DFS: bir kol kararsız bir aynaya varınca
        dallanır. Tüm ağacı gezer (çözüm sayısı, geri dönüş, near-miss)."""
        st = {'expanded': 0, 'solutions': [], 'near': 0, 'touched': set(),
              'backtrack': 0, 'dead': []}
        boats = set(self.boats)

        def run(assign, stack, seen, lit, trail):
            # dönüş: (yükseklik, çözüm_var). deaths: son karardan sonraki ölümler
            stack = list(stack)
            deaths = []
            while stack:
                x, y, dx, dy, since = stack.pop()
                while True:
                    x += dx; y += dy
                    if not inside(x, y) or (x, y, dx, dy) in seen:
                        deaths.append(trail[since:]); break
                    seen.add((x, y, dx, dy))
                    trail.append((x, y, dx, dy))
                    c = self.grid.get((x, y), '.')
                    if c == 'T':
                        lit = lit | {(x, y)}; break
                    if c == 'R' or (c == 'F' and not TOP_SOURCE):
                        deaths.append(trail[since:]); break
                    if c == 'Y':
                        n = len(trail)
                        stack.append((x, y, dy, dx, n)); stack.append((x, y, -dy, -dx, n))
                        break
                    if c in 'bs':
                        dx, dy = refl(1 if c == 'b' else 3, dx, dy)
                    elif c in 'MN':
                        st['touched'].add((x, y))
                        if (x, y) in assign:
                            dx, dy = refl(assign[(x, y)], dx, dy)
                            continue
                        st['dead'].extend(deaths)
                        st['expanded'] += 1
                        res = []
                        for s in (1, 3):
                            a2 = dict(assign); a2[(x, y)] = s
                            ndx, ndy = refl(s, dx, dy)
                            res.append(run(a2, stack + [(x, y, ndx, ndy, len(trail))],
                                           set(seen), lit, list(trail)))
                        (h1, ok1), (h2, ok2) = res
                        if ok1 != ok2:  # yanlış kol: oyuncu kaç karar geri döner
                            st['backtrack'] = max(st['backtrack'], 1 + (h2 if ok1 else h1))
                        return 1 + max(h1, h2), ok1 or ok2
            st['dead'].extend(deaths)
            if lit == boats:
                st['solutions'].append((dict(assign), list(trail)))
                return 0, True
            unlit = boats - lit
            for d in deaths:  # ışın sönmemiş tekneyi sıyırıp ölüyor
                if any(near((x, y), b) for x, y, _, _ in d for b in unlit):
                    st['near'] += 1
            return 0, False

        dx, dy = DIRS[self.yon]
        run({}, [(self.fener[0], self.fener[1], dx, dy, 0)], set(), frozenset(), [])
        return st

    def metrics(self):
        st = self.solve()
        sols = st['solutions']
        rot = self.rotatables()
        m = {'solution_count': len(sols), 'rotatable': len(rot), 'split': self.has_split()}
        if not sols:
            return m
        start = self.start()
        assign, trail = min(sols, key=lambda s: sum(start[p] != v for p, v in s[0].items()))
        m['solution_toggles'] = sum(start[p] != v for p, v in assign.items())
        m['solution_reflections'] = sum(1 for x, y, _, _ in trail
                                        if self.grid.get((x, y), '.') in 'MNbs')
        m['relevant_mirrors'] = len(assign)
        m['irrelevant_mirrors'] = len([p for p in rot if p not in st['touched']])
        m['expanded_states'] = st['expanded']
        m['max_backtrack'] = st['backtrack']
        m['near_misses'] = st['near']
        cells = {}
        for x, y, dx, dy in trail:
            cells.setdefault((x, y), set()).add('h' if dx else 'v')
        m['beam_crossings'] = sum(1 for p, a in cells.items()
                                  if len(a) == 2 and self.grid.get(p, '.') == '.')
        # aha: çözüm ışığı teknelerden önce uzaklaştırıyor mu (Manhattan, ≥2 hücre)
        def dist(p):
            return min(abs(p[0] - b[0]) + abs(p[1] - b[1]) for b in self.boats)
        m['aha'] = max(dist((x, y)) for x, y, _, _ in trail) - dist(self.fener) >= 2
        m['start_solved'] = self.trace(start)[0]
        return m

    def rows(self):
        return [''.join(self.grid.get((x, y), '.') for x in range(W)) for y in range(H)]


# --- üreteç -------------------------------------------------------------------

def seg_ok(x, y, dx, dy, L, used):
    """L adımlık parça geçerli mi (walk ile aynı kurallar, yazmadan)."""
    for k in range(1, L + 1):
        px, py = x + dx * k, y + dy * k
        if not inside(px, py):
            return False
        u = used.get((px, py))
        if k == L:
            if u is not None:
                return False
        elif u is not None and not (u in ('h', 'v') and u != ('h' if dx else 'v')):
            return False
    return True


def seg_write(x, y, dx, dy, L, used):
    axis = 'h' if dx else 'v'
    for k in range(1, L):
        p = (x + dx * k, y + dy * k)
        used[p] = axis if p not in used else 'hv'
    used[(x + dx * L, y + dy * L)] = 'X'
    return x + dx * L, y + dy * L


def walk_smart(rng, x, y, dx, dy, n_turns, used, first_min):
    """walk ile aynı sözleşme; ama sadece geçerli uzunluk/yön arasından seçer
    (İŞ 4: 8x14'te rastgele yürüyüş %96 boşa gidiyordu)."""
    turns = []
    for i in range(n_turns + 1):
        Ls = [L for L in range(first_min if i == 0 else 1, 6) if seg_ok(x, y, dx, dy, L, used)]
        if i < n_turns:  # köşeden sonra en az bir yöne 1 adım gidilebilmeli
            Ls = [L for L in Ls if any(
                seg_ok(x + dx * L, y + dy * L, ndx, ndy, 1, {**used, (x + dx * L, y + dy * L): 'X'})
                for ndx, ndy in ((dy, dx), (-dy, -dx)))]
        if not Ls:
            return None
        x, y = seg_write(x, y, dx, dy, rng.choice(Ls), used)
        if i == n_turns:
            return turns, (x, y), (dx, dy)
        opts = [(ndx, ndy) for ndx, ndy in ((dy, dx), (-dy, -dx))
                if seg_ok(x, y, ndx, ndy, 1, used)]
        ndx, ndy = rng.choice(opts)
        turns.append(((x, y), step_for(dx, dy, ndx, ndy)))
        dx, dy = ndx, ndy
    return None


def walk(rng, x, y, dx, dy, n_turns, used, first_min, smart=False):
    """(x,y)'den (dx,dy) yönüyle n_turns dönüşlü yol; köşeler ve bitiş taze hücre,
    geçilen hücrede sadece dik kesişme. → (köşeler[(p, adım)], bitiş, son yön) ya da None"""
    if smart:
        return walk_smart(rng, x, y, dx, dy, n_turns, used, first_min)
    turns = []
    for i in range(n_turns + 1):
        L = rng.randint(first_min if i == 0 else 1, 5)
        for k in range(L):
            x += dx; y += dy
            if not inside(x, y):
                return None
            u = used.get((x, y))
            axis = 'h' if dx else 'v'
            if k == L - 1:  # köşe ya da bitiş
                if u is not None:
                    return None
                used[(x, y)] = 'X'
            elif u is None:
                used[(x, y)] = axis
            elif u in 'hv' and u != axis:
                used[(x, y)] = 'hv'  # dik kesişme
            else:
                return None
        if i == n_turns:
            return turns, (x, y), (dx, dy)
        ndx, ndy = rng.choice([(dy, dx), (-dy, -dx)])
        turns.append(((x, y), step_for(dx, dy, ndx, ndy)))
        dx, dy = ndx, ndy
    return None


def make_path(rng, turns_rng, split, smart=False):
    """Fenerden tekne(ler)e güzel bir ışık yolu. split: gövde → bölücü → iki kol
    → iki tekne. → (fener, yon, köşeler, bölücü|None, tekneler, geçilen)"""
    if TOP_SOURCE:
        fx, fy, yon = rng.choice(list(TOP_COLS)), 0, 'D'
    else:
        fx, fy = rng.randrange(W), rng.randrange(H)
        yon = rng.choice('DULR')
    dx, dy = DIRS[yon]
    used = {(fx, fy): 'X'}
    if not split:
        r = walk(rng, fx, fy, dx, dy, rng.randint(*turns_rng), used, 2, smart)
        if r is None:
            return None
        return (fx, fy), yon, r[0], None, [r[1]], used
    r = walk(rng, fx, fy, dx, dy, rng.randint(1, 4), used, 2, smart)
    if r is None:
        return None
    turns, sp, (vx, vy) = r  # bölücüye varış yönü
    boats = []
    for adx, ady in ((vy, vx), (-vy, -vx)):  # iki kol: sağ ve sol
        a = walk(rng, sp[0], sp[1], adx, ady, rng.randint(2, 5), used, 1, smart)
        if a is None:
            return None
        turns += a[0]
        boats.append(a[1])
    return (fx, fy), yon, turns, sp, boats, used


def generate(rng, split=False, turns_rng=(3, 9), wrong_p=0.8, fixed_p=0.2, smart=False):
    p = make_path(rng, turns_rng, split, smart)
    if p is None:
        return None, 'yol kurulamadı'
    fener, yon, turns, sp, boats, used = p
    grid = {}
    intended = {}
    for pos, s in turns:
        if rng.random() < fixed_p:
            grid[pos] = 'b' if s == 1 else 's'
        else:
            grid[pos] = 'M'
            intended[pos] = s
    if len(intended) < 2:
        return None, 'döner ayna < 2'
    # tekneler birbirine ve fenere komşu olmasın (gövdeler üst üste biniyordu)
    spots = [fener] + boats
    if any(max(abs(p[0] - q[0]), abs(p[1] - q[1])) < 2
           for i, p in enumerate(spots) for q in spots[i + 1:]):
        return None, 'tekne sıkışık'
    grid[fener] = 'F'
    for b in boats:
        grid[b] = 'T'
    if sp:
        grid[sp] = 'Y'
    lv = Level(grid, fener, yon, boats)
    if not lv.trace({**{q: 1 for q in lv.rotatables()}, **intended})[0]:
        return None, 'yol kendini kesti'

    # yem ayna: doğru aynanın YANLIŞ kolundaki ışının üstüne
    for _ in range(rng.randint(1, 3)):
        pos, s = rng.choice(list(intended.items()))
        ok, trail = lv.trace({**{q: 1 for q in lv.rotatables()}, **intended})
        inc = next(((dx, dy) for x, y, dx, dy in trail if (x, y) == pos), None)
        if inc is None:
            continue
        # iz, hücreye VARIŞ yönünü tutar; yanlış kol = öteki çaprazdan çıkış
        odx, ody = refl(3 if s == 1 else 1, *inc)
        cand = []
        x, y = pos
        for k in range(1, 6):
            x += odx; y += ody
            if not inside(x, y) or (x, y) in lv.grid:
                break
            if k >= 2 and (x, y) not in used:
                cand.append((x, y))
        if cand:
            lv.grid[rng.choice(cand)] = rng.choice('MN')

    # yanlış kolları derinleştir: ölü bir kolun son parçasına yeni yem ayna.
    # Oyuncu yanlış yolda birkaç karar ilerleyip sonra ölür (max_backtrack ↑)
    for _ in range(rng.randint(0, 3)):
        dead = [t for t in lv.solve()['dead'] if len(t) >= 2]
        if not dead:
            break
        t = rng.choice(dead)
        cand = [(x, y) for x, y, _, _ in t[1:]
                if (x, y) not in used and (x, y) not in lv.grid]
        if cand:
            lv.grid[rng.choice(cand)] = rng.choice('MN')

    # kestirmeleri kapat: amaçlanan dışındaki her çözüm izine kaya
    for _ in range(12):
        st = lv.solve()
        alts = [t for a, t in st['solutions']
                if any(a.get(q) != v for q, v in intended.items())]
        if not alts:
            break
        spots = [(x, y) for x, y, _, _ in alts[0]
                 if (x, y) not in used and lv.grid.get((x, y), '.') == '.']
        if not spots:
            return None, 'kestirme kapatılamadı'
        # tekneye en yakın noktaya koy: kaçış yolu teknenin dibinde ölsün (near-miss)
        spots.sort(key=lambda q: min(abs(q[0] - b[0]) + abs(q[1] - b[1]) for b in boats))
        lv.grid[spots[0]] = 'R'
    else:
        return None, 'kestirme kapatılamadı'

    # aynaları çoğunlukla yanlış yöne çevir; yemler rastgele
    for q in lv.rotatables():
        if q in intended:
            wrong = rng.random() < wrong_p
            s = (3 if intended[q] == 1 else 1) if wrong else intended[q]
        else:
            s = rng.choice((1, 3))
        lv.grid[q] = 'M' if s == 1 else 'N'
    if lv.trace(lv.start())[0]:
        q = rng.choice(list(intended))
        lv.grid[q] = 'N' if intended[q] == 1 else 'M'
    return lv, None


# --- kalite filtresi (tasarım notları 4) --------------------------------------

def signature(lv):
    return {p for p, c in lv.grid.items() if c in 'MNbsRY'}


def quality(lv, m, accepted):
    """İlk takıldığı ölçütü döndürür; geçerse None."""
    if m['solution_count'] == 0:
        return 'çözülemiyor'
    if m['start_solved']:
        return 'başta çözülü'
    if m['solution_count'] != 1:
        return 'benzersiz final değil'
    if m['relevant_mirrors'] < 0.7 * m['rotatable']:
        return 'kullanılan döner ayna < %70'
    if m['irrelevant_mirrors'] > 1:
        return 'gereksiz ayna > 1'
    if not 1 <= m['near_misses'] <= 3:
        return 'near-miss 1-3 dışı'
    if m['beam_crossings'] > 2:
        return 'kesişme > 2'
    if not 3 <= m['solution_reflections'] <= 9:
        return 'yansıma 3-9 dışı'
    sig = signature(lv)
    for other in accepted[-10:]:
        o = signature(other)
        if len(sig & o) / max(1, len(sig | o)) > 0.4:
            return 'son 10 bölüme benzer'
    return None


def hard(m):
    """İŞ 4 zor eşiği; ilk takılan ölçüt ya da None."""
    if m['max_backtrack'] < 4:
        return 'geri dönüş < 4'
    if m['solution_toggles'] < 6:
        return 'çevirme < 6'
    if not 2 <= m['near_misses'] <= 3:
        return 'near-miss 2-3 dışı'
    if not m['aha']:
        return 'aha yok'
    return None


def scores(pool):
    """%30 arama · %25 geri dönüş · %20 çevirme · %15 yansıma · %10 near-miss,
    havuzda 0-1 normalize; aha bonusu +0.1, sonra yeniden 0-1."""
    keys = [('expanded_states', 0.30, lambda v: math.log2(1 + v)),
            ('max_backtrack', 0.25, float),
            ('solution_toggles', 0.20, float),
            ('solution_reflections', 0.15, float),
            ('near_misses', 0.10, float)]
    raw = [[f(m[k]) for k, _, f in keys] for _, m in pool]
    lo = [min(r[i] for r in raw) for i in range(len(keys))]
    hi = [max(r[i] for r in raw) for i in range(len(keys))]
    out = []
    for (lv, m), r in zip(pool, raw):
        s = sum(w * ((r[i] - lo[i]) / (hi[i] - lo[i]) if hi[i] > lo[i] else 0.0)
                for i, (_, w, _) in enumerate(keys))
        out.append(s + (0.1 if m['aha'] else 0.0))
    a, b = min(out), max(out)
    return [(s - a) / (b - a) if b > a else 0.0 for s in out]


def pick(pool, sc):
    """3 kolay · 4 orta · 3 zor. Kolay/orta: alt ve orta üçte birden eşit
    aralıkla; zor: havuzun en zor 3'ü (derin bölümler az, üst üçte bir sulanıyor)."""
    order = sorted(range(len(pool)), key=lambda i: sc[i])
    n = len(order)
    thirds = [order[:n // 3], order[n // 3: 2 * n // 3], order[-3:]]
    chosen = []
    for part, k, ad in zip(thirds, (3, 4, 3), ('kolay', 'orta', 'zor')):
        idx = [part[round(j * (len(part) - 1) / max(1, k - 1))] for j in range(k)]
        chosen += [(i, ad) for i in dict.fromkeys(idx)]
    return chosen


MKEYS = ('solution_toggles', 'solution_reflections', 'relevant_mirrors',
         'irrelevant_mirrors', 'expanded_states', 'max_backtrack',
         'near_misses', 'beam_crossings', 'aha')


def write_gd(path, items, cmd):
    lines = ['extends RefCounted',
             '## ÜRETİLDİ — elle düzenleme. Yeniden yazmak için (proto klasöründen):',
             '##   ' + cmd,
             '## Harita harfleri levels.gd ile aynı.', '', 'const ALL := [']
    for lv, m, sc, ad in items:
        lines.append('\t{"yon": "%s", "zorluk": %.2f, "sinif": "%s", "map": [' % (lv.yon, sc, ad))
        lines.append('\t\t# ' + ' · '.join('%s=%s' % (k, m[k]) for k in MKEYS))
        for r in lv.rows():
            lines.append('\t\t"%s",' % r)
        lines.append('\t]},')
    lines.append(']')
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


def line(n, ad, s, m):
    return ('  %-4s %-9s zorluk=%.2f çevir=%d yansıma=%d ayna=%d/%d arama=%d geri=%d near=%d kesişme=%d aha=%s'
            % (n, ad, s, m['solution_toggles'], m['solution_reflections'],
               m['relevant_mirrors'], m['rotatable'], m['expanded_states'],
               m['max_backtrack'], m['near_misses'], m['beam_crossings'], m['aha']))


def run_pool(rng, tries, gen_kwargs_fn, label):
    reasons, accepted, pool = {}, [], []
    produced = 0
    for _ in range(tries):
        lv, why = generate(rng, **gen_kwargs_fn())
        if lv is None:
            k = '(üretilemedi) ' + why
            reasons[k] = reasons.get(k, 0) + 1
            continue
        produced += 1
        m = lv.metrics()
        why = quality(lv, m, accepted)
        if why:
            reasons[why] = reasons.get(why, 0) + 1
            continue
        accepted.append(lv)
        pool.append((lv, m))
    print('[%s] deneme=%d · üretilen bölüm=%d · filtreden geçen=%d · elenen=%d'
          % (label, tries, produced, len(pool), produced - len(pool)))
    for k, v in sorted(reasons.items(), key=lambda kv: -kv[1]):
        print('  %6d  %s' % (v, k))
    return pool


def main_is3(tries, seed):
    rng = random.Random(seed)
    pool = run_pool(rng, tries, lambda: {}, 'İŞ 3')
    if len(pool) < 10:
        print('HATA: havuz 10dan küçük'); sys.exit(1)
    sc = scores(pool)
    items = [(pool[i][0], pool[i][1], sc[i], ad) for i, ad in pick(pool, sc)]
    write_gd('levels_uretilen.gd', items, 'python tools/uretec.py %d %d' % (tries, seed))
    print('seçilen 10:')
    for n, (lv, m, s, ad) in enumerate(items, 1):
        print(line('U%d' % n, ad, s, m))


def main_is4(tries, seed):
    """8x14. Yarı deneme bölücülü, yarı bölücüsüz (uzun yol, %90 yanlış başlangıç).
    Seçim: 4 bölücülü + 4 bölücüsüz, zor eşiğini geçenlerden en yüksek puanlılar."""
    global W, H
    W, H = 8, 14
    rng = random.Random(seed)
    plain = run_pool(rng, tries // 2, lambda: {'turns_rng': (5, 10), 'wrong_p': 0.9, 'smart': True}, 'bölücüsüz')
    split = run_pool(rng, tries // 2, lambda: {'split': True, 'wrong_p': 0.9, 'smart': True}, 'bölücülü')
    pool = plain + split
    sc = scores(pool)
    print('zor eşiği (geri ≥4 · çevir ≥6 · near 2-3 · aha):')
    chosen = []
    for lab, lo, hi in (('bölücülü', len(plain), len(pool)), ('bölücüsüz', 0, len(plain))):
        why = {}
        ok = []
        for i in range(lo, hi):
            w = hard(pool[i][1])
            if w:
                why[w] = why.get(w, 0) + 1
            else:
                ok.append(i)
        print('  %-9s havuz=%d · zor eşiğini geçen=%d · takılan: %s'
              % (lab, hi - lo, len(ok), ', '.join('%s %d' % kv for kv in
                                                   sorted(why.items(), key=lambda kv: -kv[1]))))
        ok.sort(key=lambda i: -sc[i])
        picked = []
        for i in ok:  # birbirine benzemesin
            if all(len(signature(pool[i][0]) & signature(pool[j][0]))
                   / max(1, len(signature(pool[i][0]) | signature(pool[j][0]))) <= 0.4
                   for j in picked):
                picked.append(i)
            if len(picked) == 4:
                break
        if len(picked) < 4:
            print('  UYARI: %s için 4 zor bölüm yok (%d)' % (lab, len(picked)))
        chosen += [(i, lab) for i in picked]
        br = [pool[i][1]['max_backtrack'] for i in range(lo, hi)]
        print('  %-9s havuz ortalama geri dönüş=%.2f · en yüksek=%d'
              % (lab, sum(br) / max(1, len(br)), max(br, default=0)))
    chosen.sort(key=lambda t: sc[t[0]])  # kolaydan zora
    items = [(pool[i][0], pool[i][1], sc[i], ad) for i, ad in chosen]
    write_gd('levels_uretilen_4.gd', items, 'python tools/uretec.py %d %d is4' % (tries, seed))
    print('seçilen %d:' % len(items))
    for n, (lv, m, s, ad) in enumerate(items, 1):
        print(line('Z%d' % n, ad, s, m))


def main_is11(tries, seed):
    """İŞ 11: 7x12, kaynak üst satırda / aşağı, sütun 1-5. Filtre ve zor eşiği
    İŞ 3-4 ile aynı. Seçim: 10 orta + 10 zor (bölücülü dahil), sütun başına en
    çok 4, birbirine benzemez. Kolay 5 = levels.gd'deki elle bölümler."""
    global TOP_SOURCE
    TOP_SOURCE = True
    rng = random.Random(seed)
    plain = run_pool(rng, tries // 2, lambda: {'turns_rng': (4, 9), 'wrong_p': 0.9, 'smart': True}, 'bölücüsüz')
    split = run_pool(rng, tries // 2, lambda: {'split': True, 'wrong_p': 0.9, 'smart': True}, 'bölücülü')
    pool = plain + split
    sc = scores(pool)
    is_split = lambda i: i >= len(plain)
    col = lambda i: pool[i][0].fener[0]
    chosen, cols = [], {}

    def take(cands, n, label, need_split=0):
        got, nsplit = [], 0
        for phase in ((True, False) if need_split else (None,)):
            for i in cands:
                if len(got) == n or (phase is True and nsplit >= need_split):
                    break
                if phase is True and not is_split(i):
                    continue
                if i in [c for c, _ in chosen] or i in got or cols.get(col(i), 0) >= 4:
                    continue
                sig = signature(pool[i][0])
                if any(len(sig & signature(pool[j][0])) / max(1, len(sig | signature(pool[j][0]))) > 0.4
                       for j in got + [c for c, _ in chosen]):
                    continue
                got.append(i)
                cols[col(i)] = cols.get(col(i), 0) + 1
                nsplit += is_split(i)
        chosen.extend((i, label) for i in got)
        return len(got)

    hard_ok = sorted([i for i in range(len(pool)) if not hard(pool[i][1])], key=lambda i: -sc[i])
    print('zor eşiğini geçen: %d (bölücülü %d)' % (len(hard_ok), sum(map(is_split, hard_ok))))
    n_zor = take(hard_ok, 10, 'zor', need_split=3)
    # orta: zorluk 0.35 → 0.75 arası eşit aralıklı 10 hedef, her hedefe en yakın
    # uygun bölüm (havuz 0.38 civarına yığılıyor; zora sıçrama olmasın). İlk 2
    # hedefte bölücülü tercih edilir (bölücü öğretimi zordan önce gelsin)
    rest = [i for i in range(len(pool)) if i not in hard_ok]
    n_orta = 0
    for j in range(10):
        t = 0.35 + j * 0.4 / 9
        near_t = sorted(rest, key=lambda i: abs(sc[i] - t))
        if j in (3, 6):
            near_t = [i for i in near_t if is_split(i)][:40] + near_t
        n_orta += take(near_t, 1, 'orta')
    print('seçilen: orta %d · zor %d' % (n_orta, n_zor))
    chosen.sort(key=lambda t: sc[t[0]])
    items = [(pool[i][0], pool[i][1], sc[i], ad) for i, ad in chosen]
    write_gd('levels_uretilen_11.gd', items, 'python tools/uretec.py %d %d is11' % (tries, seed))
    for n, (lv, m, s, ad) in enumerate(items, 1):
        print(line('K%d' % n, ad, s, m) + ' sütun=%d bölücü=%s' % (lv.fener[0], lv.has_split()))
    dist = {}
    for lv, *_ in items:
        dist[lv.fener[0]] = dist.get(lv.fener[0], 0) + 1
    print('kaynak sütunu dağılımı:', dict(sorted(dist.items())))


if __name__ == '__main__':
    tries = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    if len(sys.argv) > 3 and sys.argv[3] == 'is4':
        main_is4(tries, seed)
    elif len(sys.argv) > 3 and sys.argv[3] == 'is11':
        main_is11(tries, seed)
    else:
        main_is3(tries, seed)
