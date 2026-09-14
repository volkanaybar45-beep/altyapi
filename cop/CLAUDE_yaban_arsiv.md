# Yaban Proje Talimatları

## Proje
Match-3 madencilik oyunu (Godot 4.7.1). Oyuncu 6 hayvan taşını
eşleştirir, kömür/kor toplar, atölyede harcar; combo yaptıkça ruh
siluetleri belirir, özel hayvan taşları satır/sütun temizler.

**Kökeni:** Bu oyun `C:\BlokOyun` içinde bir "mod" olarak doğdu
(madde 122-229). 2026-09-06'da AYRI BİR OYUN olarak buraya
sökülmesine karar verildi — sebep: gerçek oyuncular üzerinde test
edildiğinde blok bulmacadan daha çok ilgi çekti. Blok bulmaca
DURDURULDU (rafa kaldırıldı), dosyaları `C:\BlokOyun`da sağlam
duruyor; bu oyun bitince oraya dönülecek.

## Kesin Kararlar (değiştirilemez)
- Parça/taş dağıtımı adil hissettirmeli
- Reklamlar ASLA hamle ortasında kesmez, sadece kazanınca gösterilir.
  Netleştirme: bu kural ZORLA/interstitial reklamlar içindir.
  Oyuncunun KENDİ İSTEĞİYLE, bir bonus için tıklayıp izlediği
  İSTEĞE BAĞLI/ödüllü reklamlar (ör. bir yetenek şarjını hemen
  yenilemek) bu kuralın KAPSAMI DIŞINDA. Ayrım: "zorla mı kesiyor" —
  isteğe bağlı reklam oyuncuyu hiçbir şeye zorlamaz, seçenek sunar.
- Görsel efekt ayarı: Az / Normal / Çok
- Giriş/hesap sistemi YOK
- Gelir modeli: reklam
- Offline oynanabilir olmalı

## Çalışma Kuralları
- Cevapları mümkün olduğunca minimum token harcayacak şekilde ver —
  gereksiz açıklama, tekrar, uzun karşılama/kapanış cümleleri
  kullanma. Kısa, öz, açıklayıcı.
- **Büyük/mimari kararlarda ÖNCE KONUŞ, hemen yazma.** Kullanıcı
  kararı tartışarak olgunlaştırıyor; tek cümleden sonra kararlar.md'ye
  yazmak ya da CLAUDE.md'yi güncellemek onu karar vermiş konuma
  sokar. "Tamam, yaz" gelmeden yazma. (2026-09-06 kullanıcı uyarısı.)
- Değişiklikten önce plan sun, onay bekle.
- "Bitti" deme; "kod yazıldı, telefonda test edilmedi" de.
- Test etmediğin şeyi çalışıyor sayma.
- İşler ters giderse hemen DUR, yeniden planla.
- Basit ve bariz çözümler için plan yapma, aşırı mühendislik yapma.
- Önemsiz olmayan değişiklikler için: dur ve "daha zarif bir yol var
  mı?" diye sor.
- Bir görevi kanıtlamadan tamamlanmış işaretleme, test et.
- Hatalardan sonra `tasks/lessons.md` dosyasını güncelle.
- Kendine sor: "Kıdemli bir mühendis bunu onaylar mıydı?"
- Seans sonunda `/kontrol` çalıştırmamı hatırlat.
- Kullanıcı "çalışıyor" dediğinde git tag at.
- **Prob geçse bile GÖZLE BAK.** Bu projede üç kez, tüm iddiaları
  geçen bir değişiklik ekran görüntüsüne bakılınca bozuk çıktı
  (silüetin HUD'u örtmesi, özel taşın normal taştan ayırt
  edilememesi, combo görsellerinin "ip gibi ince" çıkması).
- `.gd`/`.tscn`/`.tres` dosyalarını DEĞİŞTİRİRKEN Edit/Write aracını
  kullan, Bash/Python/sed ile string değiştirme YAPMA. Sebep:
  otomatik commit + Godot import hata kapısı (PostToolUse hook)
  SADECE Edit/Write aracı kullanıldığında tetikleniyor; Bash
  üzerinden yapılan değişiklikler bu güvenlik ağını atlıyor ve fark
  edilmeyen parse hataları/çoğaltılmış fonksiyonlar teste "yanlış
  yeşil" rapor verdirebiliyor.
- **Headless test veri kaybı:** Godot burada headless çalışabiliyor,
  AMA test/prob betikleri gerçek kayıt/istatistik dosyalarını İKİ KEZ
  ezdi. Her prob/test sahte `APPDATA` ile izole edilecek.

## İki Dillilik — ekrana çıkan HER metin çeviriden geçer

Oyun **Türkçe ve İngilizce** yayınlanacak (kararlar.md madde 26).
Türkçe kaynak dil, İngilizce ikinci dil.

**KURAL: Ekranda görünen hiçbir metin koda gömülü YAZILMAZ.** Hepsi
çeviri dosyasından `tr("ANAHTAR")` ile çağrılır. Yeni bir ekran, buton
ya da bildirim yazılırken metin ÖNCE çeviri dosyasına eklenir.

Gerekçe: dil desteği sonradan eklenirse o güne kadar yazılmış her
ekran ikinci kez açılır. Bu karar, tam da bunu önlemek için ayarlar
ekranından ÖNCE alındı.

**İngilizce çevirileri SENARYO Claude yazar**, KOD Claude uydurmaz.
Oyun metni bir içerik işidir; makine çevirisi ya da tahmin
kullanılmaz. Yeni bir metin gerekiyorsa KOD Claude Türkçesini yazar
ve İngilizcesini SENARYO'dan ister.

*(Kod içi yorumlar, hata ayıklama çıktıları ve prob mesajları bu
kuralın DIŞINDA — onlar oyuncuya görünmüyor.)*

## Renk Paleti — her görsel promptunda ZORUNLU

**`senaryo/RENK_PALETI.md` oyunun renk kimliğidir.** Uydurulmadı;
`maden.gd`/`atolye.gd` sabitlerinden ve mevcut görsellerden çıkarıldı.
Görsel sürümü:
https://claude.ai/code/artifact/f4e2b9ba-7f90-49bf-8f97-62e843004914

**İki farklı kullanım — karıştırma:**
- **Kodda** → değerler BİREBİR uygulanır (`Color(0.85, 0.64, 0.14)`).
  Kabuk, butonlar, paneller, yazılar, plakalar buradan boyanır.
- **Görsel üretiminde** → hex kodu ChatGPT'ye VERİLMEZ, çünkü görsel
  üreticiler hex'i güvenilir şekilde takip etmiyor. Bunun yerine
  **tarif** verilir: "warm amber gold", "icy blue-grey", "deep
  iridescent purple". Tarifler RENK_PALETI.md'nin 1. tablosunda.

**KURAL: SENARYO Claude, yazdığı HER görsel üretim promptuna ilgili
renk tarifini KENDİSİ ekler.** Kullanıcı hex kodlarıyla uğraşmaz,
hatırlatmak zorunda kalmaz. (Kullanıcının 2026-09-06'daki doğrulaması:
"bu paletleri sen her promptta belirteceksin, doğru mu anladım" —
evet.)

Üretilen görsel geldiğinde palete karşı KONTROL edilir; sapma varsa
kullanıcıya söylenir.

**Beş kullanım kuralı** RENK_PALETI.md'nin sonunda. En kritik ikisi:
- **Altı hayvan rengi SADECE hayvan kimliğidir** — menüde süs rengi
  olarak kullanılmaz.
- **Kırmızı yalnızca Tilki'nindir** — hata/tehlike için kırmızı
  kullanılmaz, Tilki'yle karışır.

## Görsel/Ses Dosyası Takibi (kayit.md)
- Her oturum başında ve her mesajda `yaban/assets/gorseller` VE
  `yaban/assets/sesler` klasörlerini tara
- Her klasörün kendi `kayit.md` dosyası olur; yoksa oluştur
- kayit.md'de kaydı olmayan yeni bir dosya bulursan, kullanıcıya o
  dosyayı hangi araç/siteyle, hangi promptla ürettiğini sor
- Cevap gelince kayit.md'ye ekle: dosya adı, tarih, kaynak/araç,
  prompt, format
- Ekleme sonrası commit at
- Aynı dosya için sorduktan sonra, cevap gelene kadar aynı oturumda
  tekrar tekrar sorma

## Oyuncu Araştırması — TASARIM KARARLARININ DAYANAĞI

**`arastirma/` klasörü bu projenin en değerli varlıklarından biridir.**
4401 gerçek Play yorumu, iki turda çekildi. Tasarım kararları TAHMİNLE
değil, buradaki veriyle verilir.

| Tur | Ne | Nerede |
|---|---|---|
| 1 | 2400 Türkçe yorum, dev **satın almalı** oyunlar | `ozet_girdi.md` · analiz: kararlar madde 10 |
| 2 | 2001 İngilizce yorum, bedava **reklamlı** oyunlar (BİZİM modelimiz) | `ozet_girdi_2.md` · analiz: kararlar madde 12 |

Ham veri `arastirma/ham/*.json` içinde, commit'li.

**Kural: oynanış, reklam, görev, zorluk ya da arayüz hakkında bir
karar verilirken ÖNCE madde 10 ve madde 12'deki bulgulara bakılır.**
Bir bulguyla çelişen öneri yapılacaksa, çeliştiği AÇIKÇA söylenir.

**Veriden çıkan ve ASLA unutulmaması gereken altı şey:**
1. Bu türün oyuncusu **sakinlik** arıyor, heyecan değil. ("stres atmak
   için oynuyoruz, siz strese sokuyorsunuz" / "timed games are not
   relaxing")
2. **Reklam sıklığı oyun öldürür.** "Her bölüm sonrası reklam"
   nefret edilen 1 numaralı şey. Sıklık sınırı ŞART.
3. **Ödüllü reklamın ödülü GARANTİ** verilir — reklam yüklenmese,
   kesilse, internet gitse bile.
4. **Zorunlu hiçbir şey olmayacak** — zorunlu etkinlik, zorunlu
   turnuva, zorunlu hesap, kapatılamayan ipucu. Hepsi nefret ediliyor.
5. **Offline ve Türkçe** bizim bedava avantajlarımız, öne çıkarılacak.
6. **Çökme = doğrudan 1 yıldız.** Kararlılık her özellikten değerli.

Araştırma tekrarlanabilir: `arastirma/oyun_bul.py` paket adı bulur,
`arastirma/yorum_cek.py` yorumları çeker. Yayından sonra KENDİ
oyunumuzun yorumları için de aynı yöntem kullanılacak.

## Odak Kuralı ve SIRA sistemi

**`senaryo/SIRA.md` projenin nabzıdır. Her oturum başında ÖNCE oraya
bak.** Üç liste var: ŞU AN (tek iş), SIRADA (kuyruk), BİTTİ (kilitli).

- **ŞU AN'da her zaman TEK bir iş olur.** O iş KİLİTLENMEDEN yenisine
  geçilmez.
- **Kilitli = telefonda test edildi ve kullanıcı "çalışıyor" dedi.**
  Kod yazılmış olması kilit DEĞİLDİR.
- İş kilitlenince BİTTİ'ye taşınır, SIRADA'dan bir sonraki çekilir.
- Arada yeni fikir gelirse SIRADA'nın uygun yerine YAZILIR — o an
  yapılmaz, ama unutulmaz da. (Kullanıcının kendi sözü: "aklımıza
  geleni kayıt almayınca unutuluyor.")
- Uzun/serbest fikirler `senaryo/yeni_fikirler.md`de durmaya devam
  eder; SIRA.md kısa ve sıralı kuyruktur.

**Kapsam ŞİMDİDEN dondurulmuyor.** Kullanıcının kararı (2026-09-06):
serbest çalışılacak, akla geleni deneyip bitireceğiz. "Beta
çıkıyoruz" denildiği gün BİTTİ listesi v1.0 / v1.1 diye ikiye
bölünecek. Her iş bitmiş olduğu için o ayırma kısa sürer — bu yüzden
"her şey bitmiş olsun" şartı pazarlık konusu değildir.

## Roller
- SENARYO Claude: `senaryo/kararlar.md` dosyasına yazar, koda dokunmaz
- KOD Claude: `yaban/` içindeki kodu yazar, `tasks/todo.md` ve
  `tasks/lessons.md` dosyalarını günceller, `senaryo/kararlar.md`'yi
  okur ama yazmaz

## Karar Yetkisi
- Küçük/tersine çevrilebilir kararları kendi başına ver, sorma
- Mimariyi değiştiren, geri dönüşü olmayan veya oyunun temel
  kurallarını (adalet, reklam kuralı) etkileyen kararlarda DUR ve
  kullanıcıya sor

## Versiyon Kontrolü (Git)
- Bu proje git ile takip edilir, `C:\Yaban` kendi reposu
- Uzak repo: `origin` → (henüz kurulmadı, GitHub'da ayrı repo açılacak)
- Yeni bir görsel, ses dosyası veya önemli bir kod değişikliği
  eklendiğinde PostToolUse hook otomatik commit'ler ve push'lar
- Commit mesajı değiştirilen dosyayı ve tarihi içerir
- Push başarısız olursa hata sessizce yutulur, bir sonraki commit'te
  tekrar denenir
- Bu davranış `.claude/settings.json` içindeki hook ile sağlanır,
  manuel commit/push atmaya gerek yoktur
- **Auto-commit hook'u ASLA zayıflatma** — kullanıcı bunu bir kanıt
  zinciri olarak istiyor
- APK/build dosyaları `.gitignore`da (GitHub 100 MB limiti, bir kez
  936 commit boyunca push'u bloklamıştı)
