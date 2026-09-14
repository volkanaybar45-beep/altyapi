# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Fener Bekçisi prototipi — KOD ekranında, iş emri aşağıda

## SIRADA
1. Godot araçlarını (import kapısı hook'u, oyun-calistir skill) oyundan bağımsız yap — prototip başlamadan önce
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 1 — Fener Bekçisi prototipi** (2026-09-14)
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
**İŞ 1 — Fener prototipi · kod yazıldı, telefonda test edilmedi** (2026-09-14)

**Yapılan:** `oyunlar/fener/proto/` (main.gd, mirror.gd, levels.gd, metin/ceviri.csv).
720x1280 portre, düz şekiller. Dokununca ayna 45° döner; ışın her karede yeniden
hesaplanır; tekneye değince parlama fenerden tekneye yayılır + tekne zıplar;
dokununca sonraki bölüm. Süre/hamle/kaybetme yok. 3 bölüm (2 · 4 · 4 ayna,
3.'de ışın kendi yolunu kesiyor). Metinler `tr()`, sadece TR sütunu (EN'i Tasarım yazar).
Eski Kuytu prototip kodu silinmedi, `cop/`'a taşındı (anayasa kuralı).

**Bölüm kurma süresi (ölçüm):** kolay ~3 dk · orta ~5 dk · şaşırtan ~10 dk.
Dürüst not: bu KOD Claude'un süresi, kronometreyle değil tahmini; insan tasarımcı
için ölçü değil. Asıl bulgu: 45° adımlı aynada ışın hep dik/yatay gider, bölüm
bir ızgaraya indirgeniyor → elle kurmak ucuz, **üreteç yazmak da kolay görünüyor**
(tersinden: tekneden fenere yol çiz, köşelere ayna koy).

**Test edilen:** `tools/mantik_test.gd` — her bölüm başta çözülmemiş, çözüm
gerçek dokunma fonksiyonuyla (tap) verilince tekneye ulaşıyor: 3/3 OK.
`tools/ekran_probe.gd` ile ekran görüntüsü alınıp GÖZLE bakıldı; 3 hata bulunup
düzeltildi (geri dönen ışın fenerin içinden geçiyordu · kule başlığı örtüyordu ·
alt yazı kesiliyordu).

**Test edilmeyen:** telefonda hiç açılmadı; dokunma hissi, parmak isabeti
(ayna dokunma yarıçapı 70px), kutlamanın canlı akışı, farklı ekran oranları.

**Ders:** import kapısı hook'u sadece `*yaban*` yolunda çalışıyor — fener'de hata
yakalamıyor, import'u elle koştum (SIRADA 1 ile aynı iş). İlk importta `.translation`
henüz üretilmediği için 1 kez hata basıyor; ikincide temiz.

**Öneri:** (1) 8 yönden 2'si aynı işi görüyor (45°=225°); oyuncu fazla dokunuyor —
4 adım (sadece iki çapraz + düz) daha tatmin edici olabilir, kurucu hissine bakılsın.
(2) Bölüm üreteci denemesi ucuz, İŞ olarak düşünülebilir.

## KARARLAR (tarihli, tek satır)
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
