# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Fener: zorluk tavanını yükselt + ışık bölücü (KOD, İŞ 4)

## SIRADA
1. `oyun-calistir` skill'i oyundan bağımsız yap (import kapısı hook'u yapıldı)
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 4 — Zorluk tavanı + ışık bölücü** (2026-09-14)
Kurucu üretilen 10 bölümü oynadı: **"çok zor değil."** Saf ayna+kaya ile tavan
düşük. İki koldan yükselt. Süre/hamle sınırı/kaybetme YİNE YOK.

1. **Işık bölücü** (planda 31. bölümdü, öne alındı): ışını ikiye ayıran nesne.
   Tek fener → iki kol → iki tekne (ya da iki kol birleşip tek tekneye).
   Çözücü, ölçer ve üreteç bölücüyü tanımalı
2. **Izgarayı büyüt:** 7×12 dar kaldı, üreteç yolu sığdıramadığı için 28484
   deneme boşa gitti. Daha büyük ızgara + gerekiyorsa dokunma hedefini koru
3. **Zor bölüm eşiklerini yükselt:** zor sınıfı için `max_backtrack ≥ 4`,
   `solution_toggles ≥ 6`, `near_misses` 2-3, **"aha" ZORUNLU**
4. Üreteci koştur, yeni **8 bölüm** seç: 4 bölücülü, 4 bölücüsüz ama en zor
   eşikleri geçen. Mevcutların yanına ekle
5. RAPOR: yeni eşiklerle kaç üretildi/elendi, seçilenlerin metrikleri, ve
   **bölücülü bölümlerin geri dönüş değeri bölücüsüzlerden yüksek mi**
6. Ekran görüntüsü al, GÖZLE BAK (iki kollu ışın karışık görünüyor mu?)

Kapsam dışı: renk filtresi, görsel entegrasyonu, ses, reklam, ana ekran.

**İŞ 3 (BİTTİ) — Bölüm üreteci + zorluk ölçümü** (2026-09-14)
Önce `oyunlar/fener/tasarim_notlari.md` oku (bölüm 3 ve 4 bu işin şartnamesi).
Kurucu kararı: **dönüş adımı 90°, KİLİTLİ.** 45° kodu kaldırılır; ileride
gerekirse ayrı bir "eğik ayna" nesnesi olarak döner, ayar olarak değil.

1. 45° modunu ve mod düğmesini kaldır; `levels.gd` bölümlerini 90°'ye göre
   doğrula (çözücü hepsini tekrar geçsin)
2. **Zorluk ölçer:** tasarım notları 3'teki metrikleri çıkar —
   `solution_count` · `solution_toggles` · `solution_reflections` ·
   `relevant_mirrors` / `irrelevant_mirrors` · `expanded_states` ·
   `max_backtrack` · `near_misses` · `beam_crossings`.
   Puan = %30 arama eforu + %25 geri dönüş + %20 çevirme + %15 yansıma +
   %10 near-miss, havuzda 0-1'e normalize
3. **Üreteç (tersine kurulum):** önce güzel ışık yolu üret → kaya koy →
   kestirmeleri kapat → aynaları yanlış yöne çevir → çözücüyle doğrula →
   zorluk ve kalite ölç → ELE / TUT. "Çözülebiliyor = iyi" KABUL EDİLMEZ
4. **Kalite filtresi** (tasarım notları 4'teki tablo) uygulanır. Ayrıca
   "aha" işareti: çözüm, ışığı hedeften önce UZAKLAŞTIRMAYI gerektiriyorsa
   bölüm puanı artar
5. Üreteci koştur, filtreden geçen **10 bölüm** seç: 3 kolay · 4 orta ·
   3 zor. Mevcut bölümlerin yerine değil, yanına koy (kurucu karşılaştıracak)
6. RAPOR'a yaz: kaç bölüm üretildi, kaçı elendi, hangi ölçütten elendi,
   seçilen 10 bölümün zorluk puanları
7. Ekran görüntüsü al, GÖZLE BAK

Kapsam dışı: ışık bölücü ve renk filtresi (V1'de var ama sonraki iş),
görsel entegrasyonu, ses, reklam, ana ekran.

**İŞ 2 (BİTTİ) — Fener prototipi, zorluk turu** (2026-09-14)
Kurucu masaüstünde oynadı: "keyifli ama çok hızlı buluyor yolunu."
Mekanik geçti, ZORLUK yetersiz. Süre/hamle sınırı/kaybetme EKLEME.

1. Işığı kesen **kayalık** ekle (ışın çarpınca durur)
2. **Sabit ayna** ekle: görünüşte farklı, çevrilemez (siluetle ayırt edilir —
   renk değil, Yaban dersi)
3. Zorluğu "çevirme sayısıyla" değil **yapıyla** artır: ışığın sırayla birden
   fazla aynadan geçmesi gereken bölümler
4. 6 bölüm daha kur: giderek zorlaşsın, sonuncusu kurucuyu 1-2 dakika düşündürsün
5. **45° (8 yön) ve 90° (4 yön) iki sürüm** yap, biri tuşla/ayarla seçilebilsin —
   kurucu ikisini de deneyip karar verecek
6. Ekran görüntüsü al, GÖZLE BAK. Bitince RAPOR'u doldur

Kapsam dışı: görsel üretimi, ses, ana ekran, reklam, bölüm üreteci (sonraki iş).

**İŞ 1 (BİTTİ) — Fener Bekçisi prototipi** (2026-09-14)
Önce `oyunlar/fener/fikir.md` oku. Amaç: ayna çevirip ışığı yönlendirmenin
tatmin edici olup olmadığını ölçmek. Görsel üretme; çizgi, daire, dikdörtgen
yeter. Godot 4.7.1: `C:/DevTools/Godot/4.7.1/`

1. Proje: `oyunlar/fener/proto/` · dikey (portre) · mobil çözünürlük
2. Sahne: koyu zemin, bir fener (ışık kaynağı), 3-5 ayna, bir tekne (hedef)
3. Aynaya dokununca 45° döner. Işın fenerden çıkar, aynalardan yansır,
   tekneye ulaşırsa bölüm tamam
4. Işın her karede yeniden hesaplanır ve çizilir — oyuncu ışığı canlı görür
5. Ulaşınca: ışık güzergâh boyunca parlasın, kısa bir kutlama (tween yeter)
6. **Süre yok, hamle sınırı yok, kaybetme yok.** İstediği kadar çevirir
7. 3 bölüm elle kur: kolay (2 ayna) · orta (3-4) · şaşırtan (ışın kesişiyor)
8. **Ölç ve RAPOR'a yaz: bir bölümü kurmak kaç dakika sürdü?** Bu sayı
   oyunun tek kişiyle sürdürülebilir olup olmadığını belirleyecek
9. Metin varsa `tr("ANAHTAR")`
10. Çalıştır, ekran görüntüsü al, GÖZLE BAK. Bitince RAPOR'u doldur

Kapsam dışı: Ateşböceği prototipi (İŞ 2), görsel üretimi, ana ekran, ses,
reklam, sis/yağmur/renkli ışık varyasyonları, bölüm üreteci.

## KOD RAPORU (KOD yazar)
**İŞ 4 — Zorluk tavanı + ışık bölücü · kod yazıldı, telefonda test edilmedi** (2026-09-14)

**Yapılan**
- **Işık bölücü** (harita harfi `Y`): sabit elmas prizma, dönmez. Gelen ışını durdurur,
  sağına ve soluna iki kol çıkarır. Bölücülü bölümde **iki tekne** var, bölüm ikisi
  de ışık alınca biter; ışık alan tekne bölüm bitmeden de parlıyor. "İki kol tek
  teknede birleşir" türü yapılmadı: tek teknede kollardan biri boşa gidebiliyor,
  ikisini birden kullanmayı zorlamak zor. Çözücü, ölçer, üreteç ve oyun bölücüyü tanıyor
- **Izgara 8x14** (yeni bölümler), hücre 90→80px. Dokunma yarıçapı 70px aynen; zaten en
  yakın ayna seçiliyor. Eski 7x12 bölümler değişmedi; hücre boyu haritadan hesaplanıyor
- **Yol kurma akıllandı:** yürüyüş sadece geçerli uzunluk/yön arasından seçiyor.
  Boşa giden deneme %96 → %30-56
- **Zor eşiği:** geri dönüş ≥4 · çevirme ≥6 · near-miss 2-3 · aha zorunlu
- Oyuna 8 bölüm eklendi (`levels_uretilen_4.gd`, "Üretilen 11-18"). Sıra: elle 9 → İŞ 3'ün 10 → İŞ 4'ün 8

**Üretim** (`python tools/uretec.py 40000 1 is4`)
- Bölücüsüz: 20000 deneme → **12335 üretildi, 2142 geçti, 10193 elendi**
  (5986 kullanılan ayna <%70 · 3418 near-miss · 702 yansıma >9 · 50 gereksiz ayna ·
  27 kesişme · 10 benzer). Zor eşiğini geçen: **113** (1568'i geri dönüş <4'ten takıldı)
- Bölücülü: 20000 deneme → **7132 üretildi, 719 geçti, 6413 elendi**
  (3402 near-miss · 2213 kullanılan ayna · 710 yansıma · 60 kesişme · 26 gereksiz · 2 benzer).
  Zor eşiğini geçen: **161**
- Üretilemeyen (sayılmadı): yol kurulamadı 5959 / 11211 · tekne sıkışık 843 / 1489 ·
  kestirme kapanmadı 830 / 168

**Seçilen 8** (zorluk · çevirme · yansıma · yoldaki/toplam ayna · arama · geri dönüş · near) — hepsi zor eşiğini geçiyor, hepsinde aha var
Z1 bölücüsüz 0.83 · 8 · 9 · 9/12 · 20 · 9 · 2 | Z2 bölücüsüz 0.85 · 8 · 9 · 9/11 · 24 · 9 · 2
Z3 bölücüsüz 0.85 · 9 · 9 · 9/11 · 19 · 9 · 2 | Z4 bölücüsüz 0.87 · 9 · 9 · 9/12 · 22 · 9 · 2
Z5 bölücülü 0.93 · 7 · 9 · 8/11 · 59 · 8 · 3 | Z6 bölücülü 0.95 · 9 · 9 · 9/12 · 61 · 7 · 3
Z7 bölücülü 0.98 · 8 · 9 · 9/10 · 59 · 9 · 3 | Z8 bölücülü 1.00 · 8 · 8 · 8/11 · 82 · 10 · 3

**Bölücülü bölümlerin geri dönüşü daha mı yüksek?** Havuzda **evet**: ortalama 4.63'e
karşı 3.07; zor eşiğini geçme oranı %22'ye karşı %5. Seçilen 8'de **hayır**: 8.5'e karşı
9.0; ikisi de tavana yakın. Bölücünün asıl farkı **arama eforunda**: 59-82'ye karşı 19-24,
yaklaşık 3 kat. Oyuncu iki kolu aynı anda akılda tutmak zorunda.

**Test edilen:** motor testi 27 bölümün hepsinde (elle 9 + İŞ 3'ün 10 + İŞ 4'ün 8):
başta çözülmemiş, çözüm var, dokunarak veriliyor → 27/27 OK. Çözüm sayıları Python
ölçerle tutuyor. Çok kollu çözücü İŞ 3'ün 10 bölümünde eski metriklerin birebir
aynısını verdi (regresyon 10/10). Ekran görüntüleri GÖZLE bakıldı (Z5 çözülmüş,
Z8 çözülmemiş + çözülmüş).

**İki kollu ışın karışık görünüyor mu?** İlk görüntüde **evet, yer yer**. Kollar komşu
şeritte paralel gidince 80px hücrede haleler birleşip kalın banda dönüyordu. Hale
inceltildi (26→18, kutlama 44→30); ikinci görüntüde şeritler ayrı okunuyor. Ayrıca 2 hata
bulundu ve düzeltildi: iki tekne çapraz komşu olup gövdeleri biniyordu (üretece
"tekne sıkışık" kuralı) · Atla düğmesi 0. satırdaki fener kulesini örtüyordu.

**Test edilmeyen:** telefonda açılmadı; 80px hücrede parmak isabeti; Z1-Z8'in gerçekten
"çok zor" hissettirip hissettirmediği (hepsi geri dönüş 7-10: yorucu olabilir).

**Not:** İŞ 3 üretim komutu artık levels_uretilen.gd'yi birebir üretmiyor (ölü kol sırası
değişti). Kurucunun oynadığı dosya git'teki haliyle korundu. Üretilen `.gd`'ler Python ile
yazılıyor; import elle koşuldu, temiz.

**Öneri:** (1) Paralel komşu şerit sayısı ölçüt olarak eklenebilir; eşiği Tasarım
koymalı. (2) Zor bölümler yansıma tavanına (9) yığılıyor; tablo 3-9 bölücülülerde dar kalıyor,
kol başına sayılabilir.

## KARARLAR (tarihli, tek satır)
- 2026-09-14 · Kurucu İŞ 4 bölümlerini oynadı: **"15'ten sonra zorlamaya başladı"** — hedeflenen eğri tutuyor, zorluk ölçeri insan hissiyle ilk kez örtüştü (arama eforu 19-82 vs önceki tur 2-25)
- 2026-09-14 · Işık bölücü tek teknede birleşen kol olarak DEĞİL, iki tekneli olarak uygulandı (tek teknede kollardan biri boşa gidiyor)
- 2026-09-14 · Işık bölücü öne alındı (31. bölüm → hemen): kurucu "çok zor değil" dedi, saf ayna+kaya zorluk tavanı düşük
- 2026-09-14 · Görsel hattı tamam: 5 Tripo varlığı + arka plan + sis + ay, hepsi defterde. Tekne `z` görünümünde render edilir (`x` yanlış), kayalık parlaklık 0.32'ye kısılır
- 2026-09-14 · **Ayna dönüş adımı 90°, KİLİTLİ** (kurucu onayı). 45° elendi: ışın aynaya paralelken sızıyor, kestirme açıyor; iki modu birden desteklemek her bölümü iki kez tasarlamak demek
- 2026-09-14 · Tasarım ve yayın planı yazıldı: `oyunlar/fener/tasarim_notlari.md` + `yayin_plani.md` (ChatGPT danışması, patron süzdü)
- 2026-09-14 · V1'de sadece iki yeni mekanik: ışık bölücü (~31) ve renk filtresi (~41). Fazlası kapsam şişmesi
- 2026-09-14 · İlk sürüm 70 değil **40-45 bölüm**; kalanı güncelleme paketi olarak gelir
- 2026-09-14 · Zorluk ritmi düz çizgi değil: her 10 bölümde bir nefes bölümü. Yeni mekanik 3 bölümde öğretilir, tanıtım bölümü zor olmaz
- 2026-09-14 · Üreteç "önce güzel çözüm yolu, sonra bulmaca" kurar; "çözülebiliyor = iyi bulmaca" kabul edilmez
- 2026-09-14 · Reklam: sadece ödüllü, bölüm bittikten SONRA; ödül "Liman Restorasyonu" ışık puanı — bulmacayı kolaylaştıran hiçbir ödül yok
- 2026-09-14 · Tek klasör: her şey `C:\Altyapi` içinde; çöp `cop/`'a, zamanı gelince temizlenir
- 2026-09-14 · Şirket yapısı: 7 bölüm, patron Claude, kurucu = son test + yayın
- 2026-09-14 · Kod ayrı Claude ekranında yazılır; iletişim bu dosyadaki İŞ EMRİ / RAPOR bölümleriyle
- 2026-09-14 · Auto-commit hook'u düzenlenen dosyanın kendi deposuna commit atar (sabit yol kaldırıldı)
- 2026-09-14 · İki hesap: patron = ana hesap; KOD = ikinci hesap, `kod_ekrani.cmd` ile (ayrı `CLAUDE_CONFIG_DIR`)
- 2026-09-14 · İlk oyun: **Fener Bekçisi** ("ışığı gemiye ulaştır" — reklamda 3 saniyede anlatılır). Yedek aday: Ateşböceği Bahçesi. Blok/match-3 rafa kalktı (`oyunlar/_arsiv_kuytu_blok/`)
- 2026-09-14 · Fener'in bilinen riski: bölüm oyunu, içerik elle üretilir. Prototipte "bir bölüm kaç dakikada kuruluyor" ÖLÇÜLECEK
- 2026-09-14 · ESKİ (geçersiz): Tür kararı prototip yarışına bırakıldı: A (blok yerleştirme) ve B (match-3) aynı deniz temasıyla yapılacak, kurucunun bırakamadığı kazanacak
- 2026-09-14 · Tahta 4 parça türüyle seyrek; 2-3 özel parça (renk / yatay / dikey patlatma); özel parça ilk bakışta ayırt edilir
- 2026-09-14 · Referanstan ALINMAYANLAR: yoğun tahta (6+ tür), günlük görev listesi
- 2026-09-14 · İlk oyun türü: sakin blok yerleştirme (kurucu seçti). Çalışma adı "Kuytu". Match-3 pazarı kalabalık diye elendi
- 2026-09-14 · Aşama kapıları kabul edildi: fikir → prototip → dikey dilim → üretim → yayın; kapı geçilmeden sonraki aşamanın işi yapılmaz; öldürme ölçütü "kurucu prototipi kendisi açmıyor"
- 2026-09-14 · Yedek: GitHub özel depo `volkanaybar45-beep/altyapi`, dal `main`; hook otomatik push eder, `git push` Claude'a yasak (kurucu çalıştırır)
- 2026-09-14 · Şirket yapısı KİLİTLENDİ (kurucu onayı) · tag `sirket-v1`
