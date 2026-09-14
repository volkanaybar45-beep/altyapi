# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Fener prototipi 2. tur: zorluk katmanları + 45°/90° karşılaştırması (KOD)

## SIRADA
1. Godot araçlarını (import kapısı hook'u, oyun-calistir skill) oyundan bağımsız yap — prototip başlamadan önce
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 2 — Fener prototipi, zorluk turu** (2026-09-14)
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
**İŞ 2 — Fener zorluk turu · kod yazıldı, telefonda test edilmedi** (2026-09-14)
(İŞ 1 raporu git geçmişinde; özü: mekanik çalışıyor, bölüm ızgaraya indirgeniyor.)

**Yapılan:** `oyunlar/fener/proto/`
- **Kaya** (üç taşlı küme): ışın çarpınca durur
- **Sabit ayna:** kalın koyu blok + iki vida, halesi yok (döner ayna: ince parlak
  çizgi + hale + mil). Ayırt etme silüetle, renkle değil. Dokununca titriyor, dönmüyor
- **45°/90° seçimi:** sağ üstte "Açı 45° / Açı 90°" düğmesi (+ M tuşu). Basınca
  bölüm baştan kurulur. 90° modunda her dokunuş iki çapraz arasında geçiş
- **Bölümler ASCII haritaya geçti** (`levels.gd`, 7x12 ızgara): 9 bölüm (eski 3 + yeni 6)
  4 kaya+sabit ayna tanışma · 5 kayalar yanlış yolu keser · 6 yandan fener ·
  7 köşeden köşeye · 8 iki kol, biri kayada biter · 9 sekiz ayna, dokuz yansıma,
  ışın kendini defalarca kesiyor, tekneye götürür gibi görünen yem ayna var

**Zorluk (çözücü ölçümü, 90° modu):** bölüm 5-7 = 16-32 kombinasyonda tek çözüm;
8 = 128'de 4; 9 = 256'da 2 (fark yem aynada, yol tek). "1-2 dk düşündürür mü"
ölçülemedi, bunu ancak kurucu söyler.

**Bölüm kurma süresi:** 6 yeni bölüm ~15 dk (bölüm başı 2-3 dk), 9. bölüm ~5 dk.
Tahmin, kronometre yok, KOD Claude süresi. Hızın sebebi ASCII harita + çözücü:
taslak yaz → çözücü "çözüm yok / 18 çözüm" der → düzelt.

**Tasarım bulgusu:** 45° modunda ayna ışına paralel çevrilince ışık içinden geçiyor.
Tekne fenerle aynı hizadaysa tek dokunuşla kestirme oluyor (bir taslak 45°'de 18
çözüm verdi). Kural `levels.gd` başına yazıldı: tekne fenerle aynı hizaya konmaz.
90° modunda bu kaçak yok, bölümler iki modda da çözülüyor.

**Test edilen:** `tools/mantik_test.gd` her bölümü iki modda motorun kendisiyle kaba
kuvvetle çözüyor. Başta çözülmemiş, çözüm var, çözüm dokunarak (tap) veriliyor: 18/18 OK.
Python çözücüyle sayılar birebir tuttu. Ekran görüntüleri (4, 6, 9; iki mod) GÖZLE
bakıldı. 1 hata bulundu ve düzeltildi: 9. bölümde kaya teknenin bayrağını örtüyordu.

**Test edilmeyen:** telefonda açılmadı; mod düğmesine dokunmanın aynı anda bölümü
geçirmemesi (kod korumalı, denenmedi), sabit aynanın titremesinin hissi, 70px dokunma
yarıçapı, 9. bölümün gerçek süresi.

**Ders:** Ayna fiziği tween'li `rotation`'dan değil `step`'ten okunuyor. Titreme
animasyonu ışını oynatmasın diye (kanonik kaynak dersi).

**Öneri:** Çözücü (`tools/mantik_test.gd` mantığı) bölüm üretecinin yarısı; üreteç
işi buna dayanabilir.

## KARARLAR (tarihli, tek satır)
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
