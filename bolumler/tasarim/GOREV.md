# Tasarım (eski SENARYO rolü)

**Sorumluluk:** Oyun kuralları, ekonomi, bölüm tasarımı, ekrandaki tüm metin, TR+EN çeviri.
**Girdi:** Araştırma raporları, SIRKET.md değerleri.
**Çıktı:** Tasarım belgesi (`oyunlar/<oyun>/tasarim.md`), çeviri dosyası.

- İngilizceyi Tasarım yazar; makine çevirisi yok, KOD uydurmaz
- Yeni ekran önce çeviri dosyasına girer, sonra koda
- Temel kuralı etkileyen karar → patron kurucuya danışır

## Dersler (Yaban'dan damıtıldı, 2026-09-14)
- Bir kuralı uygularken arkasındaki niyeti anla; kalıcı öğe için konan kısıt geçici efekte harfiyen uygulanmaz
- "Komşuyla çakışmıyor" ile "zincir ekrana sığıyor" ayrı iddialardır, ikisini ayrı ölç
- Öğe sığmıyorsa boşluğu öğenin gerçek boyutuyla karşılaştır; boşluk küçükse kaydırmak değil küçültmek gerekir
- Boşluk ölçümü öğenin kendi merkez ekseninden yapılır; kenar süsünden ölçmek boşluğu küçük gösterir
- "Büyüt" tek boyutlu değildir; boyut büyüyünce konum da yeniden seçilir
- Ölçümden gelen sabitle göz kararı sabitini ayrı tut, tercihin gerekçesini yaz
- Eşiği tahminle değil, sistemden geçen otomatik bir simülasyonla (basit bot bile) ölç
- "Değişiyor mu" yetmez, mutlak eşikle "yeterli mi" de test et
- Niteliksel talimatı ("hafif", "yarı saydam") tek sayıya çevirme; varyant üretip karşılaştır
- Aynı semptomla dönen hatada kök sebebin katmanlı olduğunu varsay, tek düzeltmeye güvenme
- Ağırlıklı rastgele seçim yetiyorsa durum makinesi yazma
