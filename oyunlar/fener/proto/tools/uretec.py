#!/usr/bin/env python3
"""Fener bölüm üreteci (tersine kurulum) + zorluk ölçer. Dönüş 90° (kilitli).

Şartname: oyunlar/fener/tasarim_notlari.md bölüm 3 ve 4.
  GÜZEL IŞIK YOLU → yem ayna → kestirmeleri kayayla kapat → aynaları yanlış
  çevir → çözücüyle doğrula → zorluk + kalite ölç → ELE / TUT

Çalıştır (proto klasöründen):  python tools/uretec.py [deneme] [tohum]
Yazar: levels_uretilen.gd (oyun okur) · ekrana rapor.
Harita harfleri levels.gd ile aynı: F T R M N b s .
"""
import math
import random
import sys

W, H = 7, 12
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


# --- çözücü + zorluk ölçer ----------------------------------------------------

class Level:
    def __init__(self, grid, fener, yon, boat):
        self.grid = grid      # {(x,y): harf}
        self.fener = fener
        self.yon = yon
        self.boat = boat

    def rotatables(self):
        return [p for p, c in self.grid.items() if c in 'MN']

    def start(self):
        return {p: (1 if self.grid[p] == 'M' else 3) for p in self.rotatables()}

    def trace(self, assign):
        """Tam atama ile ışını izler → (tekneye_ulaştı, iz)."""
        x, y = self.fener
        dx, dy = DIRS[self.yon]
        seen, trail = set(), []
        while True:
            x += dx; y += dy
            if not inside(x, y) or (x, y, dx, dy) in seen:
                return False, trail
            seen.add((x, y, dx, dy))
            trail.append((x, y, dx, dy))
            c = self.grid.get((x, y), '.')
            if c == 'T':
                return True, trail
            if c in 'RF':
                return False, trail
            if c in 'bs':
                dx, dy = refl(1 if c == 'b' else 3, dx, dy)
            elif c in 'MN':
                dx, dy = refl(assign[(x, y)], dx, dy)

    def solve(self):
        """İnsan gibi ışını takip eden DFS: ışın kararsız bir aynaya varınca dallanır.
        Tüm ağacı gezer (çözüm sayısı ve geri dönüş için)."""
        st = {'expanded': 0, 'solutions': [], 'near': 0, 'touched': set(),
              'backtrack': 0}
        bx, by = self.boat

        def run(assign, x, y, dx, dy, seen, trail):
            # dönüş: (yükseklik, çözüm_var)
            since = len(trail)  # near-miss sadece son karardan sonraki parçada
            while True:
                x += dx; y += dy
                if not inside(x, y) or (x, y, dx, dy) in seen:
                    return self._dead(st, trail[since:])
                seen.add((x, y, dx, dy))
                trail.append((x, y, dx, dy))
                c = self.grid.get((x, y), '.')
                if c == 'T':
                    st['solutions'].append((dict(assign), list(trail)))
                    return 0, True
                if c in 'RF':
                    return self._dead(st, trail[since:])
                if c in 'bs':
                    dx, dy = refl(1 if c == 'b' else 3, dx, dy)
                elif c in 'MN':
                    st['touched'].add((x, y))
                    if (x, y) in assign:
                        dx, dy = refl(assign[(x, y)], dx, dy)
                    else:
                        st['expanded'] += 1
                        res = []
                        for s in (1, 3):
                            a2 = dict(assign); a2[(x, y)] = s
                            ndx, ndy = refl(s, dx, dy)
                            res.append(run(a2, x, y, ndx, ndy, set(seen), list(trail)))
                        (h1, ok1), (h2, ok2) = res
                        if ok1 != ok2:  # yanlış kol: oyuncu kaç karar geri döner
                            wrong_h = h2 if ok1 else h1
                            st['backtrack'] = max(st['backtrack'], 1 + wrong_h)
                        return 1 + max(h1, h2), ok1 or ok2

        x, y = self.fener
        dx, dy = DIRS[self.yon]
        run({}, x, y, dx, dy, set(), [])
        return st

    def _dead(self, st, trail):
        st.setdefault('dead', []).append(trail)
        bx, by = self.boat
        if any(max(abs(x - bx), abs(y - by)) == 1 for x, y, _, _ in trail):
            st['near'] += 1  # ışın tekneyi sıyırıp ölüyor
        return 0, False

    def metrics(self):
        st = self.solve()
        sols = st['solutions']
        rot = self.rotatables()
        m = {'solution_count': len(sols), 'rotatable': len(rot)}
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
        # aha: çözüm ışığı hedeften önce uzaklaştırıyor mu (Manhattan, ≥2 hücre)
        bx, by = self.boat
        d0 = abs(self.fener[0] - bx) + abs(self.fener[1] - by)
        dmax = max(abs(x - bx) + abs(y - by) for x, y, _, _ in trail)
        m['aha'] = dmax - d0 >= 2
        m['start_solved'] = self.trace(start)[0]
        m['trail'] = trail
        return m

    def rows(self):
        out = []
        for y in range(H):
            r = ''
            for x in range(W):
                if (x, y) == self.fener:
                    r += 'F'
                elif (x, y) == self.boat:
                    r += 'T'
                else:
                    r += self.grid.get((x, y), '.')
            out.append(r)
        return out


# --- üreteç -------------------------------------------------------------------

def make_path(rng):
    """Fenerden tekneye güzel bir ışık yolu: 3-9 dönüş, taze köşeler,
    en fazla 2 dik kesişme. → (fener, yon, köşeler[(p, adım)], tekne, geçilen)"""
    n_turns = rng.randint(3, 9)
    fx, fy = rng.randrange(W), rng.randrange(H)
    yon = rng.choice('DULR')
    dx, dy = DIRS[yon]
    used = {(fx, fy): 'X'}   # hücre → 'X' dolu, 'h'/'v'/'hv' ışın geçti
    turns = []
    x, y = fx, fy
    for i in range(n_turns + 1):
        L = rng.randint(2, 5) if i == 0 else rng.randint(1, 5)
        for k in range(L):
            x += dx; y += dy
            if not inside(x, y):
                return None
            u = used.get((x, y))
            last = k == L - 1
            axis = 'h' if dx else 'v'
            if last:  # köşe ya da tekne: taze hücre olmalı
                if u is not None:
                    return None
                used[(x, y)] = 'X'
            else:
                if u is None:
                    used[(x, y)] = axis
                elif u in 'hv' and u != axis:
                    used[(x, y)] = 'hv'  # dik kesişme
                else:
                    return None
        if i == n_turns:
            return (fx, fy), yon, turns, (x, y), used
        ndx, ndy = rng.choice([(dy, dx), (-dy, -dx)])
        turns.append(((x, y), step_for(dx, dy, ndx, ndy)))
        dx, dy = ndx, ndy
    return None


def generate(rng):
    p = make_path(rng)
    if p is None:
        return None, 'yol kurulamadı'
    fener, yon, turns, boat, used = p
    grid = {}
    intended = {}
    for pos, s in turns:
        if rng.random() < 0.2:
            grid[pos] = 'b' if s == 1 else 's'
        else:
            grid[pos] = 'M'
            intended[pos] = s
    if len(intended) < 2:
        return None, 'döner ayna < 2'
    lv = Level(grid, fener, yon, boat)
    lv.grid[fener] = 'F'
    lv.grid[boat] = 'T'

    # yem ayna: doğru aynanın YANLIŞ kolundaki ışının üstüne
    for _ in range(rng.randint(1, 3)):
        pos, s = rng.choice(list(intended.items()))
        # aynaya hangi yönden gelindiğini bul: yol boyunca izle
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
        dead = [t for t in lv.solve().get('dead', []) if len(t) >= 2]
        if not dead:
            break
        t = rng.choice(dead)
        cand = [(x, y) for x, y, _, _ in t[1:]
                if (x, y) not in used and (x, y) not in lv.grid]
        if cand:
            lv.grid[rng.choice(cand)] = rng.choice('MN')

    # kestirmeleri kapat: amaçlanan dışındaki her çözüm izine kaya
    path_cells = set(used)
    for _ in range(12):
        st = lv.solve()
        alts = [t for a, t in st['solutions']
                if any(a.get(q) != v for q, v in intended.items())]
        if not alts:
            break
        t = alts[0]
        spots = [(x, y) for x, y, _, _ in t
                 if (x, y) not in path_cells and lv.grid.get((x, y), '.') == '.']
        if not spots:
            return None, 'kestirme kapatılamadı'
        # tekneye en yakın noktaya koy: kaçış yolu teknenin dibinde ölsün (near-miss)
        bx, by = boat
        spots.sort(key=lambda q: abs(q[0] - bx) + abs(q[1] - by))
        lv.grid[spots[0]] = 'R'
    else:
        return None, 'kestirme kapatılamadı'

    # aynaları çoğunlukla yanlış yöne çevir; yemler rastgele
    for q in lv.rotatables():
        if q in intended:
            wrong = rng.random() < 0.8
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
    return {p for p, c in lv.grid.items() if c in 'MNbsR'}


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


def scores(pool):
    """%30 arama · %25 geri dönüş · %20 çevirme · %15 yansıma · %10 near-miss,
    havuzda 0-1 normalize; aha bonusu +0.1, sonra yeniden 0-1."""
    keys = [('expanded_states', 0.30, lambda v: math.log2(1 + v)),
            ('max_backtrack', 0.25, float),
            ('solution_toggles', 0.20, float),
            ('solution_reflections', 0.15, float),
            ('near_misses', 0.10, float)]
    raw = []
    for _, m in pool:
        raw.append([f(m[k]) for k, _, f in keys])
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


def write_gd(path, items):
    lines = ['extends RefCounted',
             '## ÜRETİLDİ — elle düzenleme. Yeniden yazmak için (proto klasöründen):',
             '##   python tools/uretec.py <deneme> <tohum>',
             '## Harita harfleri levels.gd ile aynı.', '', 'const ALL := [']
    for lv, m, sc, ad in items:
        lines.append('\t{"yon": "%s", "zorluk": %.2f, "sinif": "%s", "map": [' % (lv.yon, sc, ad))
        lines.append('\t\t# ' + ' · '.join('%s=%s' % (k, m[k]) for k in (
            'solution_toggles', 'solution_reflections', 'relevant_mirrors',
            'irrelevant_mirrors', 'expanded_states', 'max_backtrack',
            'near_misses', 'beam_crossings', 'aha')))
        for r in lv.rows():
            lines.append('\t\t"%s",' % r)
        lines.append('\t]},')
    lines.append(']')
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


def main():
    tries = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    rng = random.Random(seed)
    reasons, accepted, pool = {}, [], []
    produced = 0
    for _ in range(tries):
        lv, why = generate(rng)
        if lv is None:
            reasons['(üretilemedi) ' + why] = reasons.get('(üretilemedi) ' + why, 0) + 1
            continue
        produced += 1
        m = lv.metrics()
        why = quality(lv, m, accepted)
        if why:
            reasons[why] = reasons.get(why, 0) + 1
            continue
        accepted.append(lv)
        pool.append((lv, m))
    print('deneme=%d · üretilen bölüm=%d · filtreden geçen=%d · elenen=%d'
          % (tries, produced, len(pool), produced - len(pool)))
    for k, v in sorted(reasons.items(), key=lambda kv: -kv[1]):
        print('  %5d  %s' % (v, k))
    if len(pool) < 10:
        print('HATA: havuz 10dan küçük'); sys.exit(1)
    sc = scores(pool)
    chosen = pick(pool, sc)
    items = [(pool[i][0], pool[i][1], sc[i], ad) for i, ad in chosen]
    write_gd('levels_uretilen.gd', items)
    print('seçilen 10:')
    for n, (lv, m, s, ad) in enumerate(items, 1):
        print('  U%-2d %-5s zorluk=%.2f çevir=%d yansıma=%d ayna=%d/%d arama=%d geri=%d near=%d kesişme=%d aha=%s'
              % (n, ad, s, m['solution_toggles'], m['solution_reflections'],
                 m['relevant_mirrors'], m['rotatable'], m['expanded_states'],
                 m['max_backtrack'], m['near_misses'], m['beam_crossings'], m['aha']))


if __name__ == '__main__':
    main()
