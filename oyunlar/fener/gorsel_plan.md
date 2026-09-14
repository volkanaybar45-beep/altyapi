# Fener Bekçisi — Görsel Plan (2026-09-14)

Hedef ekran: **dikey 1080×1920** (tasarım çözünürlüğü). Tüm px değerleri buna göre.
Hat kararı patrondan geldi. Bu dosya onu uygulanabilir hâle getirir.

---

## 1. Varlık listesi

| Varlık | Hat | Kaynak px | Ekranda px | `toon_render` görünümü | Gerekçe |
|---|---|---|---|---|---|
| Fener kulesi | Tripo | 512×512 | ≤ 250 × 510 | `z` | Işık kaynağı, her bölümde var. **512'yi aşan ekran boyu yasak** — betik FINAL=512 sabit, büyütmek bulanıklaştırır |
| **Ayna — plaka** | Tripo | 256×256 | ~144 × 64 | `z` (tam cepheden) | Dönen parça. Kod 2B'de pivot etrafında döndürür; 3/4 açıdan render edilirse döndürünce çarpık görünür |
| **Ayna — taban** | Tripo | 128×128 | ~70 × 70 | `z` | Sabit ayak. Plakadan ayrı, çünkü dönmez |
| Tekne | Tripo | 512×512 | ~260 × 160 | `x` (gerekirse `xr` ile aynala) | Hedef nesne, bölümde bir tane |
| Kayalık | Tripo | 512×512 | 200–420 geniş | `z` | Engel; bölüm başına 2-5 kopya, ölçek + aynalama ile çeşitlenir |
| Gece denizi arka planı | **2B** | 1080×1920 | tam ekran | — | Tek katman, 3B gereksiz |
| Sis katmanı | **2B** | 2160×540, **yatay seamless** | ekran boyu kayar | — | Kod yatay kaydıracak; tile olmazsa dikiş görünür |
| Ay | **2B** | 256×256 saydam | ~140 × 140 | — | Tek parça, sabit |
| Işın | **kod** | — | çekirdek ≥16 px + glow | — | Açı/uzunluk çalışma anında belirleniyor |
| Parlama (ayna/lamba) | **kod** | — | — | — | Additive blend, dosya gereksiz |
| Sis hareketi | **kod** | — | — | — | Shader/tween; doku 2B'den gelir |
| Kutlama parçacıkları | **kod** | — | — | — | GPUParticles, dosyasız |

**Ayna neden iki parça:** oyunun tek mekaniği "aynayı çevir". Yuvarlak disk her
açıda aynı görünür — oyuncu aynanın hangi yöne baktığını göremez. Plaka **uzun
kenarı ayna düzlemi olan yassı bir levha** olmalı; siluet asimetrik olmazsa
mekanik okunmaz.

**Dokunma hedefi:** ayna (plaka+taban) toplam ~144 px ≈ 9 mm. Alt sınır, küçültme.

---

## 2. Tripo varlıkları için ChatGPT 2B referans prompt'ları

Kurallar:
- **Hex kodu prompt'a yazılmaz**, tarif yazılır (`RENK_PALETI` yöntemi).
- Görsel, oyundaki kamera açısıyla üretilir — `toon_render.py`'de serbest döndürme yok.
- Tek nesne, düz zemin, gölge yok.
- **Kontur:** referans görselde koyu kontur istenir (Tripo siluet için ona ihtiyaç
  duyuyor). Oyuna giren açık mavi-gri kontur referanstan gelmez, render sonrası
  eklenir — bkz. bölüm 5.2. Bu iki kontur çelişki değil, iki ayrı aşama.

**Fener kulesi**
> A single stylized lighthouse tower for a mobile game icon, front three-quarter view, standing upright and centered, tapered cylindrical body in pale bone-white stone with one narrow horizontal band of weathered slate grey, a small glazed lamp room at the top glowing warm lantern yellow, a simple railing, no rocks and no ground beneath it, clean toon shading with flat color areas and a bold uniform dark outline, no more than two tones per surface, no fine texture detail, soft cartoon proportions, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Ayna — plaka** (dönen parça, tam cepheden)
> A single stylized mirror plate for a mobile game icon, viewed straight on from the front, a wide flat rectangular plate with softly rounded corners, clearly wider than tall, a pale silvery light-toned polished metal face set inside a chunky warm brass border frame, the plate has visible thickness like a solid slab, no reflected scenery drawn on the face, no stand and no base and no post, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, perfectly symmetrical left to right, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Ayna — taban** (sabit ayak)
> A single stylized short pedestal stand for a mobile game icon, front three-quarter view, a heavy round weathered brass base with a thick stubby vertical post on top ending in a simple pivot knob, nothing mounted on the post, chunky simplified shape wider at the bottom, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Tekne**
> A single stylized small fishing boat for a mobile game icon, pure side view facing right, short chunky wooden hull in cold dark blue-grey with a pale lighter stripe along the gunwale, one short mast with a tiny lantern hanging from it glowing warm lantern yellow, a small furled sail, rounded cartoon proportions wider than tall, no water and no waves under it, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Kayalık**
> A single stylized sea rock formation for a mobile game icon, front three-quarter view, a compact cluster of three or four blocky angular boulders in cold blue-grey slate with pale lighter tops, wider than tall, flat bottom so it can sit on a surface, no water and no plants, chunky simplified silhouette readable at small size, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Üretim anında üçü birden (URETIM_HATTI):** Tripo Gizlilik **Gizli** · `.glb`
HEMEN indir · deftere yaz.

---

## 3. Arka plan ve sis prompt'ları

ChatGPT dikey çıktısı büyük olasılıkla **1024×1536 (2:3)** — 9:16 değil. Prompt'ta
üst/alt boş pay istenir, sonra 1080×1920'ye kırpılır. Pay istenmezse ufuk ya da ay
kesilir.

**Gece denizi arka planı**
> A calm night sea scene as a vertical mobile game background, tall portrait composition, very dark navy water filling the lower two thirds with soft gentle horizontal wave bands and a faint pale moonlight streak on the surface, a slightly lighter deep blue night sky above with a low soft horizon line, empty center area with nothing in it so game objects can be placed on top, no lighthouse, no boat, no rocks, no moon, no star clusters, no text, no characters, smooth painterly flat toon style with soft gradients and no visible brush texture, low saturation, keep extra empty margin at the top and bottom edges for cropping.

**Sis katmanı (saydam PNG)**
> A horizontal band of soft pale blue-grey fog wisps on a fully transparent background, wide panoramic strip much wider than tall, smooth soft-edged cloudy shapes with feathered semi-transparent edges, low contrast and low saturation, no sharp lines, no objects, no text, the left and right edges must match so the strip tiles seamlessly when repeated horizontally, nothing else in the image.

**Ay**
> A single stylized full moon for a mobile game, a plain pale cool white-blue disc with a very soft faint glow halo, two or three barely visible lighter craters, no face, no clouds, no stars, isolated on a fully transparent background, no text.

Sis'in tile'lığı **gözle doğrulanır:** PNG yan yana iki kez konur, dikiş aranır.

---

## 4. Gece paleti — 7 renk, ölçülmüş

Hex yalnızca **koda** girer. Görsel üretiminde "tarif" sütunu kullanılır.

| # | Rol | Hex | Tarif (prompt için) | Nerede |
|---|---|---|---|---|
| 1 | Deniz / zemin | `#0A1826` | very dark navy | Su ve en alt opak taban. Gökyüzü aynı rengin açığı `#16293D` — ayrı renk değil, gradyanın üst ucu |
| 2 | Kontur / rim | `#8FB3CC` | cool pale blue-grey | **Tüm nesnelerin dış hattı**, ay ışığı kenarı, HUD çizgileri |
| 3 | Sis | `#5E7C99` | pale blue-grey | Sis katmanı, %35–50 alfa |
| 4 | Fener ışığı | `#FFE7A3` | warm lantern yellow | Işın, lamba odası, tekne feneri, parlama, kutlama parçacıkları |
| 5 | Ay ışığı | `#E3EDF7` | pale cool white | Ay diski, **ayna plakasının yüzeyi**, HUD metni |
| 6 | Pirinç | `#B08D4F` | warm brass | Ayna çerçevesi ve tabanı — ışığın tek sıcak eşlikçisi |
| 7 | Koyu gövde | `#33414F` | cold dark slate | Kayalık ve tekne gövdesi (ortak) |

**Tekne neden kahverengi değil:** kayalıkla aynı koyu gövde tonunu paylaşıyor;
ayrımı renk değil siluet ve **teknenin sıcak feneri** (#FFE7A3) taşıyor. Ekranda
tek sıcak eksen kalıyor: ışık zinciri.

### Ölçülen kontrastlar (WCAG, hesaplandı — tahmin değil)

Deniz `#0A1826` üzerinde:

| Çift | Oran | |
|---|---|---|
| Ay ışığı / ayna plakası | **15.13** | ✅ dokunma hedefi ekranın en parlak nesnesi |
| Fener ışığı | **14.69** | ✅ hedef ≥3.0 rahat geçiyor |
| Kontur / rim | **8.10** | ✅ |
| Pirinç | **5.78** | ✅ |
| Sis | **4.11** | ✅ (gökyüzü üstünde 3.40) |
| Fener ışığı vs sis | **3.57** | ✅ ışın sis içinde kaybolmuyor |
| Koyu gövde (kayalık/tekne) | 1.72 | ⚠ **tasarım gereği** |

**Karanlık gövdeler bilerek düşük** — gece hissi bundan geliyor. Okunabilirliği
gövde değil **kontur** taşıyor: rim `#8FB3CC` denize 8.10, koyu gövdeye **4.72**.
İkisi de ≥3.0. Kontur rengi kaldırılamaz, inceltilemez.

### Üretim sonrası zorunlu doğrulama
Arka plan PNG'si geldiğinde **gerçek baskın tonu örneklenir** ve bu tablo o tonla
yeniden ölçülür. Tablodaki deniz rengi şu an bir hedef, ölçüm değil. Işık çifti
3.0'ın altına düşerse **deniz koyulaştırılır, ışık değil.**

---

## 5. Tutarlılık kuralları

**5.1 Işık yönü.** Ana ışık **sol üstten** (fener kulesi solda). Tüm 2B prompt'ları
ve tüm `toon_render.py` çağrıları aynı ışıkla. Ay sağ üstte — dolgu, gölge yönünü
değiştirmez.

**5.2 Kontur — `toon_render.py` OLDUĞU GİBİ YETMİYOR.**
Betik okundu. Kontur rengi kodda sabit: `INK = [0.09, 0.07, 0.06]` (sıcak koyu
kahve, ~`#171211`). Bu renk deniz `#0A1826` üzerinde **1.04** kontrast veriyor —
yani görünmez. Kalınlık da sabit: `dilate(mask, 2)` 1536 px üst-örneklemede, 512'ye
indirilince **~0,7 px**. "İp gibi ince" Yaban dersi tam olarak bu.

**Karar: `toon_render.py`'ye DOKUNULMAZ** (Yaban'da çalıştığı doğrulanmış betik).
Yerine ayrı bir son-işlem adımı yazılır:
`rim_ekle.py <png> <rim_hex> <kalinlik_px>` — alfayı genişletir, halkayı rim rengiyle
doldurur, premultiply uygular (GOREV.md dersi).
- 512 px kaynakta kalınlık **6 px**, 256 px kaynakta **4 px**, 128 px kaynakta **3 px**.
- Ekranda hepsi ~3 px'e denk gelir. Tüm varlıklarda aynı.

**5.3 Doygunluk.** Düşük. Tek istisna fener ışığı ve pirinç. Ekranda **tek sıcak
odak** vardır: ışık zinciri. Kayalık/tekne/arka plan sıcağa kaçarsa ışık okunmaz.

**5.4 Ton sayısı.** Yüzey başına en fazla iki ton (URETIM_HATTI küçük ikon kuralı).

**5.5 Saf siyah/saf beyaz yok.** En koyu `#0A1826`, en açık `#FFE7A3` / `#E3EDF7`.

**5.6 Tripo takımı sabit.** `v3.1 En İyi Kalite` · Ultra Ağ AÇIK · Doku AÇIK · 4K ·
Aydınlatmayı kaldır AÇIK · PBR KAPALI · Gizli. Beş varlık aynı ayarla; yoksa yan
yana durduklarında aile bozulur.

**5.7 Aynalama.** Varyasyon için PIL `FLIP_LEFT_RIGHT` yeterli, yeni model üretilmez.
Ama aynalama ışık yönünü ters çevirir — kayalıkta serbest, tekne ve fenerde gözle
kontrol edilerek.

**5.8 Ayna dönüşü kodda.** Plaka sprite'ı pivot noktasından 2B döndürülür; taban
sabit kalır. Plaka tam cepheden render edildiği için bu dönüş geometrik olarak
dürüst. 3/4 açılı bir plaka döndürülürse çarpık görünür.

---

## 6. Defter (lisans kanıt zinciri)

**Durum:** `C:\Altyapi\oyunlar\fener\` içinde `fikir.md` ve bu dosyadan başka dosya
yok. **Kayıtsız görsel/ses dosyası YOK.** Uydurulmuş kayıt da yok.

Boş şablon yazıldı: `C:\Altyapi\oyunlar\fener\gorseller\kayit.md`
Sütunlar: dosya adı · tarih · araç · prompt · format.
İlk PNG inmeden satır yazılmaz.
