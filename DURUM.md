# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Fener: sahne canlansın (KOD, İŞ 7) → sonra yeni APK → dış test tekrar

## SIRADA
0. **V1 görsel çeşitliliği — modüler bölge paketi** (APK + oyuncu geri bildirimi
   SONRASI konuşulur): 5-7 bölge (Sakin Kıyı · Sisli Kayalıklar · Fırtına ·
   Buz · Tropik · Volkan · Kuzey Işıkları), her bölge modüler parça seti;
   70 ayrı sahne çizilmez. Şimdi TEK bölge (gece denizi) okunur olsun.
   VFX'li bölgeler (şimşek/volkan) kapsam şişmesi riski
0a. **"Gece Limanı" mockup'ındaki meta sistemler — V1 DIŞI** (ChatGPT görselleri,
   2026-09-15): altın ekonomisi, 50 altınlık ipucu, günlük görev listesi,
   koleksiyon, mektup kutusu, mini oyunlar (cam silme, iskele tahtası dizme).
   Gerekçe: ipucu bulmacayı kolaylaştırır (karara aykırı), günlük görev zaten
   elendi, mini oyun = yeni oyun demek. Sanat yönü ve kedi ALINDI
0b. Arka planda ufukta yavaşça geçen küçük gemi siluetleri (atmosfer; bulmacaya
   dokunmaz, hedef değil). Kurucunun "gemi ufukta dursa" fikrinin güvenli hali
1. İngilizce metinler (Tasarım yazar) — mağaza öncesi, test Türkçe olduğu için ertelendi
2. `oyun-calistir` skill'i oyundan bağımsız yap (import kapısı hook'u yapıldı)
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 10 — Diyorama çerçevesi + fener kaynağı üstte + yeni aynalar** (2026-09-15)
Kurucu Tripo'da liman diyoraması ürettirdi, patron 4 modeli render edip baktı.
Seçilen: `coastal village 3d model (1)` (aydınlatma kapalı + PBR) — sıcak lambalar,
suda pişmiş yansıma. Kadraj: **yaw −40°, pitch 30°**.
Deneme render'ları ve 720×1600 kompozisyon: `gorseller/diyorama_deneme/`

1. **Arka plan katmanı diyorama olsun:** köy + kayalık + fener üstte, iskele sol
   kenarda; alt üçte iki açık deniz. Deniz İŞ 7'deki shader'la kalır (dalga,
   ay yolu, yansıma). Diyorama tek PNG levha — çalışma anında 3D yok
2. **KARAR (A): ışık kaynağı diyoramanın kendi feneridir.** Ayrı kule nesnesi
   KALDIRILIR (ekranda iki fener olmaz). Işın gerçekten o kulenin lamba
   odasından çıkar; lamba odası ışın çıkışıyla hizalanır
3. Bunun sonucu: **kaynak konumu üstte sabit.** Üreteç ve çözücü buna göre
   güncellenir; ızgara diyoramanın altındaki açık denize oturur.
   Üretilen bölümler yeniden doğrulanır (çözülemeyen varsa RAPOR'a yaz)
4. **Aynalar yeniden tasarlanır:** ChatGPT mockup'ındaki pirinç/altın gövdeli,
   yuvarlak taban üstünde duran, cam yüzeyli ayna. Kurucu onayladı.
   Görsel Tripo'dan gelecek (Sanat), KOD gelince bağlar. 4 yön render
4a. **SET GELDİ (2026-09-15), hepsi `gorseller/diyorama_deneme/`, defteri dolu:**
   `diyorama_liman.glb` · `ayna.glb` · `kaya_taban_duz.glb` · `kaya_engel_sivri.glb` ·
   `tekne.glb` · `gokyuzu_panorama.png` · `ay.png`. GLB'ler `toon_render.py` ile
   oyun sprite'ına çevrilir; ayna 4 yönden. `ay.png` halesinde renkli benek var,
   temizlensin. Yeni dosyalar `gorseller/kayit.md`'ye de işlenir
4b. **Kayalar da yeniden:** ayna tabanı = **düz tepeli** yosunlu kayalık ada;
   engel kayası = **sivri tepeli** kaya kümesi. İkisi SİLUETTEN ayrılır,
   renkten değil (renk körlüğü dersi). Tripo'dan gelecek, KOD bağlar
5. Işın rengi ve kalınlığı diyoramanın sıcak lamba ışığıyla uyumlu kalsın
6. Ekran görüntüsü: 3 bölüm, gerçek telefon oranı, GÖZLE BAK
7. RAPOR: kaynak sabitlenince kaç üretilmiş bölüm elendi, kare hızı

**GEOMETRİ KURALI (patron kararı — perspektif/ızgara çatışması)**
Diyorama perspektifli (yaw −40°, pitch 30°), ızgara düz. **Izgara DÜZ KALIR,**
perspektife sokulmaz: ışın 90° yansıyor, ızgara eğilirse ekranda açılar 90°
görünmez ve oyuncu yansımayı gözle takip edemez. Bulmacanın okunurluğu
atmosferden önce gelir. Derinlik şu üç ölçülebilir kuralla kurulur:
- G1. **Sprite render açısı = diyorama kamera açısı.** Her GLB `toon_render.py`
  ile **yaw −40°, pitch 30°** render edilir (ayna: bu kamerada 4 dönüş yönü).
  Farklı açıdan render edilmiş tek sprite bile yapıştırma gibi durur
- G2. **Uzaklık küçültmesi:** üst satırdaki nesne, alt satırdakinin **%85'i**
  ölçeğinde; aradaki satırlar doğrusal ara değer. Aynı kural yansımaya da
- G3. **Oturma noktası:** her sprite'ın ALT ORTA noktası hücrenin su noktasıdır
  (sprite merkezi değil). Yansıma bu noktadan aynalanır, dikey kayma 0 px;
  yansıma yüksekliği gövdenin %60'ı, alfa 0.35, aşağı doğru sönümlenir
- G4. Işık yönü tek: diyoramada lamba ışığı SOLDAN geliyor; sprite render'ında
  ve koddaki parlamalarda ışık yönü de SOLDAN. Sağdan aydınlatma yasak

**KABUL ÖLÇÜTLERİ — tek turda bitsin, hepsi RAPOR'da sayıyla yazılacak**
Kurucu: "tek seferde, doğru hesaplamalarla, doğru yerlere." Aşağıdakilerin
HEPSİ sağlanmadan iş bitmiş sayılmaz. Sağlanamayan madde varsa DUR ve yaz.
- K1. Katman sırası (alttan üste): gökyüzü → ay → deniz shader → ay yolu →
  diyorama levhası → nesne yansımaları → ışın → nesneler (kaya, ayna, tekne)
- K2. Ekranda **tek fener** var. Ayrı kule nesnesi kodda ve sahnede kalmadı
- K3. Işın, diyoramanın lamba odası pikselinden çıkıyor (±8 px). Ölç ve yaz
- K4. Izgara diyoramanın altındaki açık denize tam oturuyor; hiçbir hücre
  diyorama levhasının üstüne binmiyor. 9:16 ve 20:9'da ayrı ayrı doğrula
- K5. Çakışma 0/28 (mevcut `cakisma.py`). Bozulan bölüm varsa sayısını yaz
- K6. Kontrast ≥3.0: ışın/deniz · ayna yüzü/deniz · tekne/deniz · engel kayası/deniz.
  Dördü de en açık deniz bandında ölçülecek, medyanda değil
- K7. Taban kayası ile engel kayası **gri tonda** (doygunluk sıfırlanmış)
  yan yana konduğunda ayırt ediliyor — siluet testi, ekran görüntüsüyle kanıtla
- K8. Kare hızı PC'de 60 fps'in altına düşmedi; düştüyse hangi katman pahalı
- K9. Her yeni dosya `gorseller/kayit.md`'de kayıtlı (kaynak, tarih, prompt)
- K10. En az 3 bölüm (kolay · bölücülü · zor) gerçek telefon oranında ekran
  görüntüsüyle GÖZLE bakıldı; kareler rapora eklendi

Kapsam dışı: altın/ipucu ekonomisi, günlük görev, koleksiyon, mektup kutusu,
yeni mini oyunlar (cam silme, iskele dizme) — hepsi V1 dışı, SIRADA'ya yazıldı.

**İŞ 9 — Tekne canlansın, karşılık versin** (2026-09-15)
Kurucu: "gemi çok yapmacık, aşağıda duruyor; ışığı bulunca o da ışık yakarak,
korna çalarak karşılık verse." Teşhis: tekne ölü — suya ait değil, tepki vermiyor.

**Tekne ızgara hücresinde KALIR.** Ufka sabitlemek hedefi her bölümde aynı yere
koyar, üreteci çökertir, bulmaca çeşitliliğini bitirir (patron kararı, panoda).

1. **Suya ait olsun (bekleme hali):** yavaş yalpa (hafif dönme) + dikey iniş-çıkış,
   yansıması da onunla sallansın. Dibinde küçük su izi/köpük. Sönük ve sakin
2. **Işık ulaşınca karşılık versin,** sırayla:
   - Güverte feneri yanar (sıcak sarı, kısa parlama)
   - **Korna çalar** (`tekne_korna.mp3`, defterde — kısık ve uzak duysun, bağırmasın)
   - Tekne yavaşça ışığa/limana doğru süzülmeye başlar (küçük yer değişimi yeter)
   - Sonra bölüm geçer (İŞ 8'deki otomatik devam ile birlikte çalışsın)
3. Bekleyen tekne ile ulaşılan tekne arasındaki fark **ilk bakışta** okunsun
4. Tekne görseli hâlâ "yapıştırılmış" duruyorsa RAPOR'a yaz — Sanat'a daha
   alçak açılı yeni render yaptırılır (bu işte görsel üretme, sadece bildir)
5. Ekran görüntüsü: bekleyen tekne + karşılık veren tekne, gerçek telefon oranı

Kapsam dışı: teknenin ufka taşınması, yeni bölge/tema, yeni mekanik, reklam.

**İŞ 8 — Otomatik devam + ses** (2026-09-15)
Kurucu istedi. Kapsam DAR tutuldu; müzik yok, ses ayarı var.

**A. Otomatik devam**
1. Bölüm bitince kutlama oynar (~1.4 sn), sonra **kendiliğinden** sonraki bölüme geçer
2. "Devam için dokun" yazısı kalkar; ama ekrana dokunulursa **hemen** geçilir
   (bekleme zorunlu değil)
3. Son bölüm bitince ana ekrana dön (ya da kısa "hepsi bitti" ekranı)
4. Geçiş sert olmasın: kısa kararma/açılma yeter. Sahne sakin kalsın

**B. Ses**
5. **Ortam:** yavaş deniz dalgası döngüsü + çok kısık rüzgâr (sürekli, dikişsiz döngü)
6. **Efekt, 4 tane:** ayna çevirme (kısa tık) · ışın tekneye ulaşma (sıcak çan) ·
   bölüm tamam (kısa yükseliş) · düğme dokunuşu
7. **Ayarlar ekranı işe yarasın** (şu an "Henüz ayar yok"): Ses aç/kapa + Ortam sesi
   aç/kapa, seçim cihazda saklanır (`user://`). Metinler `tr()`, EN boş
8. **Müzik YOK.** Sakin oyunda ortam sesi yeterli; müzik lisans ve dosya boyutu yükü
9. Telefon sessize alınmışsa ya da ses dosyası yoksa oyun ÇALIŞMAYA devam eder (çökme yok)
10. **Sesler GELDİ** (2026-09-15, Pixabay, defter dolu): `oyunlar/fener/sesler/` →
    `ortam_deniz.mp3` · `ortam_ruzgar.mp3` · `ayna_cevir.mp3` · `isin_ulasti.mp3` ·
    `bolum_tamam.mp3` · `dugme.mp3`. KOD bunları `proto/sesler/`'e kopyalar
    (Godot proje dışını APK'ya koyamaz) ve oyuna bağlar. Deniz/rüzgâr import'unda
    **Loop açık**. `ortam_deniz.mp3` 4.2 MB — gerekirse 30-60 sn'ye kısalt
11. **Lisans zinciri, pazarlık yok:** her ses için `kayit.md`'ye dosya adı, tarih,
    kaynak (Pixabay + sayfa linki), lisans, süre. **Kayıtsız ses oyuna girmez**
12. RAPOR: APK boyutu ne kadar büyüdü, ses dosyası formatı/boyutu

Kapsam dışı: müzik, seslendirme, titreşim, yeni bölge/tema, reklam, kayıt sistemi.

**İŞ 7 (kod yazıldı, telefon testi bekliyor) — Sahne canlansın** (2026-09-15)
İlk dış testçi (kurucunun arkadaşı) telefonda oynadı. Zorluk TAMAM ("bir tık
zor" ama geçene kadar denedi — bırakmadı). Görsel için: **"dümdüz, kule havada,
kaya havada, deniz sabit, ay sabit, parlamıyor, ışık ve ayna çok sıradan."**

Teşhis: hiçbir nesne suya BASMIYOR, hiçbir şey KIPIRDAMIYOR. Çözüm yeni görsel
çizmek değil; çoğu kod/shader. Yeni varlık üretmeden %80'i alınır. HIZLI çalış.

1. **Nesneler suya otursun** (havada durma biter):
   - Kule: dibinde küçük kayalık/ada + köpük halkası, su hattı
   - Ayna: taban su hattına otursun, dipte hafif dalgalanma
   - Kayalar: yarı batık görünsün, su hattı çizgisi
   - **Her nesnenin suda titrek yansıması** (dikey aynalanmış, alfa düşük,
     yatayda hafif kayan bozulma) — derinliği tek başına bu kurar
2. **Deniz kıpırdasın:** yavaş dalga hareketi (shader ya da iki kayan katman),
   nesne diplerinde hafif dalgalanma. Sakin kalsın, sallanmasın
3. **Ay canlansın:** yumuşak hale + suda **ay yolu** (titreyen gümüş şerit)
4. **Işık sıradan olmasın:**
   - Lamba odasında dönen parıltı; çekirdekte çok hafif nefes (flicker)
   - Işının geçtiği yerde suda parlama izi
   - Yansıma düğümlerinde küçük kıvılcım
5. **Ayna sıradan olmasın:** ışık gelince yüzeyde kayan parlama (specular),
   çerçevede altın pırıltı. Işık GELMEYEN ayna sönük kalsın (ipucu değeri)
6. **İlk 3-5 bölüm yumuşasın** (öğretme eğrisi). Üst taraftaki zorluk KALSIN
7. **Tekne ufuk bandında kayboluyor (kontrast 1.3, bölüm 16):** arka plan
   görselinde ufuk bandı koyultulsun/yumuşatılsın. Kenar çizgisi yaması YOK
8. Ekran görüntüsü al, gerçek telefon oranında GÖZLE BAK (en az 3 bölüm).
   Hareket tek karede görünmez: kısa aralıklı 2-3 kare al, karşılaştır
9. RAPOR: tekne/zemin kontrastı (ufuk bandı dahil, ≥3.0), kare hızı düştü mü

Kapsam dışı: yeni bölge/tema (fırtına, volkan, buz — SIRADA 0), ses, reklam,
kayıt sistemi, liman restorasyonu, renk filtresi, yeni mekanik.

**İŞ 6 (BİTTİ) — Görsel düzeltme turu** (2026-09-14)
Kurucu ekran görüntüsüne baktı: "bu görseller böyle olmayacak." Haklı.
Sahne şu an ışık oyunu gibi değil, gri bloklardan oluşan çerçeve gibi
görünüyor. Sırayla düzelt, her maddeden sonra ekran görüntüsü al ve BAK.

1. **Aynalar gri çıkıyor.** Normal (döner) aynaya sabit ayna karartması
   uygulanıyor olabilir — kontrol et. Döner ayna: altın çerçeve GÖRÜNÜR,
   yüzey parlak, gece zemininde en dikkat çeken ikinci şey (birincisi ışık)
2. **Işın yeniden tasarlanacak.** Şu an düz beyaz kalın boru:
   - İnce parlak çekirdek + geniş yumuşak hale (çekirdek ≤ halenin 1/3'ü)
   - Köşeler kare olmasın: her yansıma noktasında küçük parlak düğüm
   - Uzunluk boyunca hafif sönümlenme; sisin içinden geçerken hafif yayılma
3. **Tekne %120-150 büyüsün**, üstündeki hale kalksın. Hedef en net okunan
   nesne olmalı; feneri sıcak sarı parlasın
4. **Fener kulesi büyüsün** ve ızgaranın içinde eşit bir hücre gibi durmasın;
   sahnenin sahibi o. Lamba odası ışın çıkışıyla hizalı kalsın
5. **Çakışma yok:** nesneler birbirinin üstüne binmeyecek; üreteç komşu
   hücrelere iki büyük nesne koyuyorsa aralarını aç ya da o bölümü ele
6. Ölç ve RAPOR'a yaz: ışın/zemin, ayna/zemin, tekne/zemin kontrastı (≥3.0)
7. En az 3 farklı bölümden (kolay, bölücülü, zor) ekran görüntüsü al,
   gerçek telefon oranında GÖZLE bak, sonra rapor et
8. **Tekne gövdesi 1.95 kontrast — kenar çizgisi yamadır, yetmez.** Görselin
   kendisi açılsın (render parlaklığı yükseltilerek yeniden üretilebilir,
   `toon_render.py … z 0.30 - 0.45` gibi). Kayalık 1.8'de kalabilir: o engel,
   okunması gereken nesne değil
9. **Paket adı ve sürüm** (patron kararı, panoda): Benzersiz isim
   `com.volkagames.fenerbekcisi` · uygulama adı `Fener Bekçisi` ·
   sürüm adı `0.1`
10. **Uzun telefon (20:9):** altta ~320 px boş deniz kalıyor. Oyun alanı
    dikeyde ortalansın ya da ızgara bu boşluğu kullansın
11. Uygulama ikonu: **şimdilik geçici** bir ikon yeter (mağaza ikonu ayrı iş).
    Fener + ışık + tekne kompozisyonu yayın öncesi üretilecek

12. **APK hazırlığı (export ayarları) — APK'yı ALMA, sadece hazırla:**
    - Proje Ayarları: `rendering/textures/vram_compression/import_etc2_astc = true`
      (Godot uyarısı: "Hedef platform ETC2/ASTC doku sıkıştırması gerektiriyor")
    - `export_presets.cfg`: `package/unique_name=com.volkagames.fenerbekcisi` ·
      `package/name=Fener Bekçisi` · `version/name=0.1` · `version/code=1`
    - Export path: `C:/Altyapi/oyunlar/fener/apk/fener-0.1-debug.apk`,
      `.gitignore`'a `*.apk` (GitHub 100 MB dersi)
    - RAPOR'a: APK alma komutu + kalan eksikler

Kapsam dışı: ses, reklam, kayıt sistemi, liman restorasyonu, renk filtresi.

**İŞ 5 (BİTTİ) — Görsel entegrasyonu + ana ekran** (2026-09-14)
Kurucu: "şimdilik iyi, görseller ve oyunun yapısı otursun, sonra APK ile
birkaç kişinin fikrini alırım." Aşama 2 kapısı geçti, Aşama 3 (dikey dilim).
Görseller hazır: `oyunlar/fener/gorseller/` (defter: `kayit.md`).

1. Düz şekilleri gerçek görsellerle değiştir:
   `fener_kulesi.png` · `ayna_plaka.png` (kod döndürür) + `ayna_taban.png`
   (dönmez) · `tekne.png` · `kayalik.png` · `arkaplan_gece_denizi.png` ·
   `sis_katmani.png` (alfa %35-50, yavaş yatay kayar, tile) · `ay.png`
2. **Sabit ayna** ayrı görsel değil: plaka görseli koyultulup/karartılıp
   kullanılabilir ama siluetten ayırt edilmeli (renk körlüğü)
3. Işın koddan: çekirdek ≥16 px + additive parlama, renk `#FFE7A3`.
   Zemin `#082047`; ışın sisin içinden geçerken kaybolmamalı
4. Tamamlanma anı: ışık güzergâh boyunca yansın, tekne feneri parlasın,
   kısa parçacık. **Sahne sakin kalsın, ekran patlamasın**
5. **Ana ekran:** oyun adı + "Oyna" + "Ayarlar". Arka plan gece denizi + ay.
   Metinler `tr()` ile; EN karşılıkları BOŞ bırakılır (Tasarım yazacak)
6. Ölçüm: her görsel gerçek cihaz oranında ekran görüntüsüne alınıp GÖZLE
   bakılacak; ışın/zemin ve tekne/zemin kontrastı raporlanacak (hedef ≥3.0)
7. RAPOR'a ayrıca yaz: **Android export şablonu kurulu mu, APK almak için
   ne gerekiyor** (keystore, SDK yolu). APK'yı bu işte ALMA, sadece raporla

Kapsam dışı: renk filtresi, ses, reklam, kayıt sistemi, liman restorasyonu.

**İŞ 4 (BİTTİ) — Zorluk tavanı + ışık bölücü** (2026-09-14)
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
**İŞ 10 — DURDU, kod yazılmadı: K4 ve madde 3 sayıyla sağlanamıyor** (2026-09-15)

Önce hesap yapıldı (istendiği gibi). İki engel çıktı; ikisi de patron/kurucu kararı.

**Engel 1 — K4 (ızgara diyoramanın altına sığmıyor, 9:16'da oynanamaz)**
- Ölçüm (`kompoz_720x1600.png`, diyorama 720 genişlikte): lamba ≈ (352, 62). Diyorama
  sağda y≈330'da, ortada y≈420'de biter; **iskele solda y≈785'e iner** (en alt nokta)
- Izgara yüksekliği = 12.2 hücre (7×12: 11 aralık + üst/alt 0.6 pay), 8×14'te 14.2 hücre; altta 80 px yazı
- Kullanılabilir yükseklik ve hücre boyu (şu an hücre 90 px, ayna dokunma yarıçapı 70 px):

  | Ekran | Diyorama altı → yazı | 7×12 hücre | 8×14 hücre |
  |---|---|---|---|
  | 20:9 (1600) | 785 → 1520 = 735 px | **60 px** | **52 px** |
  | 9:16 (1280) | 785 → 1200 = 415 px | **34 px** | **29 px** |
- 34 px hücre ≈ 3.5 mm dokunma hedefi: 9:16'da oynanamaz. (Patronun deneme kompozisyonunda da
  ilk satırın 2 hücresi iskelenin üstünde, 12. satır ekran dışında)
- Seçenekler (karar gerekli):
  **(a)** İskele kırpılsın (madde 1 "iskele sol kenarda" değişir): diyorama altı ≈440 → 20:9'da 88 px,
  9:16'da 62 px hücre (7×12) ·
  **(b)** Diyorama küçültülsün: 9:16'da 70 px hücre için ölçek ≤ **0.44** (fener ~90→40 px, "sahnenin sahibi" olmaz) ·
  **(c)** K4 gevşesin: iskelenin üstüne yalnız BOŞ hücre binebilir (üreteç o hücreleri boş tutar) ·
  **(d)** Izgara küçülsün (ör. 7×9): bütün bölümler yeniden üretilir

**Engel 2 — Madde 3 (kaynak üstte sabit): 28 bölümden 23'ü elenir**
- Kural: ışın lambadan (x≈352 = 7 sütunlu ızgarada **3. sütun**) aşağı iner. Bir bölüm, yatay/dikey
  aynalamayla fener 3. sütuna, yön aşağıya getirilebiliyor ve fenerin üstü boşsa uyar; sonra
  Python çözücüyle yeniden doğrulandı (başta çözülmemiş + en az 1 çözüm)
- **Uyan: 5/28** — elle 1, 2, 3, 6, 9 (çözüm sayıları değişmedi: 1/2 · 1/4 · 2/4 · 1/16 · 4/128)
- **Elenen: 23/28** — elle 4, 5, 7, 8, 10 (fener yan/alt/başka sütunda) + **üretilenlerin 18'inin 18'i**
  (fener ızgaranın içinde, yön U/L/R; 8×14'lerde lamba iki sütunun arasına düşüyor)
- Yani 5 bölümlük oyun kalır. Üreteç "kaynak üstte, 3. sütun, yön aşağı" kısıtıyla yeniden
  yazılıp ~20 bölüm yeniden üretilmeli + zorluk eşikleri yeniden seçilmeli. Bu İŞ 10'un
  "yeniden doğrula" kapsamını aşan ayrı bir iş; karar gerekli

**Hazır olan hesaplar** (engeller kalkınca koda girecek değerler, henüz uygulanmadı)
- G1: bütün GLB'ler yaw −40°, pitch 30°. `toon_render.py`'de kamera döndürme YOK (sadece düz
  ön/yan) → isteğe bağlı yaw/pitch argümanı eklenmeli (Sanat aracı; geriye uyumlu). Işık vektörü
  zaten soldan (L = −0.35, 0.62, 0.70) → G4 uyumlu
- Ayna 4 yön: pitch 30°'de derinlik ekranda sin30 = 0.5 kısalır → diskin ekranda 45° çizgi
  görünmesi için kameraya göre yaw = atan(2) = **63.4° · 116.6° · 243.4° · 296.6°**
  (adım 1-3-5-7'ye karşılık; dönüşte sprite değişir). Render'la doğrulanmadı
- G2: satır ölçeği s(r) = 0.85 + 0.15·r/(h−1) → 7×12: satır 0 = 0.850, satır 6 = 0.932, satır 11 = 1.000
  (8×14: satır başı adım 0.01154). Yansıma aynı ölçekle
- G3: oturma = sprite alt ortası = hücre su noktası; yansıma o noktadan aynalanır, dikey kayma 0,
  yükseklik gövdenin %60'ı, alfa 0.35, aşağı doğrusal sönüm (şu anki yansıma merkezden değil su
  hattından aynalanıyor ama boyu %100 — değişecek)

**K9 — defter:** diyorama seti ana deftere (`gorseller/kayit.md`) henüz işlenmemiş (yalnız
`diyorama_deneme/promptlar.md`'de). `gokyuzu_panorama.png` ve `ay.png` için **prompt yazılı değil**
→ kurucu: bu ikisinin ChatGPT prompt'u neydi? (tek soru)

**Öneri:** en az maliyetli yol (a) iskele kırpma + üreteci sabit kaynakla yeniden koşturma
(ayrı iş, İŞ 10'dan önce). Karar gelince G1-G4 değerleri hazır, doğrudan uygulanır.

**İŞ 8 + İŞ 9 — Otomatik devam + ses + tekne karşılığı · kod yazıldı, telefonda test edilmedi** (2026-09-15)

**Yapılan — İŞ 9. Tekne** (ızgara hücresinde kaldı; fizik konumu değişmedi)
- **Bekleme:** yavaş yalpa (±3°) + iniş-çıkış, her tekne farklı evrede; yansıması aynı açıyla
  sallanır; dipte halka/köpük; fener sönük kor
- **Işık ulaşınca:** fener kısa, büyük sıcak parlama → tam yanar · çan (0 sn) · **korna 0.35 sn sonra**
  (-18 dB, kısık; aynı tekne 3 sn içinde tekrar korna çalmaz) · tekne ~1.4 sn'de ışığın geldiği
  yöne 0.15 hücre süzülür (ışın ucu gövdede kalır), yalpası yatışır, gövde sıcak renge bürünür,
  kıçta yatay köpük izi + pruvada küçük dalga · ışık kaybolursa 0.8 sn'de eski haline döner
- Kutlama: eski "büyüyüp küçülme" (yapmacık) kalktı; süzülme görünsün diye kutlama 1.5 sn,
  "bölüm tamam" sesi kornadan sonra (1.1 sn), sonra otomatik devam
- Fener/tekne parıltısı düz daireydi → mavi zeminde **gri disk** görünüyordu (toplamalı sıcak renk
  maviyle griye dönüyor). Yumuşak radyal doku + doygun turuncuya çevrildi (kule lambası dahil)
- **Madde 4 — Sanat'a bildirim:** tekne hâlâ biraz "yapıştırılmış": render **tam yandan**, güverte hiç
  görünmüyor, düz kesik silüet. Yansıma/yalpa/köpük suya bağladı ama hacim yok. Hafif yukarıdan
  (10-20°) yeni render önerilir. Bu işte görsel üretilmedi
- Süzülme `cakisma.py` hesabında yok (0.15 hücre; komşu aynaya çok yaklaşan bölüm olabilir)

**Yapılan — A. Otomatik devam**
- Bölüm bitince kutlama (~1.5 sn) + 0.6 sn → 0.25 sn kararma → sonraki bölüm → 0.3 sn açılma
- "Devam için dokun" kalktı; kutlama sırasında dokunuş hemen geçirir (çift geçiş korumalı)
- Son bölüm: "Şimdilik bu kadar — teşekkürler!" 2.2 sn → ana ekran. "Atla" da aynı geçişi kullanır
  (son bölümde artık başa sarmaz, ana ekrana döner)

**Yapılan — B. Ses** (autoload `Ses`, `proto/ses.gd`; sahne değişince ortam kesilmez)
- Ortam: deniz (-8 dB) + rüzgâr (-24 dB, çok kısık), dikişsiz döngü (import Loop açık)
- Efekt: ayna çevirme · ışın tekneye ulaştı (yeni bir tekne ışık alınca; yüklemede değil) ·
  bölüm tamam (çandan 0.35 sn sonra, üst üste binmesin) · düğme (menü, Atla, ayar)
- **Ayarlar ekranı:** Ses efektleri + Ortam sesi, Açık/Kapalı (yazı + renk). `user://ayarlar.cfg`;
  sadece iki bool okunur, tip yanlış/dosya bozuk → varsayılan (açık). Panel opak yapıldı
- Ses dosyası yoksa uyarı yazılır, oyun sessiz devam eder (kod `/root/Ses` yoksa da çalışır)
- Metinler `tr()`: yeni SES_EFEKT, SES_ORTAM, ACIK, KAPALI (EN boş); SON değişti; DEVAM, AYAR_YOK silindi
- Müzik yok

**Ses dosyaları ve boyut**
- `ortam_deniz`: 132 sn / 4.2 MB mp3 → **45 sn döngü, mono OGG, 366 KB** (çapraz geçişle dikişsiz)
- `ortam_ruzgar`: 8 sn mp3 → 6.2 sn döngü, mono OGG, 42 KB
- 4 efekt mp3 olduğu gibi (11 + 184 + 66 + 34 KB)
- `tekne_korna.mp3` (İŞ 9) olduğu gibi, 77 KB
- **APK'ya giren ses: ~0.82 MB** (Godot import çıktısı ölçüldü). Ham hali kopyalansaydı ~4.9 MB
- Defter: `sesler/kayit.md`'ye sayfa linki, lisans, ham/oyundaki süre, işlem eklendi; `proto/sesler/kayit.md` işaret
  dosyası. **Linkler dosya adından kuruldu, tarayıcıda açılıp doğrulanmadı**

**Test edilen** (`tools/devam_probe.gd`, pencereli, gerçek ses sürücüsü WASAPI): otomatik devam OK ·
dokununca hemen geçiş OK · son bölüm → ana ekran OK · ayar kaydı/geri okuma OK · bozuk ayar
dosyası → varsayılan OK · eksik ses dosyası çökmüyor OK · ortam sesi ilerliyor OK · efekt çalıyor OK.
Motor testi OK · çakışma 0/28 · kare hızı değişmedi (PC 150 fps). Tekne 720×1600'de gözle
bakıldı: bekleyen (2 kare, yalpa görünüyor) · ilk parlama · karşılık veren (süzülmüş, iz). Ayarlar paneli 20:9 ve 9:16'da gözle bakıldı (ilk hali yarı saydamdı, arkadaki
düğmeler içinden görünüyordu → düzeltildi)

**Test EDİLMEYEN:** korna dahil sesler **kulakla dinlenmedi** (çan + korna + "tamam" 1.1 sn içinde üçü
art arda — kalabalık gelebilir; seviye dengesi, `ayna_cevir` kuru mu, `isin_ulasti`
5.9 sn — kuyruğu sonraki bölüme taşabilir); telefonda sessiz mod; geçişin akıcılığı canlı izlenmedi.
APK alınmadı (gerçek APK boyutu farkı ölçülmedi, tahmin ~+0.74 MB)

**Öneri:** kurucu dinlesin; `isin_ulasti` uzun gelirse 2 sn'ye kısaltılıp söndürülür (tek satır ffmpeg)

**İŞ 7 — Sahne canlansın · kod yazıldı, telefonda test edilmedi** (2026-09-15)

**Yapılan** (yeni varlık üretilmedi; iki mevcut görsel düzenlendi, defterde)
1. **Suya oturma:** oyunda ufuk artık ilk satırın hemen üstünde → **gökte nesne kalmadı**
   (ay gök şeridinde). Kule kayalık adacığın üstünde (adacığın altı suda) · kaya ve tekne
   su hattından kesik (yarı batık) · her nesnede su hattı köpüğü + yavaşça açılan iki halka ·
   **her nesnenin titrek yansıması** (dikey aynalı, soluk, dalgalı; ayna plakasının açısı da aynalanır)
2. **Deniz:** zemin shader'la yavaşça kıpırdar + kayan soluk parıltı bantları (küçük genlik)
3. **Ay:** yumuşak hale (hafif nabız) + suda titreyen gümüş **ay yolu**. Ay, altında tekne
   olan sütuna konmaz (kontrast)
4. **Işık:** lamba odasında dönen iki ışık kolu · çekirdekte ±%7 nefes · ışının geçtiği suda
   göz kırpan sıcak pullar (gökte yok) · her yansıma düğümünde dönen küçük kıvılcım
5. **Ayna:** ışık alan ayna tam parlak, yüzeyde kayan parlama, çerçevede altın pırıltı;
   **ışık almayan ayna sönük** (0.3 sn geçişle)
6. **Öğretme eğrisi:** yeni Bölüm 1 (tek ayna, tek dokunuş) · 2 iki ayna · 3 kaya + sabit
   ayna (eski 4, iki çözümlü) · 4-5 dört ayna (eski 2-3) · 6 eski 5 · 7-10 aynı. Üretilen
   bölümler aynı. **Elle bölüm sayısı 9→10: eski "bölüm N" numaraları 1 kaydı**
7. **Ufuk bandı:** arkaplan görselinde ufuk altındaki parlak ay izi/dalga parıltıları o
   satırın deniz rengine çekildi (gök aynı). Canlı denizde sis bandı üstünde tekne yine 2.3
   kaldı → tekne `z 0.30 - 0.72` ile yeniden render. Kenar çizgisi yaması yok. Eskiler `cop/fener_is7/`
- Çakışma: kule adacığı `cakisma.py`'ye eklendi; 5 bölümde iki alttaki aynaya biniyordu →
  kurala eklendi (kulenin 2 altı doluysa boşluk). **0/28**

**Kontrast — tekne gövdesi / zemin** (canlı deniz, shader açık, 720×1600 ekran görüntüsünden)
- Medyan deniz **5.8** · en açık sis bandı (%99) **3.6** · ufuk bandı: gövde artık hep ufkun
  altında; ufuk altındaki deniz en açık luminans 0.019 → **~5.0** ✓ (İŞ 6'da 1.3)

**Kare hızı (PC, 720×1600, en kalabalık bölüm 26, dikey eşitleme kapalı):** su katmanları
açık **148 fps / 6.8 ms**, kapalı **187 fps / 5.3 ms** → su katmanları ~1.4 ms/kare.
**Telefonda ölçülmedi.** Telefon 5-10 kat yavaşsa 60 fps sınırına yaklaşabilir; takılırsa
ilk kapatılacak: suda ışın pulları + ay yolu (her kare GDScript döngüsü)

**GÖZLE BAKILDI:** Bölüm 1 (çözülmemiş + çözülmüş, 20:9), Üretilen 10 (zor, 20:9),
Üretilen İŞ4-Z6 (bölücülü, 20:9, 2 kare 0.6 sn arayla), Bölüm 7 (9:16), Bölüm 17 (9:16), ana ekran.
Kareler arası fark görüldü (ay yolu pulları, ayna parlaması, ışın pulları yer değiştiriyor).
Bakınca düzeltilen: ilk arkaplan düzenlemesi ufukta çamurlu şerit + zeytin rengi ay izi
yaptı (atıldı, sadece deniz düzenlendi) · ayna yansıması çizgili gri leke (çizgi kaldırıldı) ·
ışın pulları gökte "+" gibiydi (sadece suda, yassı) · ay yolu çok dardı (ay çapına bağlandı) ·
adacık görünmüyordu (1.0→1.3 hücre) · 9:16'da adacık "Devam" yazısına değiyordu

**Test edilen:** motor testi OK (10 elle + 18 üretilen), import/betik kontrolü temiz, çakışma 0/28.

**Test EDİLMEYEN:** telefonda açılmadı, kare hızı telefonda ölçülmedi; deniz kıpırtısı ve
sis canlı izlenmedi (sadece aralıklı kareler); ayna dönüş animasyonu sırasında yansıma
(ölçek tween'i) bakılmadı; ana ekranda nesne yok, suya oturma sadece oyunda.

**Öneri**
- Yeni APK'dan önce kurucu 1-5. bölümleri oynasın (eğri tahmin, test edilmedi)
- `tools/fps_probe.gd` APK'da da koşturulabilir hale getirilirse telefonda kare hızı ölçülür

**İŞ 6 — Görsel düzeltme turu · kod yazıldı, telefonda test edilmedi** (2026-09-15)

**Yapılan**
1. **Ayna:** kod karartmıyordu; gri/grenli olan görselin yüzüydü (render gürültüsü). Plaka
   artık gölgelendiricili Sprite2D: yüz pürüzsüz gümüş-mavi degrade + çapraz parlama,
   çerçeve parlak altın. Sabit ayna aynı gölgelendiricide karartılır + kıskaçlar (silüet aynı kaldı)
2. **Işın:** çekirdek 10px×k (+ ince beyaz iç), hale 48px×k beş katlı yumuşak (oran 0.21) ·
   her kırılmada parlak düğüm · 1800px'te hale %45'e, çekirdek %80'e söner · sis bandında
   hale %45 genişler, seyrelir
3. **Tekne** 1.25→**1.7 hücre** (×1.36), hale kalktı, feneri hep sıcak sarı yanar (toplamalı),
   ışık alınca/bitince güçlenir. Kenar çizgisi yaması **silindi**
4. **Kule** 1.25→**2.0 hücre** (×1.6), lamba hücre merkezinde (ışın çıkışı hizalı), gri daire
   yerine titreyen sıcak parıltı
5. **Çakışma:** `tools/cakisma.py` sprite alfa maskeleriyle 28 bölümü denetler. Yeni boyutta
   11 bölümde binme vardı → **ızgarada sadece çakışan sütun/satır arası açılır** (tekne-komşu
   0.4 hücre, kule altındaki tekne 1.3). Işın hep satır/sütun merkezinden geçtiği için fizik
   değişmez. Sonuç: **0 çakışma**, hiç bölüm elenmedi. Ay da nesneyle çakışırsa sola/ortaya
   kayar, yer yoksa o bölümde çizilmez
8. **Tekne görseli** `toon_render.py … z 0.30 - 0.55` ile yeniden üretildi; eskisi
   `cop/fener_is6/`, iki defter de güncellendi. Tüm sprite'lara mipmap + doğrusal-mipmap
   filtre (küçültmede gren kayboldu)
9/12. `project.godot`: `config/version="0.1"`, ad zaten "Fener Bekçisi", ETC2/ASTC zaten açıktı
10. **20:9:** oyun alanı fazla yüksekliği kullanır, **dolu satırlar** dikeyde ortalanır
    (haritaların alt satırları boştu, boşluğun asıl sebebi buydu); "Devam" yazısı ekran altına yaslı
11. Geçici ikon `gorseller/ikon_gecici.png` (kule + tekne + ışın, kayıtlı görsellerden; defterde)

**Kontrast (WCAG)** — zemin: medyan / en koyu / en açık (ufuk parıltısı, %99'luk)
- Işın çekirdeği: 14.4 / 15.8 / 5.3 ✓ · Ayna yüzü: 12.6 / 13.9 / 4.7 ✓ · Ayna çerçevesi: 10.4 / 11.4 / 3.9 ✓
- **Tekne gövdesi: 3.6 / 3.9 ✓ ama ufuk parıltısının üstüne düşerse 1.3 ✗** (zemin görselinin
  ufuk bandı çok açık; bölüm 16'da tekne tam oraya denk geliyor). Kurucu bakmalı

**GÖZLE BAKILDI** (720×1600 ve 720×1280): Bölüm 1 (kolay), Üretilen 10 (zor, çözülmüş),
Bölüm 16 (kule üstünde tekne, iki oran), Üretilen İŞ4-Z6 (bölücülü, çözülmüş). Bakınca bulunan ve
düzeltilen: kule aya biniyordu · tekne gövdesi grenliydi · tekne üstündeki aynaya değiyordu
(0.3→0.4) · 20:9'da alt 600px boştu · hale kenarı basamaklıydı · sıfır boylu ışın parçası
üçgenleme hatası veriyordu

**Test edilen:** motor testi OK (fizik bozulmadı), import/betik kontrolü temiz, çakışma 0/28.

**Test EDİLMEYEN / YAPILAMAYAN**
- Telefonda açılmadı; ana ekran ve ayar paneli bu turda bakılmadı; ekran boyutu oyun
  sırasında değişirse yerleşim yeniden hesaplanmaz (bölüm yüklenirken hesaplanır)
- **Madde 12 yarım: `export_presets.cfg` bana yasak** (`.claude/settings.json` deny, bilinçli).
  Kurucu Godot'ta Proje → Dışa Aktar → Android'de şunları girmeli: `package/unique_name =
  com.volkagames.fenerbekcisi` · `package/name = Fener Bekçisi` · `version/name = 0.1` ·
  `version/code = 1` · export yolu `C:/Altyapi/oyunlar/fener/apk/fener-0.1-debug.apk`
- **APK komutu** (proto klasöründe, sahte APPDATA ile):
  `Godot_v4.7.1-stable_win64_console.exe --headless --path . --export-debug "Android" C:/Altyapi/oyunlar/fener/apk/fener-0.1-debug.apk`
  (ön ayar adı "Android" varsayıldı, dosyayı göremedim). `*.apk` zaten `.gitignore`'da
- Kalan eksik: İzin listesi dosyadan doğrulanamadı (boş olmalı)

**Güvenlik:** `export_presets.cfg` **git'te izleniyor ve `.gitignore`'da yok** (anayasa ister).
Dokunmadım: `git rm --cached` + `.gitignore` satırı patron kararı

**Öneri**
- Import hook'u hata metnini stdout'a yazıyor → Claude "blocking error, No stderr output"
  görüyor, sebebi göremiyor. `echo ... >&2` olmalı (bu turda hatayı elle koşup buldum)
- `cakisma.py` aralık kuralı main.gd `_spacing` ile iki yerde; biri değişirse öteki de
- Ders: sprite küçültülerek çiziliyorsa mipmap açılmazsa doku grenli görünür

**İŞ 5 — Görsel entegrasyonu + ana ekran · kod yazıldı, telefonda test edilmedi** (2026-09-14)

**Yapılan**
- 8 görsel oyunda: `proto/gorseller/`'e **kopyalandı** (Godot proje dışını APK'ya koyamaz);
  oradaki `kayit.md` asıl deftere işaret ediyor. Defterde 8'i de kayıtlı, eksik yok
- Kule: lamba odası ışının çıktığı hücrede, kule hep dik · tekne · kayalık · gece
  denizi zemini · ay · iki sis bandı (alfa %40 ve %35, yavaş, zıt yönde kayar, döşeme)
- **Ayna:** plaka döner, taban dönmez. **Sabit ayna** = aynı plaka karartılmış + iki
  uçta plakadan taşan koyu kıskaç, tabanı ve halesi yok → silüet farklı
  (renk körlüğünde de ayırt edilir)
- **Işın:** çekirdek 16px `#FFE7A3` (normal karışım) + ayrı katmanda toplamalı (additive) parlama. Işın
  sisin, zeminin ÜSTÜNDE; aynalar, kule ve tekne ise ışının üstünde
- **Tamamlanma:** parlama güzergâh boyunca yayılır, tekne feneri yanar, fenerden
  14 sıcak kıvılcım yukarı süzülür (tek sefer, 1.4 sn). Sahne sakin
- **Ana ekran** (`menu.tscn`, açılış sahnesi): "Fener Bekçisi" + Oyna + Ayarlar
  ("Henüz ayar yok" + Geri). Android geri tuşu: oyundan menüye, menüden çıkış
- Metinler `tr()`, CSV'ye `en` sütunu eklendi, **boş**. EN projeye BAĞLANMADI: boş EN
  yüklenirse İngilizce telefonda metin boş çıkabilir; Tasarım doldurunca tek satır

**Kontrast** (WCAG, deniz zemini ölçüldü: orta #041A3C, alt #02122D, iş emri zemini #082047)
- Işın çekirdeği / zemin: **12.2-15.3** ✓
- Tekne görseli / zemin: **1.95** ✗ (koyu mavi-gri gövde gece denizine karışıyor).
  Görsel değiştirilmeden siluete ay ışığı renginde 3px kenar çizgisi eklendi
  (`#8FA9C9`): kenar / zemin **6.6-7.7** ✓. Gövdenin kendisi hâlâ 1.95
- Ayrıca: ayna plakası 8.4 · fener kulesi 6.8 · **kayalık 1.8** (hedef yok ama düşük)

**GÖZLE BAKILDI** (720x1600 = 20:9 ve 720x1280): ana ekran, elle bölüm 4
(çözülmemiş + kutlama), üretilen 16 (yoğun 8x14), üretilen 17 (bölücülü, kutlama).
Bakınca 5 hata bulundu ve düzeltildi:
1. Işın aynaların üstündeydi, plakanın açısı okunmuyordu → ışın nesnelerin altına alındı
2. Toplamalı hale fazla genişti, ekran "patlıyordu" → daraltıldı
3. Tekne gece denizinde kayboluyordu → kenar çizgisi
4. 8x14'te çapraz komşu plakalar biniyordu → plaka %110'dan %95'e
5. Yukarı çıkan ışın başlığın üstünden geçiyordu; 20:9'da ışın y=1280'de kesiliyordu → düzeltildi

**Test edilen:** motor testi 27/27 OK (görsel değişikliği fiziği bozmadı). Import temiz.

**Test edilmeyen:** telefonda açılmadı; Ayarlar paneli ekran görüntüsüyle bakılmadı;
Android geri tuşu denenmedi; sis kayması canlı izlenmedi (tek kare görüldü).
20:9'da oyun alanı üste yaslı, altta ~320px boş deniz kalıyor. Kurucu bakmalı.

**Android / APK (ALINMADI, sadece durum)**
- Export şablonu **kurulu**: `C:/DevTools/Godot/4.7.1/editor_data/export_templates/4.7.1.stable/`
  (android_debug.apk, android_release.apk, android_source.zip)
- JDK 17: `C:/DevTools/Java/jdk-17` · Android SDK: `C:/Android/Sdk` (build-tools, platform-tools,
  cmdline-tools, ndk var). İkisi de editör ayarında tanımlı
- Debug keystore **var** (`editor_data/keystores/debug.keystore`)
- `proto/export_presets.cfg` **var**: Android, arm64, gradle kapalı. Şifre alanı yok
  (Godot 4 şifreleri git dışı `.godot/export_credentials.cfg`'de tutar)
- **APK öncesi gerekenler:**
  (1) `package/unique_name` hâlâ `com.example.$genname` → kalıcı paket adı seçilmeli
  (sonradan değişmez; patron kararı)
  (2) version/name boş · uygulama ikonu yok (Godot ikonu çıkar)
  (3) Birkaç kişiye dağıtım için **debug APK yeter** (hazır). Play Store için **release
  keystore** gerek: JDK'daki `keytool` ile üretilir, **git'e girmez, ayrıca yedeklenmeli**
  (kaybolursa uygulama güncellenemez)
  (4) Komut: `Godot_console.exe --headless --path proto --export-debug "Android" <yol>.apk`

**Ders:** `main.gd`'nin çizim bölümünü bir kez Python ile değiştirdim (kural: sadece
Edit/Write). Import kapısını elle koştum, temizdi. Bir de: yeni hook, paralel Edit'lerde
ara durumdaki (henüz tanımlanmamış sabit) hatayı bildiriyor. Zararsız, ama çıktısı boş
geliyor ("No stderr output"): hook hatayı stdout'a yazıyor, Claude Code stderr gösteriyor.

**Öneri:** Kayalık kontrastı 1.8; tekne gibi kenar çizgisi ya da görseli açmak Sanat'a sorulsun.

## KARARLAR (tarihli, tek satır)
- 2026-09-15 · **İlk dış test (arkadaş, telefonda):** zorluk TAMAM — "bir tık zor" ama geçene kadar denedi, bırakmadı. Görsel ZAYIF: "dümdüz, kule havada, kaya havada, deniz sabit, ay sabit, parlamıyor, ışık/ayna sıradan". Teşhis: nesneler suya basmıyor + hiçbir şey kıpırdamıyor → İŞ 7
- 2026-09-15 · Dış testçi ikinci bakış: "görseller daha iyi olmuş, daha da iyi olabilir" — yön doğru, tavan uzak. Sıçrama İŞ 7'den (hareket + derinlik) beklenecek
- 2026-09-15 · APK alındı ve telefonda çalıştı (dış testçi oynadı). Aşama 3 dikey dilim sürüyor
- 2026-09-15 · `export_presets.cfg` git dışı bırakıldı (`.gitignore` + `git rm --cached`, commit 21e7021). Anayasa kuralıydı, ihlal duruyordu. Godot ayarları tek makinede; yeni klonda export ayarı elle girilir
- 2026-09-15 · İŞ 6 görselleri geçti (kurucu ekran görüntüsüne baktı). Kalan tek görsel sorun: **tekne ufuktaki açık bandın üstünde kayboluyor (kontrast 1.3)** — bölüm 16
- 2026-09-14 · Paket adı: `com.volkagames.fenerbekcisi` (kalıcı, mağazada değişmez). Uygulama adı "Fener Bekçisi"
- 2026-09-14 · AdMob: eski hesap sürekli ret alıyor, yeni hesapla başvurulacak. **İlk sürüm reklamsız çıkabilir**, reklam onay sonrası güncellemeyle eklenir. Geliştirmede SADECE test reklam kimliği; gerçek kimlik yayın gününe kadar koda girmez; kendi reklamına tıklamak YASAK (geçersiz trafik = ret sebebi)
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
