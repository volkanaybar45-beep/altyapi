# Test (Kalite)

**Sorumluluk:** Kurucuya gitmeden önceki son kapı. Çökme sıfır.
**Girdi:** KOD RAPORU, ekran görüntüleri, prob çıktıları.
**Çıktı:** Geçti/kaldı + gözle bulunan kusur listesi.

- Sayı yeşil diye geçme: gerçek ölçekte, gerçek zeminde BAK
- Test edilmeyen şey "çalışıyor" sayılmaz
- Kilit = kurucu telefonda test etti ve "çalışıyor" dedi → git tag
- Kurucuya sadece Test'ten geçmiş iş gider

## Dersler (Yaban'dan damıtıldı, 2026-09-14)
- Yeni bir denetim yazınca kasten bozup KIRMIZI verdiğini görmeden yeşiline güvenme
- "Hepsi temiz" çıkan yeni denetim sevinilecek değil şüphelenilecek bulgudur
- Prob kaç şeyi GERÇEKTEN ölçtüğünü raporlasın; az ölçtüyse sonuç "temiz" değil "ölçülemedi"
- Test, ölçtüğü kodun yüklendiğini önce doğrulasın; parse hatası "tümü geçti" diyebilir
- Test üretim sabitini kopyalamasın, kaynağından okusun
- Sabit kare/süre bekleme güvenilmez; bitiş koşulunu her karede yokla (güvenlik sayacıyla)
- İzleme süresi, ölçülen döngünün periyodundan kısaysa test hiçbir şey kanıtlamaz
- Fonksiyonu elle bir kez çağırmak periyodik çalıştığını kanıtlamaz
- Prob gerçek akışı atlayıp hedef duruma zıplıyorsa gördüğün şey probun eksikliğidir
- Küçültülmüş/izole kurulum gerçek boyutun olasılığını temsil etmeyebilir; en az bir kez gerçek boyutta doğrula
- Prob kırmızı verdiğinde önce ölçüm aracından şüphelen; yanlış kırmızı da yanlış yeşil kadar pahalı
- Sayı geçse bile GERÇEK render'a gözle bak; ince/yarı saydam katmanlarda göz de yanılır, o zaman piksel ÖLÇ
- Çakışma/üst üste binme gözle "temiz görünüyor" ile değil piksel maskesiyle ölçülür
- Mantık testi ile gerçek render testi ayrıdır; yeni ekran için ikisi de zorunlu
- CLI bayrağı hata vermeden çalıştı diye işe yaradığını varsayma; etkisini ayrıca kanıtla
- Mimari değişiklikten sonra o alanı dolaylı test eden ESKİ probları da bul ve koştur
- Her prob sahte APPDATA ile izole; paylaşılan sahte ortam önceki koşumun durumunu miras alabilir, ön koşulunu sıfırla
- Kullanıcı "değişmedi" derse önce test ettiği build'in değişikliği içerdiğini kanıtla
- Sadece masaüstünde doğrulama yetmez; performans hatası hedef telefonda çıkar
