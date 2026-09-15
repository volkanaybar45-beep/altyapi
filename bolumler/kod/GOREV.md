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

## Güvenlik (anayasadaki politikanın kod karşılığı)
- Anahtar/parola/keystore koda ve depoya girmez; gerekirse ortam değişkeni
- Kayıt dosyası okunurken: alan tipleri doğrulanır, eksik alan varsayılana
  düşer, `eval`/dinamik kod çalıştırma YOK. Bozuk kayıt çökme değil sıfırlama
- `OS.execute`, dosya sistemi ve ağ çağrıları gerekmedikçe kullanılmaz
- Android izin listesi boş tutulur; eklenen her izin RAPOR'da gerekçelenir
- Analitik/çökme raporu eklenecekse önce patrona sorulur (veri toplar)
- Hata mesajları oyuncuya dosya yolu/iç bilgi göstermez

## Dersler
- (2026-09-14) Godot import kapısı `--import` ile parse hatası yakalamıyor; `.gd` için `--check-only --script` kullanılır
- (2026-09-14) Hook'a gelen dosya yolunun sonunda Windows satır sonu (`\r`) olabilir; `tr -d '\r'` ile temizlenmezse uzantı eşleşmesi sessizce başarısız olur ve kapı HİÇ çalışmaz

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

## Görsel/uzamsal işlerde ÖNCE HESAP (patron kuralı, 2026-09-15)
Kurucu hatırlatmak zorunda kalmasın: görsel, yerleşim veya hareket içeren her
iş emrinde matematik/geometri/fizik ÖNCEDEN çıkarılır, iş emrine sayı olarak
yazılır. "Bakınca düzeltirim" turu israftır.
- Perspektifli arka plan + düz oyun alanı bir arada kullanılıyorsa çatışmayı
  ADLANDIR ve hangisinin öncelikli olduğunu karara bağla (okunurluk > atmosfer)
- Sprite'lar arka planla aynı kamera açısından render edilir; açı yazılır
- Derinlik: uzaklık-ölçek oranı yüzdeyle verilir, "biraz küçük" denmez
- Oturma noktası (alt-orta mı, merkez mi), yansıma yüksekliği, alfa, sönümleme
  sayıyla yazılır
- Işık yönü TEK olur ve yazılır; ters yönden aydınlatma yasak
- Kontrast hedefi en açık zemin bandında ölçülür, medyanda değil
- Siluet ayrımı gri tonda kanıtlanır (renk körlüğü)
