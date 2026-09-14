# Üretim Hattı — görsel/3B boru hattı (doğrulanmış)

Yaban'da kurulup çalıştığı ölçülen hat. Yeni projede aynen
kullanılabilir.

## Lisans zemini — CAN DAMARI
- **OpenAI (ChatGPT) tek izinli görsel zemin.** Dreamina YASAK.
- **Tripo Pro** aboneliği: Gizlilik **"Gizli"** ELLE seçilir.
  Pro'ya geçmek tek başına yetmez. Ücretsiz planda üretilenler
  "Açık Modeller · Ticari Olmayan" olur ve oyuna GİREMEZ.
- Yeni bir araç kullanılmadan önce lisansı okunur.
- Telif, insan müdahalesine bağlıdır — prompt ve seçim bizim.

## Zincir
ChatGPT (2B referans) → Tripo Pro (Image-to-3D) → `toon_render.py`
→ saydam PNG (256×256 ikon / 512 büyük)

## Tripo ayarları — doğrulanmış takım
`v3.1 – En İyi Kalite` · Ultra Ağ **AÇIK** · Doku **AÇIK** ·
Texture **4K** · Aydınlatmayı kaldır **AÇIK** · PBR **KAPALI** ·
Üçgen topoloji · Poligon ~300K · AI tamamlama **KAPALI** · Gizli

- **Doku açık olmazsa** PBR ve "Aydınlatmayı kaldır" satırları
  panelde GÖRÜNMÜYOR — sıralama önemli.
- **PBR neden kapalı:** metalness/roughness haritası istenmeyen
  parlaklık ekliyor.

## ⚠ .glb HEMEN İNDİRİLİR
Tripo geçmişi **7 gün** sonra siliniyor. Elinde sadece düz PNG
kalırsa o nesneyi bir daha farklı açıdan/ışıkla render edemezsin.
Üretim anında üçü birden: Gizli seç · `.glb` indir · deftere yaz.

## toon_render.py
```
python toon_render.py <glb> <ad> <görünüm> <doygunluk> <ton> <parlaklık>
```
- Görünümler: `z` (-Z'ye bak), `x` (-X'e bak), `xr` (+X, aynalı).
  **Serbest döndürme YOK** — dikey bir poz gerekiyorsa ayrı model
  gerekir. (Denendi: yatay bir modeli `x`/`xr` ile dikleştirmek
  nesneyi kenardan gösteriyor, bıçak gibi düzleşiyor.)
- Blender/GL gerektirmez; `trimesh` ile GLB okunur, yüzeyden
  nokta bulutu örneklenir, toon gölge + kontur uygulanır.
- Aynalama gerekiyorsa PIL `FLIP_LEFT_RIGHT` / `FLIP_TOP_BOTTOM`
  yeterli, yeni model üretme.

## Küçük ikon kuralları (deneyle bulundu)
- **55 px'te okunacak:** kalın dış hat, büyük iç alan, en fazla
  iki ton. İç detay, doku, ince çizgi bu ölçekte sadece kir üretir.
- **Parçalanma:** 55-80 px hücrede EN FAZLA 3-4 dilim. Daha fazlası
  baklava dilimine dönüyor. Kesim, kolların ORTASINDAN geçmeli —
  aralarından değil (ince parça yerine tıknaz parça).
- **Siluet ailesi:** aynı aileden iki sembol olmaz. Kırmızı-yeşil
  çiftine (renk körlüğü) en uzak iki aile verilir.
- Üretilen her görsel, hedef ölçeğe küçültülüp GERÇEK zemine
  konarak gözle kontrol edilir; kontrast ölçülür (en zayıf sembol
  için hedef ≥ 3.0).
