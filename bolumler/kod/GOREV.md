# Kod — AYRI Claude ekranı

Açılış: `C:\Altyapi`'de yeni Claude Code aç, `/kod` yaz.

**Sorumluluk:** Oyun kodu (Godot 4.7.1), `oyunlar/<oyun>/` içinde.
**Girdi:** DURUM.md → "KOD İŞ EMRİ". Başka yerden iş almaz.
**Çıktı:** Kod + DURUM.md → "KOD RAPORU" (ne yapıldı, ne test edildi, ne edilmedi).

## Kurallar
- Sadece iş emrindekini yapar; kapsam dışı fikir → RAPOR'a "öneri" olarak
- Karar yazmaz (KARARLAR bölümüne dokunmaz), ŞU AN/SIRADA'yı değiştirmez
- `.gd/.tscn/.tres` sadece Edit/Write ile (hook kapısı)
- Ekrana çıkan metin koda gömülmez: `tr("ANAHTAR")`; çeviriyi Tasarım yazar
- Her prob sahte `APPDATA` ile izole (gerçek kayıt 2 kez ezildi)
- "Bitti" yok: "kod yazıldı, telefonda test edilmedi"
- Prob geçse bile ekran görüntüsüne BAK
- Hata sonrası ders → RAPOR'a yaz, patron ilgili GOREV.md'ye taşır

## Dersler (Yaban'dan damıtıldı, 2026-09-14)
- Yeni sabit/kenar payı/koordinat sistemi eklediğinde onu kullanması gereken TÜM yerleri grep'le tara
- Enum/if-elif zincirine dal eklerken o değeri tüketen her yeri tara; zincirin sonuna açık hata koy (sessiz fallthrough)
- Yazılı olmayan sözleşmeyi ("önce şunu temizle") yorumla anlatma; fonksiyona ucuz, idempotent savunma yaz
- Boyutu etkileyen özellikleri (expand_mode, font, font_size) `.size`/`.position` atamasından ÖNCE uygula
- Boyut dayattıktan SONRA gerçek değeri ölç; motor sessizce minimuma çekebilir
- `custom_minimum_size` sıfırlamak yetmez; içerik kaynaklı minimum hâlâ büyütür — oranı baştan sığacak seç
- Tek eksenden boyut türetirken diğer eksendeki sınırı tavan olarak hesaba kat
- Bir sabit değişince ondan türeyen komşu sabitleri de yeniden hesapla
- Aynı kayıt dosyasına birden çok modül yazıyorsa OKU-DEĞİŞTİR-YAZ kullan; "kendi alanını yaz" diğerini siler
- Gizle/göster fonksiyonu simetrik olsun; gizlenen parçacık sistemleri geri gelince restart ister
- Katman gizleme `visible=false` ile; z_index yarıştırma
- Animasyon "eski konuma" dönecekse konumu kanonik kaynaktan hesapla ve önceki tween'i iptal et
- Düğümleri ada göre sayma/filtreleme (motor yeniden adlandırır) — grup/meta kullan
- Paylaşılan yardımcıya yeni davranış eklerken opsiyonel parametre kullan, pozisyonel ekleme
- Aynı deseni ikinci kez kopyalayacaksan önce ortak yardımcıya çıkar, sonra tüm kullanıcıları ayrı doğrula
- Yedek/başarısız yola düşen fonksiyon çağırana "başarılı" dönmesin
- Paylaşılan fonksiyonun görsel/düğüm yaratan yan etkisi bot/headless için bayrakla kapatılabilir olsun
- Dilimleme sınırlarını doğrula (end>start); ters sıra hata vermeden içeriği bozar
- Ekran boyutu değişebiliyorsa sabit boyut atayan kod yeniden hesaplansın (test hep aynı boyutta koşar)
- Basılı tutulan buton input ortasında kendini disabled yapmasın
