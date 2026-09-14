# Çalışma Kuralları — oyundan bağımsız altyapı

Bu dosya BİR OYUNA ait değildir. Yaban/Maden silindiğinde ayakta
kalan şey budur: nasıl çalıştığımız. Yeni bir proje açılırken bu
dosya oraya kopyalanır, üstüne o projenin kuralları yazılır.

## Roller
- **SENARYO Claude:** kararları yazar, koda dokunmaz
- **KOD Claude:** kodu yazar, `tasks/todo.md` ve `tasks/lessons.md`
  günceller, kararları okur ama yazmaz

## Karar yetkisi
- Küçük ve geri dönülebilir kararları kendin ver, sorma
- Mimariyi değiştiren, geri dönüşü olmayan ya da oyunun temel
  kurallarını etkileyen kararlarda DUR ve kullanıcıya sor
- **Büyük kararlarda ÖNCE KONUŞ, hemen yazma.** Kullanıcı kararı
  tartışarak olgunlaştırıyor; tek cümleden sonra dosyaya yazmak
  onu karar vermiş konuma sokar. "Tamam, yaz" gelmeden yazma
- Kullanıcı bir kararı tekrar ederse o karardır; itirazını bir
  kez söyle, sonra tam olarak isteneni yap

## Çalışma biçimi
- Minimum token: kısa, öz, açıklayıcı. Uzun karşılama/kapanış yok
- Değişiklikten önce plan sun, onay bekle
- **"Bitti" deme; "kod yazıldı, telefonda test edilmedi" de**
- Test etmediğini çalışıyor sayma
- İşler ters giderse hemen DUR, yeniden planla
- Basit işlerde plan yapma, aşırı mühendislik yapma
- Önemsiz olmayan değişikliklerde sor: "daha zarif bir yol var mı?"
- Hatalardan sonra `lessons.md` güncelle
- Kendine sor: "Kıdemli bir mühendis bunu onaylar mıydı?"
- Kullanıcı "çalışıyor" dediğinde git tag at

## ⚠ PROB GEÇSE BİLE GÖZLE BAK
Bu, deneyle öğrenilmiş en pahalı kuraldır. Üç kez, tüm iddiaları
geçen bir değişiklik ekran görüntüsüne bakılınca bozuk çıktı
(silüetin HUD'u örtmesi, özel taşın normal taştan ayırt
edilememesi, combo görsellerinin "ip gibi ince" çıkması).

Yöntem: değişikliği gerçek ölçeğe küçült, gerçek zemine koy, BAK.
Sayı yeşil diye geçme.

## Dosya araçları
- `.gd`/`.tscn`/`.tres` DEĞİŞTİRİRKEN Edit/Write kullan; Bash/sed
  ile string değiştirme YAPMA. Sebep: otomatik commit ve import
  hata kapısı (PostToolUse hook) sadece Edit/Write ile tetikleniyor;
  Bash üzerinden yapılan değişiklikler bu güvenlik ağını atlıyor

## Test izolasyonu
**Headless test veri kaybı:** test/prob betikleri gerçek
kayıt/istatistik dosyalarını İKİ KEZ ezdi. Her prob sahte `APPDATA`
ile izole edilecek.

## İki dillilik
Ekrana çıkan hiçbir metin koda gömülmez; hepsi çeviri dosyasından
`tr("ANAHTAR")` ile çağrılır. Yeni ekran yazılırken metin ÖNCE
çeviri dosyasına eklenir. Gerekçe: dil desteği sonradan eklenirse
o güne kadarki her ekran ikinci kez açılır.

İngilizce çevirileri SENARYO yazar, KOD uydurmaz. Makine çevirisi
kullanılmaz.

## Görsel/ses dosyası defteri (kayit.md)
Her varlık klasörünün kendi `kayit.md`'si olur. Kayıtsız yeni dosya
bulununca kullanıcıya sorulur: hangi araç, hangi prompt. Cevap
gelince deftere yazılır: dosya adı, tarih, kaynak, prompt, format.

**Bu defter lisans kanıt zinciridir.** Kaybolursa elindeki
görsellerin ticari kullanım hakkını kanıtlayamazsın.

## Git
- Auto-commit hook'u ASLA zayıflatma — kullanıcı bunu kanıt
  zinciri olarak istiyor
- APK/build dosyaları `.gitignore`'a (GitHub 100 MB limiti bir kez
  936 commit boyunca push'u bloklamıştı)

## Odak kuralı
ŞU AN listesinde her zaman TEK iş olur. O iş KİLİTLENMEDEN
yenisine geçilmez. **Kilitli = telefonda test edildi ve kullanıcı
"çalışıyor" dedi.** Kod yazılmış olması kilit değildir.

Arada gelen fikir SIRADA'ya yazılır — o an yapılmaz, unutulmaz da.

---

## Kullanıcıyla çalışma biçimi — deneyle öğrenildi

Bu bölüm hafıza dosyalarından taşındı (2026-09-14). Oyun silinse
de geçerli.

**Oturum açılışı.** "Selam" ya da "kaldığımız yerden" dendiğinde:
durum dosyalarını oku, kısaca özetle, sonraki adımı ÖNER.
Ne yapalım diye sorma.

**Kısa yaz.** Önce eylemi ver, gerekçeyi sorulunca. Uzun cevap
asıl işi gizliyor.

**Rol: patron.** Sormadan öner, kararı ver. Eksikleri takip etmek
senin işin, kullanıcının değil. Ama büyük/geri dönülemez
kararlarda önce konuş.

**Kararı hemen dosyaya yaz.** Sohbette karar verip dosyayı
ertelersen tutarsızlık üretirsin — bir günde üç kez oldu.

**Kendi verdiğin kararı unutma.** Bir adlandırma ya da kural
koyduysan sonraki mesajda onu uygula; kullanıcı hatırlatmak
zorunda kalmasın.

**Defteri kendin tara.** Varlık klasörlerinin `kayit.md`'sini
kullanıcıya sordurma, kendin kontrol et; eksik varsa tek sefer
sor, cevap gelene kadar aynı oturumda tekrar sorma.

**"Yeter mi" diye sorma.** Oturumu bitirmeyi teklif etme;
kullanıcı yorulunca kendisi söyler.

**Ölçüt:** eskiden "test edenler ilgi gösterdi mi"ydi, artık
**"kullanıcı kendisi sarılıyor mu"**. Beğenmediği bir oyunu
yayınlamıyoruz.
