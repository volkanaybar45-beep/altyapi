# DURUM — tek pano

Her oturum İLK bu dosya okunur. Karar verilince HEMEN buraya yazılır.

## ŞU AN (tek iş)
Kuytu — Prototip A (blok yerleştirme). KOD ekranında, iş emri aşağıda

## SIRADA
1. Godot araçlarını (import kapısı hook'u, oyun-calistir skill) oyundan bağımsız yap — prototip başlamadan önce
2. KOD ekranı ilk kurulum testi (`kod_ekrani.cmd` → /login → /kod → "iş emri yok")

## KOD İŞ EMRİ (patron yazar)
**İŞ 1 — Kuytu Prototip A: blok yerleştirme** (2026-09-14)
Önce `oyunlar/kuytu/fikir.md` oku. Amaç: türü hisle seçmek. Görsel üretme,
düz renkli şekil kullan. Godot 4.7.1: `C:/DevTools/Godot/4.7.1/`

1. Proje: `oyunlar/kuytu/proto_a/` · dikey (portre) · mobil çözünürlük
2. 8×8 ızgara, altta 3 parça havuzu (tetris benzeri şekiller), sürükle-bırak
3. Dolan satır VE sütun temizlenir; aynı hamlede birden fazlası temizlenirse
   kombo sayılır (şimdilik sadece ekranda sayı olarak)
4. **Süre yok, hamle sınırı yok, kaybetme ekranı yok.** Hiçbir parça
   sığmıyorsa: en dolu satırı temizle ve devam et (geçici çözüm, his
   prototipte ölçülecek)
5. Sade tutma efekti: yerleşme ve temizlenme için kısa tween — henüz "vay"
   efekti yapma, o tür seçildikten sonra
6. Skor görünür ama küçük. Ekranda başka HUD yok
7. Metin: `tr("ANAHTAR")` ile, TR karşılıkları geçici olarak sende
8. Çalıştır, ekran görüntüsü al, GÖZLE BAK (sayı yeşil yeterli değil)
9. Bitince RAPOR'u doldur; APK isteme, önce masaüstünde görelim

Kapsam dışı: match-3 (İŞ 2), görsel üretimi, ana ekran, ortamlar, reklam.

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
