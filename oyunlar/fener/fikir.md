# Fener Bekçisi — Aşama 1: Fikir

Karar: 2026-09-14 (kurucu seçti). Prototip yarışı: bu vs. Ateşböceği Bahçesi.

## Tek cümle
Gece denizinde aynaları ve fenerleri çevirip ışığı gemiye ulaştırırsın.

## Ana hareket
Dokunarak bir aynayı çevir. Işık ışını yansır, yol değişir. Gemiye ulaşınca
bölüm açılır.

## Neden sakin
Süre yok, hamle sınırı yok, yanlış hamle cezası yok. İstediğin kadar çevir.

## Neden "vay" der
Sis, gece denizi, ışık huzmesi. Zincir tamamlanınca ışık bütün güzergâh
boyunca bir anda yanar, sis açılır, tekne düdük çalıp limana girer.

## Neden bu oyun (kurucu gerekçesi, 2026-09-14)
- Tek cümlelik vaat: **"Işığı gemiye ulaştır."** Reklam videosunda 3 saniyede
  gösterilir. Match-3 ve blok yerleştirmenin olmayan avantajı bu
- Aranan his: "bunu daha önce görmedim ama nasıl oynandığını hemen anladım"
- Tema değiştirmek yeni oyun yapmaz — meyve yerine balık koymak sıyrılma değildir

## Gemi çeşitliliği (karar, 2026-09-14)
**Tek model, çok renk.** Yeni model = Tripo + render + defter; oyuncunun
gördüğü fark küçük. Renk varyantı koddan (aynı görsel, ton değişimi) bedava.
- Renk ileride MEKANİK olur: renk filtresi gelince kırmızı tekne kırmızı ışık ister
- Bölücülü bölümlerde iki tekne renkle ayrılır, ikinci modele gerek yok
- Çeşitlilik hissini ortam ve mevsimler taşır: aynı tekne, farklı deniz
- İkinci siluet SADECE oyuncunun ayırt etmesi gereken bir kural doğarsa gelir
  (örn. büyük gemi iki ışık ister)

## Referans 2 — yoğun mockup'lar (2026-09-14)
Kurucu üç ChatGPT mockup'ı getirdi: fotogerçekçi ada, şelale, kasaba, çok
sayıda ayna, prizma, HUD dolu.

**ALINMADI, gerekçesiyle:**
- Yoğunluk ışını öldürüyor. Oyunun kahramanı ışık çizgisi; kalabalık sahnede
  kayboluyor. Bizim ekran koyu ve boş kalacak ki ışık parlasın
- Fotogerçekçi üslup tek kişiyle her bölüm için üretilemez (içerik değirmeni)
- HUD'daki altın, ipucu sayacı, 5 güçlendirici → "para tuzağı yok, zorunlu
  hiçbir şey yok" sözüne aykırı

**ALINDI:**
1. **Prizma:** ışığı renklere ayıran nesne. Çekirdeğe yeni sistem yazmadan
   oturur, bölüm çeşitliliğini katlar
2. **Çoklu hedef:** "3 tekneyi aynı anda limana al", renk eşleştirmeli
3. Sis/fırtına havası — zaten merdivende vardı, referans haklılığını gösterdi

**Üslup kararı:** koyu gece · az nesne · sade siluet · **tek parlak şey ışık.**
Referansın kalabalığı değil, kalabalığın hissi.

## Çekirdeği genişletme merdiveni (yeni sistem yazmadan)
Aynı mekanik, artan varyasyon: sis · yağmur · kırık ayna · renkli ışık
(renk filtresi) · aynı anda iki gemi · hareketli ayna. Her biri yeni kod
değil, aynı çekirdeğin parametresi.

### Seviye merdiveni (referans 3'ten, 2026-09-14)
| Bölüm | İçerik |
|---|---|
| 1-10 | Temel mekanik: ayna çevir, ışığı gemiye ulaştır |
| 11-20 | Yeni öğeler: kayalık, sabit ayna, prizma |
| 21-30 | Zorlu düzenler (aynı öğeler, daha iyi bulmaca) |
| 31-40 | Hava koşulları: sis, yağmur |
| 41-50 | Çoklu hedef: birden fazla gemi, renk eşleştirme |
| 51-70 | Hareketli öğeler: kayan platform, dönen ayna |
| 71+ | Usta seviyeler |

Ortam serisi: sakin akşam → fırtınalı gece → buzlu deniz → tropik →
volkanik → kutup ışıkları. Her biri arka plan + palet değişimi.

### ASIL KANCA: dünyayı ışıkla geri getirmek (2026-09-14)
Oyunun sözü "bulmaca çöz" değil, **"karanlık bir yeri geri getir."**

- Ada/liman bölüm başında karanlık ve ölü görünür
- Bölüm çözülünce sadece gemi kurtulmaz: evlerin ışıkları yanar, iskele
  canlanır, martılar gelir, ses katmanı eklenir
- 20 bölüm sonunda karanlık liman, yaşayan sıcak bir köye dönüşmüş olur
- Oyuncunun cümlesi: "puzzle çözmedim, bir yeri kurtardım"

**Maliyet kontrolü:** yeni sahne değil, tek arka planın üstüne sönük→yanık
katmanlar. Her katman bir PNG + bir fade. Bu yüzden karşılanabilir.
Uzun ömür sorununun (bölüm tekrarı) asıl cevabı budur.

### Mevsimler (kurucu fikri, 2026-09-14)
Hava koşulları tek çatı altında: ilkbahar (dingin, açık) → yaz (güneş, parlak
su) → sonbahar (rüzgâr, dalga) → kış (kar, buz). Yağmur, fırtına ve sis
mevsimlerin içine dağılır.

- **Takvime BAĞLANMAZ, ilerlemeye bağlanır.** Gerçek tarihe bağlanırsa
  "kaçırdım" hissi doğar; bizim kaçındığımız baskı budur. Oyuncu kendi
  hızında yaşar, hiçbir şeyi kaçırmaz
- Maliyeti düşük: palet + parçacık + arka plan tonu. Yeni mekanik gerekmez
- Hava, oyunu ZORLAŞTIRMAZ; sadece dekordur. Zorluk bulmacadan gelir
  (istisna: sis ve fırtına, merdivende bilinçli mekanik olarak duruyor)

**ÇIKARILANLAR:** "zamanlama" mekaniği (geri sayım), **"sınırlı hamle"**,
"günlük görevler", enerji/can sistemi, çoklu para birimi, koleksiyon/karakter
geliştirme. Gerekçe: ilk üçü baskı üretir (sakinlik sözü), son üçü tek kişiyi
batırır. İlk sürümde meta sistem YOK — önce 20 çok iyi bölüm.

**Alınanlar:** kırık ayna (tamir et) · ışık renkleri · hareketli platform ·
özel ışık hedefleri · kozmetik fener geliştirme · hikâye parçaları/mektuplar.

### İsim ve slogan (aday)
**Fener Bekçisi — "Küçük Işıklar, Büyük Yolculuklar"**
Mağaza vaadi: tek parmakla oynanır · offline · reklam destekli · sakin.

## Reklam modeli (oyunu bozmadan)
- Bölüm sonu ödülünü ×2 yapan isteğe bağlı reklam
- İsteğe bağlı ipucu
- İkinci şans (ama bizde kaybetme yok; "bölümü atla" olarak düşünülecek)
- Zorunlu araya giren reklam YOK. Ödül her hâlükârda garanti verilir
- Not: "reklam destekli oyunlar indirmelerin %83'ü" verisi kurucudan geldi,
  BİZ DOĞRULAMADIK. Karar buna dayanmıyor

## AÇIK RİSK — dürüst kayıt
Bu bir **bölüm oyunu**: her bölüm elle tasarlanır. Oyuncu bölümleri tüketir,
biz sürekli yeni bölüm üretmek zorunda kalırız. Kurucu bunu bilerek kabul etti
(2026-09-14): "oyun tutar reklamlardan ciddi para kazandırırsa bölüm tasarlarız."
Azaltma yolu: bölümlerin bir kısmını üreteçle kurup elle rötuşlamak — prototipte
denenecek.

## Prototipte cevaplanacak
1. Ayna çevirip ışığı yönlendirmek tatmin edici mi?
2. Bir bölüm tasarlamak ne kadar sürüyor? (içerik maliyetinin gerçek ölçüsü)
3. Bölüm üreteci mümkün mü?

## Kapı ölçütü
Kurucu telefonda oynadı ve bırakmak istemedi.
