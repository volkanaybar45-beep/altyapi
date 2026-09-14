# Fener Bekçisi — Yayın ve Para Planı

Kaynak: ChatGPT danışma (2026-09-14), patron süzdü.
**Rakamlar ve Play kuralları DOĞRULANMADI** — yayın öncesi Yayın bölümü
Play Console'dan teyit edecek (SIRADA).

## 1. Reklam modeli — sadece ödüllü
Hedef "çok reklam izletmek" DEĞİL: **çok oyuncu × uzun kalıcılık × az ama
gönüllü reklam.** 1000 indirme para değildir, günlük aktif oyuncu paradır.

Kaba eCPM kıyası (Q4 2024 verisi, doğrulanmadı): Kuzey Amerika ~$9 ·
APAC ~$8 · Avrupa ~$5 · Orta Doğu ~$2.4 · LATAM ~$1.8.
Matematik senaryosu: 1.000 günlük oyuncu × kişi başı 0,5 reklam × $3 eCPM
≈ aylık $45. 10.000 oyuncu × 0,7 × $4 ≈ $840. **Gelir tahmini değil, ölçek
fikri.**

### Reklam nereye konur
- **Bölüm bittikten SONRA**, gemi limana girip ışıklar yandıktan sonra:
  "Liman hatırası ×2 — kısa video izle". İstemiyorsa doğrudan sonraki bölüm
- Kozmetik ekranı: 1 reklam → özel fener rengi için parça
- Bölüm seti sonu: kartpostal aç
- **Çekirdek ilerleme ASLA reklama bağlı olmaz**

### Ödül ne olacak — Liman Restorasyonu
Bulmaca çözünce +10 ışık puanı; reklam izleyen +20 alır. Puanla açılanlar:
fener dış görünüşü · iskele lambaları · tekne boyaları · gece gökyüzü ·
martı animasyonları · kartpostallar · müzik katmanları.
**Hiçbiri bulmacayı kolaylaştırmaz.**

### Ödül garantisi (şirket kuralı) — teknik yöntem
```
reward_id = "bolum_34_cift_odul"
if reklam_yuklu: göster → başarı VEYA hata → ÖDÜLÜ VER
else:           "Ücretsiz bonusu al" → ÖDÜLÜ VER
reward_id cihazda claimed=true işaretlenir
```
Böylece ödül her hâlükârda verilir ama internet kapatılarak tekrar alınamaz.

### Asla yapılmayacaklar
Bulmaca açılırken/düşünürken reklam · her bölüm sonunda zorunlu reklam ·
yeniden başlatınca reklam · ana menüye dönerken reklam · sürekli banner ·
"devam etmek için reklam" · sahte kapatma düğmesi.

## 2. Mağaza sayfası
**İkon:** tek başına fener KOYMA ("fener duvar kağıdı" gibi görünür).
Kompozisyon: sol üstte fener → altın ışık → ayna → küçük tekne. Sisli koyu
mavi zemin, tek odak, yazı yok. **48-64 pikselde bile "ışık → ayna → tekne"
okunmalı.**

**1. ekran görüntüsü:** ana menü değil, oyunun en güzel anı — altın ışık
zinciri aktif, arkada sıcak liman.
Metin: EN "LIGHT THE WAY HOME" · TR "ONLARA EVE DÖNÜŞ YOLUNU GÖSTER"
**2.** fırtınalı zor seviye · **3.** karanlık → aydınlanmış liman.

**Kısa açıklama (80 karakter sınırı):**
- EN: `Rotate mirrors, bend light and guide ships home in calm offline puzzles.`
- TR: `Aynaları çevir, ışığı yönlendir ve gemilere eve dönüş yolunu göster.`
"70 bölüm", "ücretsiz", "en iyi" ile başlama — **mekaniği sat.**

**3 saniyelik video:** intro/logo/fade YOK.
0.0-0.6 sis, tekne karanlıkta, ışık yanlış yere gidiyor ·
0.6-1.2 parmak aynaya dokunur, ÇIT, 90° döner ·
1.2-2.3 ışık ayna→ayna→ayna→gemi akar ·
2.3-3.0 liman yanar, tekne hareket eder, "LIGHT THE WAY HOME".
**Ses kapalıyken de anlaşılmalı.**

## 3. İlk 1000 indirme
"Yayınla ve bekle" = çok az indirme. En güçlü yöntem: **oyun geliştirenlere
değil, bulmaca OYNAYANLARA göster.** (Aktarılan tek vaka: oyuncu
topluluğunda ~50 bin görüntülenme ≈ 1000 indirme; geliştirici topluluğunda
200 bin görüntülenme < 200 indirme. Garanti değil, hedef kitlenin önemini
gösteriyor.) Topluluk kurallarına uy, spam yapma.

### 30 günlük takvim
| Zaman | İş |
|---|---|
| T-21 | Mağaza sayfası TR+EN hazır · kapalı test başlar |
| T-20 | 15 kısa oynanış videosu |
| T-14→T-1 | Shorts/TikTok/Reels düzenli paylaşım |
| T-10 | Bulmaca topluluklarına oynanabilir demo |
| T-7 | En iyi ikon + ekran görüntüsü seçilir |
| T-3 | Sürüm dondurulur |
| T0 | Yayın |
| T+1-7 | Sadece hata düzeltme, yeni özellik YOK |
| T+7 | İlk mağaza A/B testi |
| T+10-20 | Yeni bölüm paketi |
| T+30 | Veriye göre karar |

## 4. Yayın öncesi kontrol (DOĞRULANACAK)
- Yeni kişisel Play Console hesaplarında üretim erişimi için **12 testçinin
  14 gün** kapalı testte kalması isteniyor olabilir → erken başlat
- Ön kayıt kullanılacaksa yayından önce kurulur, kampanya en fazla 90 gün
- Play App Signing kararları açık test/üretim öncesinde daha kolay değişir
- Geliştirici doğrulaması: 30 Eylül 2026 tarihli bir gereklilik var,
  Console'dan durum kontrol edilecek
- APK/AAB/keystore git'e girmez

## 5. Sürüm stratejisi
**İlk sürümde 70 değil, 40-45 çok iyi bölüm.** Sonra +15 "Fırtınalı Denizler",
sonra +10 "Kutup Işıkları". İki faydası: tek kişiye 70 bölüm baskısı olmaz;
Play'de gerçek güncelleme içeriği doğar (yeni içerik mağazada öne çıkabilir).
