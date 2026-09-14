# Fener Bekçisi — Görsel Plan (2026-09-14)

Hedef ekran: **dikey 1080×1920** (tasarım çözünürlüğü). Tüm px değerleri buna göre.
Hat kararı patrondan geldi, tartışılmıyor. Bu dosya onu uygulanabilir hâle getirir.

---

## 1. Varlık listesi

| Varlık | Hat | Kaynak px | Ekranda px | `toon_render` görünümü | Gerekçe |
|---|---|---|---|---|---|
| Fener kulesi | Tripo | 512×512 | ~300 × 620 | `z` | Her bölümde var, ışık kaynağı; hacimli durmalı |
| Ayna | Tripo | 256×256 | **144 × 144** | `z` | Tek dokunma hedefi; her bölümde 3-8 kopya, açı tutarlılığı şart |
| Tekne | Tripo | 512×512 | ~260 × 160 | `x` (gerekirse `xr` ile aynala) | Hedef nesne, her bölümde bir tane |
| Kayalık | Tripo | 512×512 | 200–420 geniş | `z` | Engel; bölüm başına 2-5 kopya, ölçek/aynalama ile çeşitlenir |
| Gece denizi arka planı | **2B** | 1080×1920 | tam ekran | — | Tek katman, 3B'ye gerek yok |
| Sis katmanı | **2B** | 2160×540, **yatay tekrarlanabilir (seamless)** | ekran boyu kayar | — | Kod yatay kaydıracak; tile olmazsa dikiş görünür |
| Ay | **2B** | 256×256 saydam | ~140 × 140 | — | Tek parça, sabit |
| Işın | **kod** | — | çekirdek ≥16 px + glow | — | Açı/uzunluk çalışma anında belirleniyor |
| Parlama (ayna/lamba) | **kod** | — | — | — | Additive blend, dosya gereksiz |
| Sis hareketi | **kod** | — | — | — | Shader/tween; doku 2B'den gelir |
| Kutlama parçacıkları | **kod** | — | — | — | GPUParticles, nokta/daire çizimi yeter |

**Dokunma hedefi notu:** ayna 144 px ≈ 9 mm; parmak için alt sınır. Küçültme.

---

## 2. Tripo varlıkları için ChatGPT 2B referans prompt'ları

Kurallar (dördü için de geçerli):
- **Hex kodu prompt'a yazılmaz**, tarif yazılır (`RENK_PALETI` yöntemi).
- Görsel, oyundaki kamera açısıyla üretilir — `toon_render.py`'de serbest döndürme yok.
- Tek nesne, düz/saydam zemin, gölge yok.

**Fener kulesi**
> A single stylized lighthouse tower for a mobile game icon, front three-quarter view, standing upright and centered, tapered cylindrical body in pale bone-white stone with one narrow horizontal band of weathered slate grey, a small glazed lamp room at the top glowing warm lantern yellow, a simple railing, no rocks and no ground beneath it, clean toon shading with flat color areas and a bold uniform dark outline, no more than two tones per surface, no fine texture detail, soft cartoon proportions, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Ayna**
> A single stylized standing mirror prop for a mobile game icon, front three-quarter view, a thick circular polished disc of pale silvery light-toned metal set inside a chunky warm brass ring frame, mounted on a short sturdy pivot post with a heavy round base, the disc clearly has depth and thickness like a solid plate rather than a flat pane, no reflected scenery drawn on the disc, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Tekne**
> A single stylized small fishing boat for a mobile game icon, pure side view facing right, short chunky wooden hull in warm dark brown with a pale cream stripe along the gunwale, one short mast with a tiny lantern hanging from it, no sail or a small furled sail, rounded cartoon proportions wider than tall, no water and no waves under it, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Kayalık**
> A single stylized sea rock formation for a mobile game icon, front three-quarter view, a compact cluster of three or four blocky angular boulders in cold blue-grey slate with pale lighter tops, wider than tall, flat bottom so it can sit on a surface, no water and no plants, chunky simplified silhouette readable at small size, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects.

**Üretim anında üçü birden (URETIM_HATTI):** Tripo'da Gizlilik **Gizli** · `.glb` HEMEN indir · deftere yaz.

---

## 3. Arka plan ve sis prompt'ları

ChatGPT dikey çıktısı büyük olasılıkla **1024×1536 (2:3)**. 9:16 değil — prompt'ta
kenarlarda boş pay istenir, sonra 1080×1920'ye kırpılır. Kırpma payı yoksa ay ya da
ufuk kesilir.

**Gece denizi arka planı**
> A calm night sea scene as a vertical mobile game background, tall portrait composition, very dark navy water filling the lower two thirds with soft gentle horizontal wave bands and a faint pale moonlight streak on the surface, a slightly lighter deep blue night sky above with a low soft horizon line, empty center area with nothing in it so game objects can be placed on top, no lighthouse, no boat, no rocks, no moon, no stars clusters, no text, no characters, smooth painterly flat toon style with soft gradients and no visible brush texture, low saturation, keep extra empty margin at the top and bottom edges for cropping.

**Sis katmanı (saydam PNG)**
> A horizontal band of soft pale blue-grey fog wisps on a fully transparent background, wide panoramic strip much wider than tall, smooth soft-edged cloudy shapes with feathered semi-transparent edges, low contrast and low saturation, no sharp lines, no objects, no text, the left and right edges must match so the strip tiles seamlessly when repeated horizontally, nothing else in the image.

**Ay**
> A single stylized full moon for a mobile game, a plain pale cool white-blue disc with a very soft faint glow halo, two or three barely visible lighter craters, no face, no clouds, no stars, isolated on a fully transparent background, no text.

Sis'in tile'lığı **gözle doğrulanır**: PNG'yi yan yana iki kez koyup dikiş aranır.

---

## 4. Gece paleti (öneri) — ölçülmüş

Hex yalnızca **koda** girer. Görsel üretiminde "tarif" sütunu kullanılır.

| Rol | Hex | Tarif (prompt için) | Nerede |
|---|---|---|---|
| Deniz / zemin | `#0A1826` | very dark navy | Su, en alt opak taban |
| Gökyüzü | `#16293D` | deep blue night sky | Ufuk üstü |
| Kontur / rim | `#8FB3CC` | cool pale blue-grey | **Tüm nesnelerin dış hattı** ve ay ışığı kenarı |
| Sis | `#5E7C99` | pale blue-grey | Sis katmanı, %35–50 alfa |
| Fener ışığı | `#FFE7A3` | warm lantern yellow | Işın, lamba odası, tekne feneri, parlama |
| Ay | `#E3EDF7` | pale cool white | Ay diski, ay ışığı çizgisi |
| Ayna yüzeyi | `#C9D8E2` | light polished silver | Ayna diski — **dokunulacak şey ekrandaki en parlak nesne** |
| Ayna çerçevesi | `#B08D4F` | warm brass | Ayna halkası (ışığın tek sıcak eşlikçisi) |
| Kayalık | `#2B4054` | cold blue-grey slate | Engeller |
| Tekne gövdesi | `#4A3A2A` | warm dark brown wood | Hedef |
| Metin | `#EAF2F8` | — | HUD, bölüm no |

### Ölçülen kontrastlar (WCAG, hesaplandı — tahmin değil)

Deniz `#0A1826` üzerinde:

| Çift | Oran | |
|---|---|---|
| Fener ışığı | **14.69** | ✅ hedef ≥3.0 |
| Ay | **15.13** | ✅ |
| Ayna yüzeyi | **12.29** | ✅ dokunma hedefi rahat bulunur |
| Kontur / rim | **8.10** | ✅ |
| Ayna çerçevesi | **5.78** | ✅ |
| Sis | **4.11** | ✅ (gökyüzü üstünde 3.40) |
| Işık vs sis | **3.57** | ✅ ışın sis içinde kaybolmuyor |
| Kayalık gövdesi | 1.68 | ⚠ **tasarım gereği** |
| Tekne gövdesi | 1.65 | ⚠ **tasarım gereği** |

**Karanlık gövdeler bilerek düşük.** Gece hissi bundan geliyor. Okunabilirliği
gövde değil **kontur** taşıyor: rim `#8FB3CC` denize 8.10, kayaya 4.83, tekneye
4.92 — üçü de ≥3.0. Kontur rengi kaldırılamaz, inceltilemez.

### Üretim sonrası zorunlu doğrulama
Arka plan PNG'si geldiğinde **gerçek baskın tonu örneklenir** ve yukarıdaki
oranlar o tonla yeniden ölçülür. Tablodaki deniz rengi şu an bir hedef, ölçüm
değil. Işık çifti 3.0'ın altına düşerse deniz koyulaştırılır, ışık değil.

---

## 5. Tutarlılık kuralları

1. **Işık yönü:** ana ışık **sol üstten** (fener kulesi solda). Tüm 2B referans
   prompt'ları ve tüm `toon_render.py` çağrıları aynı ışıkla. Ay sağ üstte —
   dolgu ışığı, gölge yönünü değiştirmez.
2. **Kontur:** tek renk `#8FB3CC`, 512 px kaynakta **6 px**, 256 px kaynakta
   **4 px** (ekranda ~3 px'e denk gelir). Her varlıkta aynı. İnce kontur yasak —
   Yaban dersi: "ip gibi ince" çıkıyor.
3. **Doygunluk:** düşük. Tek istisna fener ışığı `#FFE7A3` ve ayna pirinci
   `#B08D4F`. Ekranda **tek sıcak odak** vardır: ışık zinciri. Kayalık/tekne/
   arka plan sıcak renge kaçarsa ışık okunmaz.
4. **Ton sayısı:** yüzey başına en fazla iki ton (URETIM_HATTI, küçük ikon kuralı).
5. **Saf siyah/saf beyaz yok.** En koyu `#0A1826`, en açık `#FFE7A3` / `#E3EDF7`.
6. **Tripo takımı sabit:** `v3.1 En İyi Kalite` · Ultra Ağ AÇIK · Doku AÇIK · 4K ·
   Aydınlatmayı kaldır AÇIK · PBR KAPALI · Gizli. Dört varlık aynı ayarla üretilir,
   yoksa yan yana durduklarında aile bozulur.
7. **Aynalama:** varyasyon için PIL `FLIP_LEFT_RIGHT` yeterli, yeni model üretilmez.
   Ama aynalama ışık yönünü ters çevirir — kayalık için serbest, tekne/fener için
   kontrol edilerek.

---

## 6. Defter (lisans kanıt zinciri)

**Durum:** `C:\Altyapi\oyunlar\fener\` içinde `fikir.md` ve bu dosyadan başka
dosya yok. **Kayıtsız görsel/ses dosyası YOK.** Uydurulmuş kayıt da yok.

Boş şablon yazıldı: `C:\Altyapi\oyunlar\fener\gorseller\kayit.md`
Sütunlar: dosya adı · tarih · araç · prompt · format.
İlk PNG buraya inmeden satır yazılmaz.
