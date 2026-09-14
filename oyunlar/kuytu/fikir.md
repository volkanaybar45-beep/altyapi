# Kuytu — Aşama 1: Fikir

Çalışma adı. Tür: sakin blok yerleştirme. Karar: 2026-09-14.

## Tek cümle
Izgaraya parça yerleştirip sıraları temizlediğin, süresi ve kaybı olmayan,
istediğin an bırakıp istediğin an dönebildiğin sessiz bir bulmaca.

## Aşama 1 soruları
1. **Ne zaman açılır?** Yatakta, sırada beklerken, molada. Tek eliyle, sessizde.
2. **30 saniyede ne yapar?** 3 parçadan birini ızgaraya sürükler, sıra dolunca
   temizlenir. Tekrar açma sebebi: yarım kalan tahta ve "bir hamle daha" hissi.
3. **Reklam nerede?** Bölüm sonu zorunlu reklam YOK. Sadece isteğe bağlı ödüllü
   reklam (tahtayı toparlama gibi), ödülü garanti verilir.
4. **Offline?** Evet, tamamen. Hesap yok, giriş yok, internet yok.
5. **Hangi veri destekliyor?** 125 yorum çökme/açılmama · 36 yorum reklam
   sıklığı · 53 yorum para tuzağı · "rahatlatıcı" denen oyunun düşük puanlı
   yorumlarının dörtte biri "hiç rahatlatıcı değil" · az özellikli küçük oyunlar
   4.3-4.6, agresif büyük oyunlar 2.9-3.4 puan.

## Sakinlik nasıl sağlanır (bu oyunun sözü)
- Süre yok, geri sayım yok, yanıp sönen kırmızı yok
- **Oyun bitmez.** Yer kalmadığında "kaybettin" ekranı değil, tahta nazikçe
  toparlanır ve devam edersin (yöntem prototipte denenecek)
- Can/enerji yok, bekleme yok, günlük görev yok, turnuva yok
- Ses varsayılan kapalı; açıksa yumuşak
- Puan görünür ama öne çıkmaz; rekabet yok

## Görsel yön (kurucu kararı, 2026-09-14)
- **Tahta sade kalır.** Yoğun tahta göz yorar: en fazla **4 özel görsel**,
  geri kalan düz ve sessiz. Zemin dingin, kontrast düşük
- **Efektler çarpıcı olur.** Sakinlik tahtada, heyecan hareket ve ışıkta:
  kare parçalanması, sıra temizlenmesi ve kombo anları "vay" dedirtmeli
- Bu ikisi çelişmez: durağan görüntü sade, hareket zengin
- Efekt sadece oyuncunun kendi hamlesine cevap verir; kendiliğinden yanıp
  sönen, dikkat çeken şey yok
- **Ana ekran şart:** oyunu açınca karşılayan sakin bir giriş ekranı
- Üretim: ChatGPT (2B) → Tripo Pro (3B) → `toon_render.py`. Efektlerin
  çoğu koddan (parçacık, tween), görselden değil

### Varlık listesi (Aşama 2 için en az)
1. 4 blok/parça görseli — birbirinden siluetle ayrılır, renk körlüğüne dayanıklı
2. Tahta zemini (tek, sade)
3. Ana ekran arka planı + oyun adı
4. Parçacık dokusu (kırılma/ışık için 1-2 küçük görsel)

## Prototipte cevaplanacak açık sorular
1. Tıkanma anı nasıl çözülür ki hem sakin kalsın hem anlamsızlaşmasın?
2. Izgara kaç kare, aynı anda kaç parça sunulur?
3. Tek başına bir hamle tatmin edici mi? (his meselesi, kodla değil elle ölçülür)

## Kapı ölçütü (Aşama 2'ye geçiş)
Kurucu telefonda oynadı ve bırakmak istemedi.
