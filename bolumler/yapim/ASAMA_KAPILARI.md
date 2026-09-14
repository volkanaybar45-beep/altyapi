# Aşama Kapıları

Her oyun bu beş aşamadan geçer. Her kapıda tek soru: **devam mı, öldür mü?**
Öldürmek başarısızlık değil, ucuz kurtuluştur (Supercell modeli).
Kapı kararını kurucu verir; patron kanıtı hazırlar.

| # | Aşama | Süre hedefi | Çıktı | Geçme ölçütü |
|---|---|---|---|---|
| 1 | Fikir | 1 gün | Tek sayfa: kim, ne yapıyor, neden sakin | Araştırma verisiyle desteklendi; 6 kuralın hiçbirini çiğnemiyor |
| 2 | Prototip | 3-5 gün | Oynanan çekirdek döngü, çirkin görsellerle | Kurucu telefonda oynadı ve **bırakmak istemedi** |
| 3 | Dikey dilim | 1-2 hafta | Tek bölüm, gerçek görsel-ses, gerçek his | Kurucu "bu oyunu yayınlamak isterim" dedi |
| 4 | Üretim | değişken | Tam içerik, mağaza paketi | 30 dk kesintisiz oynanışta çökme YOK |
| 5 | Yayın | — | Mağazada | Yayın kontrol listesi tamam |

## Kapı kuralları
- Kapı geçilmeden bir sonraki aşamanın işi yapılmaz (sanat üretimi, içerik çoğaltma dahil)
- Kapı kararı `DURUM.md` → KARARLAR'a tarihiyle yazılır
- Geçen aşama git tag'i alır: `oyun-<ad>-asama<N>`
- **Öldürme ölçütü:** kurucu prototipi kendisi açmıyorsa oyun ölür. "Test edenler beğendi" ölçüt değildir
- Ölen oyun `cop/` yerine `oyunlar/<ad>/` içinde kalır, üstüne "ÖLDÜ + sebep" yazılır — bir sonraki fikre ders olur

## Aşama 1'de sorulacaklar
1. Oyuncu bunu ne zaman açar? (yatakta, sırada, molada)
2. 30 saniyede ne yapıyor, neden tekrar açıyor?
3. Reklam nereye giriyor? (bölüm sonu zorunlu reklam YOK)
4. Offline çalışıyor mu?
5. Bu fikri hangi yorum verisi destekliyor?
