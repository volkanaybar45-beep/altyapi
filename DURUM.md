# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Kuytu — Prototip A (blok yerleştirme). KOD ekranında, iş emri aşağıda

## SIRADA
1. Godot araçlarını (import kapısı hook'u, oyun-calistir skill) oyundan bağımsız yap — prototip başlamadan önce
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 1 — Ateşböceği Bahçesi prototipi** (2026-09-14)
Önce `oyunlar/atesbocegi/fikir.md` oku. Amaç: dokunuşun iyi gelip gelmediğini
ölçmek. Görsel üretme; nokta, daire, çizgi yeter. Godot 4.7.1:
`C:/DevTools/Godot/4.7.1/`

1. Proje: `oyunlar/atesbocegi/proto/` · dikey (portre) · mobil çözünürlük
2. Koyu zemin, üzerine 20-30 ateşböceği (küçük parlak nokta), hafifçe süzülür
3. Parmağı basılı tutup yakın böcekler üzerinden geçir → zincir kurulur;
   parmak kalkınca zincir tamamlanır. Menzil dışındakine atlanamaz
4. Zincir tamamlanınca: ışık dalgası yayılsın, zincirdekiler parlasın,
   yerlerine yenileri yavaşça gelsin
5. **Süre yok, kaybetme yok, hata yok.** Kısa zincir de geçerlidir
6. Zincir uzunluğu ekranda küçük bir sayı; başka HUD yok
7. En az 2 varyant dene: zincir menzili dar/geniş — hangisi iyi hissettiriyor
8. Metin varsa `tr("ANAHTAR")`
9. Çalıştır, ekran görüntüsü al, GÖZLE BAK. Bitince RAPOR'u doldur

Kapsam dışı: Fener prototipi (İŞ 2), görsel üretimi, ana ekran, ses, reklam,
seviye/ilerleme sistemi.

## KOD RAPORU (KOD yazar)
_yok_

## KARARLAR (tarihli, tek satır)
- 2026-09-14 · Tek klasör: her şey `C:\Altyapi` içinde; çöp `cop/`'a, zamanı gelince temizlenir
- 2026-09-14 · Şirket yapısı: 7 bölüm, patron Claude, kurucu = son test + yayın
- 2026-09-14 · Kod ayrı Claude ekranında yazılır; iletişim bu dosyadaki İŞ EMRİ / RAPOR bölümleriyle
- 2026-09-14 · Auto-commit hook'u düzenlenen dosyanın kendi deposuna commit atar (sabit yol kaldırıldı)
- 2026-09-14 · İki hesap: patron = ana hesap; KOD = ikinci hesap, `kod_ekrani.cmd` ile (ayrı `CLAUDE_CONFIG_DIR`)
- 2026-09-14 · Tür kararı prototip yarışına bırakıldı: A (blok yerleştirme) ve B (match-3) aynı deniz temasıyla yapılacak, kurucunun bırakamadığı kazanacak
- 2026-09-14 · Tahta 4 parça türüyle seyrek; 2-3 özel parça (renk / yatay / dikey patlatma); özel parça ilk bakışta ayırt edilir
- 2026-09-14 · Referanstan ALINMAYANLAR: yoğun tahta (6+ tür), günlük görev listesi
- 2026-09-14 · İlk oyun türü: sakin blok yerleştirme (kurucu seçti). Çalışma adı "Kuytu". Match-3 pazarı kalabalık diye elendi
- 2026-09-14 · Aşama kapıları kabul edildi: fikir → prototip → dikey dilim → üretim → yayın; kapı geçilmeden sonraki aşamanın işi yapılmaz; öldürme ölçütü "kurucu prototipi kendisi açmıyor"
- 2026-09-14 · Yedek: GitHub özel depo `volkanaybar45-beep/altyapi`, dal `main`; hook otomatik push eder, `git push` Claude'a yasak (kurucu çalıştırır)
- 2026-09-14 · Şirket yapısı KİLİTLENDİ (kurucu onayı) · tag `sirket-v1`
