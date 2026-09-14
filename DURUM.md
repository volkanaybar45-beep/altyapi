# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Fener: zorluk tavanını yükselt + ışık bölücü (KOD, İŞ 4)

## SIRADA
1. Godot araçlarını (import kapısı hook'u, oyun-calistir skill) oyundan bağımsız yap — prototip başlamadan önce
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 3 — Bölüm üreteci + zorluk ölçümü** (2026-09-14)
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
**İŞ 3 — Üreteç + zorluk ölçümü · kod yazıldı, telefonda test edilmedi** (2026-09-14)

**Yapılan**
- 45° modu ve mod düğmesi kaldırıldı; ayna her dokunuşta 90° döner. Yerine
  "Atla ›" düğmesi kondu (kurucu üretilen bölümlere hızlı ulaşsın diye)
- Oyun sırası: elle kurulan 9 bölüm → **üretilen 10 bölüm** (başlıkta "Üretilen N · zorluk X")
- `tools/uretec.py`: tersine kurulum (yol → yem ayna → yanlış kolu derinleştir →
  kestirmeye kaya → aynaları %80 yanlış çevir) + ölçer (8 metrik + aha) + kalite
  filtresi + puan (%30/25/20/15/10, havuzda 0-1, aha +0.1). Çıktı `levels_uretilen.gd`
  (üretilmiş dosya, elle düzenlenmez; `python tools/uretec.py 30000 1` ile tekrar üretilir)

**Üretim sayıları** (30000 deneme, tohum 1): **1407 bölüm üretildi, 88 geçti, 1319 elendi**
- 1023 · kullanılan döner ayna < %70 (yem ayna fazla)
- 294 · near-miss 1-3 dışı (çoğu 0: ışın tekneyi hiç sıyırmıyor)
- 1 · son 10 bölüme benzer · 1 · kesişme > 2
- Üretilemeyen (sayılmadı): 28484 yol ızgaraya sığmadı · 89 döner ayna < 2 · 20 kestirme kapanmadı

**Seçilen 10** (zorluk · çevirme · yansıma · yoldaki/toplam ayna · arama · geri dönüş · aha)
U1 kolay 0.00 · 1 · 4 · 2/2 · 2 · 1 · – | U2 kolay 0.17 · 1 · 6 · 3/4 · 4 · 2 · –
U3 kolay 0.27 · 3 · 6 · 3/3 · 3 · 1 · aha | U4 orta 0.27 · 3 · 5 · 5/7 · 7 · 2 · –
U5 orta 0.33 · 3 · 7 · 4/5 · 4 · 1 · aha | U6 orta 0.39 · 5 · 6 · 5/7 · 7 · 3 · –
U7 orta 0.42 · 4 · 6 · 5/6 · 6 · 2 · aha | U8 zor 0.73 · 6 · 9 · 8/11 · 11 · 3 · aha
U9 zor 0.87 · 9 · 9 · 9/11 · 15 · 5 · aha | U10 zor 1.00 · 6 · 7 · 7/10 · 25 · 9 · aha

**Bulgu:** Aynı ölçer elle kurulan 9 bölüme de koşuldu. 8'inde `max_backtrack` = 1,
yani yanlış çevirme ışını anında öldürüyor, oyuncu hatayı hemen görüyor. Kurucunun
"çok hızlı buluyor" demesinin ölçülebilir karşılığı bu olabilir. Üretilen zorlarda
geri dönüş 3-9: yanlış yolda birkaç ayna ilerleyip sonra ölüyor. Elle bölümlerde
near-miss 0, aha hiç yok.

**Test edilen:** motor testi (`tools/mantik_test.gd`, 90°) 19 bölümün hepsinde:
başta çözülmemiş, çözüm var, dokunarak veriliyor → 19/19 OK. Çözüm sayıları Python
ölçerle tutuyor (fark yalnız ışının değmediği aynalardan). Ekran görüntüsüne GÖZLE
bakıldı (U1, U10 çözülmemiş + çözülmüş). 1 hata bulundu ve düzeltildi: üreteç kayayı
teknenin dibine koyunca kaya bayrağı örtüyordu → direk kısaltıldı.

**Test edilmeyen:** telefonda açılmadı. Puanın insan süresiyle örtüşüp örtüşmediği
bilinmiyor (şartname de "son kalibrasyonu oyuncu yapar" diyor). U10'da geri dönüş
9: "zor" mu "yorucu" mu, kurucu söyler. "Son 10'a benzerlik" hücre örtüşmesiyle
ölçülüyor, göz benzerliği değil.

**Not:** `levels_uretilen.gd` Python ile yazılıyor (Edit/Write değil). Import kapısı
fener'de zaten çalışmıyor; import'u elle koştum, temiz.

**Öneri:** Near-miss en çok eleyen ikinci ölçüt. Üreteç kayayı bilerek teknenin
yanına koyarsa verim artar.

## KARARLAR (tarihli, tek satır)
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
