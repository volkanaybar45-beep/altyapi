# Maden — Renk Paleti

> Görsel sürümü: https://claude.ai/code/artifact/f4e2b9ba-7f90-49bf-8f97-62e843004914
> (renkleri gözle görmek için; bu dosya çalışma kopyasıdır)

**Bu palet uydurulmadı.** Her renk ya `yaban/scripts/maden.gd` /
`atolye.gd` içinde tanımlı bir sabit, ya da mevcut bir arka plan/ikon
görselinden örneklenmiş baskın ton. Kabuk (ana sayfa, ayarlar, oyun
sonu) bu paletten boyanacak ki oyun tek parça dursun.

**Nasıl kullanılır:**
- **Kodda** → değerler birebir uygulanır (`Color(...)` sütunu).
- **Görsel üretiminde** → hex kodu ChatGPT'ye verilmez, **tarif**
  verilir ("warm amber gold"). Üretim sonrası palete karşı kontrol
  edilir.

---

## 1. Altı hayvan kimliği — KURULU

`maden.gd:152` · `ANIMAL_PLATE_COLOR_VIVID`

| Hayvan | Hex | Godot | Tarif (görsel promptu için) |
|---|---|---|---|
| Baykuş | `#D9A324` | `Color(0.85, 0.64, 0.14)` | warm amber gold |
| Kurt | `#8CC7E6` | `Color(0.55, 0.78, 0.90)` | icy blue-grey |
| Kuzgun | `#6B298C` | `Color(0.42, 0.16, 0.55)` | deep iridescent purple |
| Ayı | `#D9701F` | `Color(0.85, 0.44, 0.12)` | warm orange-brown |
| Kartal | `#29B8B3` | `Color(0.16, 0.72, 0.70)` | white-turquoise |
| Tilki | `#CC2429` | `Color(0.80, 0.14, 0.16)` | crimson red |

**DİKKAT:** Bunlar kimliğin KAYNAĞI. Oyun çalışırken `_ready()` içinde
HSV üzerinden doygunluğu/parlaklığı kısılmış hâli
(`ANIMAL_PLATE_COLOR`) kullanılıyor — tahtada gördüğün ton buradan
biraz daha sakin.

**Bilinen zayıf çift:** Kurt ve Kartal (ikisi de açık ve soğuk). Plaka
rengi bu yüzden gerekli, kaldırılmamalı.

---

## 2. Zeminler — KURULU

| Ne | Hex | Kaynak |
|---|---|---|
| Maden — gece orman | `#475860` | `maden_arkaplan.png` baskın ton |
| Atölye — ocak karanlığı | `#050403` | `atolye_arkaplan.png` baskın ton |
| Tahta paneli | `#2B2B29` | `Color(0.17, 0.17, 0.16)` yarı saydam |
| HUD sayaç paneli | `#0F0F0F` | `Color(0.06, 0.06, 0.06, 0.72)` |

---

## 3. Malzeme ve ekonomi — KURULU

| Ne | Hex | Godot / kaynak |
|---|---|---|
| Kömür — ilerleme çubuğu | `#738CA6` | `Color(0.45, 0.55, 0.65)` |
| Kor — ilerleme çubuğu | `#EB6B1A` | `Color(0.92, 0.42, 0.10)` |
| Elmas — normal | `#F0FAFB` | `elmas_normal.png` |
| Elmas — kusursuz | `#D5CDD8` | `elmas_kusursuz.png` |

**Korunacak karar:** Kömür SOĞUK, kor SICAK. İki malzeme sayıyla değil,
sıcaklık ekseniyle ayrılıyor. (Kömür ikonu neredeyse siyah — `#0B0A09` —
okunması için çubuk rengi açıldı.)

**Not:** Elmas kusursuz, normalden DAHA KOYU. Ayrımı parlaklık değil ton
taşıyor.

---

## 4. Combo şeridi — KURULU

`maden.gd:264` · `COMBO_COLORS` — sarıdan kızıla, ısınan metal gibi.

| Kademe | Hex | Godot |
|---|---|---|
| Kıvılcım | `#FFEB73` | `Color(1.0, 0.92, 0.45)` |
| Alev | `#FFC74D` | `Color(1.0, 0.78, 0.30)` |
| Kor | `#FF9433` | `Color(1.0, 0.58, 0.20)` |
| Ateş | `#FF6138` | `Color(1.0, 0.38, 0.22)` |

**Kabuk bunu ödünç almalı:** ana sayfada "en yüksek combo" gösterilecekse
sayının rengi oyuncunun ulaştığı kademeden gelsin. Yeni görsel gerekmiyor.

---

## 5. Durum ve metin — KURULU

| Rol | Hex | Godot | Nerede |
|---|---|---|---|
| Birincil metin | `#FAEDD1` | `Color(0.98, 0.93, 0.82)` | Başlık, sayaç |
| Soluk metin | `#D9D1B8` | `Color(0.85, 0.82, 0.72, 0.75)` | Yardımcı yazı |
| Açık zemin üstü metin | `#1A1712` | `Color(0.10, 0.09, 0.07)` | Seçili buton |
| Başarı | `#99F28C` | `Color(0.60, 0.95, 0.55)` | Atölye: tamamlandı |
| Bekleme / uyarı | `#FFD94D` | `Color(1.0, 0.85, 0.30)` | Atölye: sürüyor |
| Bilgi | `#8CD9FF` | `Color(0.55, 0.85, 1.0)` | Atölye: sonuç |
| Seçim halkası | `#FFF299` | `Color(1.0, 0.95, 0.60, 0.95)` | Tahtada seçili taş |
| Altın vuruş bölgesi | `#FFD940` | `Color(1.0, 0.85, 0.25, 0.90)` | Atölye: çekiç |

---

## 6. Kabuk renkleri — ONAYLANDI (2026-09-06)

Kullanıcı kararı SENARYO'ya bıraktı, kontrast ölçümü + web araştırması
sonrası onaylandı. **İki düzeltmeyle** (ölçüm sırasında bulundu).

| Ne | Hex | Godot | Zemine kontrast |
|---|---|---|---|
| Menü zemini | `#1E272C` | `Color(0.118, 0.153, 0.173)` | — |
| Yükseltilmiş yüzey | `#333F45` | `Color(0.200, 0.247, 0.271)` | 1.40:1 |
| Ayırıcı çizgi | `#44525A` | `Color(0.267, 0.322, 0.353)` | 1.88:1 |
| Ana vurgu — altın | `#D9A324` | `Color(0.85, 0.64, 0.14)` | 6.67:1 |
| İkincil vurgu — kor | `#EB6B1A` | `Color(0.92, 0.42, 0.10)` | 4.81:1 |
| **Buton içi yazı** | `#1A1712` | `Color(0.10, 0.09, 0.07)` | — |

### Ölçülen kontrastlar (WCAG)

Menü zemini `#1E272C` üzerinde: metin `#FAEDD1` **13.10:1**, soluk metin
`#D9D1B8` **9.96:1**, altın **6.67:1**, kor **4.81:1** — hepsi AA (4.5)
geçiyor.

### DÜZELTME 1 — Buton yazısı KOYU olacak, açık DEĞİL

| Kombinasyon | Kontrast | |
|---|---|---|
| Açık yazı `#FAEDD1` / kor buton | 2.72:1 | ❌ okunmaz |
| Açık yazı / altın buton | 1.96:1 | ❌ çok kötü |
| **Koyu yazı `#1A1712` / kor buton** | **5.66:1** | ✅ |
| **Koyu yazı `#1A1712` / altın buton** | **7.84:1** | ✅ |

Altın ve kor açık renkler; üstlerine açık yazı konulamaz. Kitle yaşça
büyük (madde 12) ve telefon güneşte kullanılıyor — bu pazarlık konusu
değil.

### DÜZELTME 2 — Yüzey zeminden yeterince ayrışmıyordu

İlk öneri `#2A3439` idi; zeminle arası sadece **1.19:1** — ucuz
ekranda ve gün ışığında kaybolur. `#333F45`'e açıldı (**1.40:1**),
gerektiğinde `#44525A` ayırıcı çizgiyle desteklenecek. Altın bu yüzey
üzerinde de geçiyor (4.76:1).

### Bilerek uyulmayan tavsiye

Dark-mode kaynakları vurgu rengi olarak mavi/turkuaz/mor öneriyor
([Medium](https://medium.com/@social_7132/dark-mode-done-right-best-practices-for-2026-c223a4b92417),
[coloruxlab](https://coloruxlab.com/guides/mobile-app-color-design)).
Bu **genel uygulama** tavsiyesi. Bizim dünyamızın tüm ışığı ateş ışığı;
altın ve kor oyunun kendi kodundan geliyor. Maviye kaymak oyunu her
uygulamaya benzetirdi. **Bilinçli sapma.**

Uyulan tavsiyeler: düz siyah yerine katmanlı koyu gri ✅, buton yazısı
≥4.5:1 ✅, dokunma hedefleri büyük ✅, menüler arası tutarlılık ✅.

## Kullanım kuralları

**1. Altı hayvan rengi SADECE hayvan kimliğidir.**
Menüde buton, çubuk ya da süs rengi olarak kullanılmaz. Kullanılırsa
oyuncunun "mor = Kuzgun" bağı zayıflar — o bağ oyunun okunabilirliğini
taşıyan şey.

**2. Bir ekranda tek vurgu rengi.**
Altın *ya da* kor; ikisi birden değil. Kor yalnızca ekranın en önemli
tek eylemine ayrılır.

**3. Saf beyaz ve saf siyah yok.**
Metin `#FAEDD1`, koyu zemin üstü metin `#1A1712`. Oyunun bütün ışığı
ateş ışığı — nötr beyaz o dünyaya ait değil.

**4. Kırmızı yalnızca Tilki'nindir.**
Hata, tehlike ya da "sil" için kırmızı kullanılmaz — Tilki'yle karışır.
O roller için kor turuncusu ya da metin ağırlığı kullanılır.
*(Bu kural "öfkeli boss" işini de bağlar: altı hayvanı kırmızı alevle
sarmak Tilki'yi kendi alevinde kaybettirebilir — bkz. madde D-228.)*

**5. Yazı büyük, kontrast yüksek.**
Araştırmada kitlenin yaşça büyük ve sadık olduğu çıktı ("definitely for
us older adults", "I'm 70 years old" — madde 12). Soluk metin
(`#D9D1B8` %75) küçük punto ile birlikte kullanılmaz.
