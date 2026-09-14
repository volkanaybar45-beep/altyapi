# Sanat ve Ses

**Sorumluluk:** Görsel/ses üretimi, lisans kanıt zinciri.
**Girdi:** Tasarım ihtiyaç listesi.
**Çıktı:** Saydam PNG/ses + her klasörde `kayit.md`.

- Hat ve ayarlar: `URETIM_HATTI.md` · betik: `toon_render.py` · palet yöntemi: `RENK_PALETI.md`
- İzinli zemin: ChatGPT (OpenAI) + Tripo Pro "Gizli". Dreamina YASAK
- `.glb` üretim anında indirilir (Tripo 7 günde siler)
- `kayit.md`: dosya · tarih · araç · prompt · format. Kayıtsız dosya oyuna girmez
- Her görsel hedef ölçekte, gerçek zeminde gözle kontrol; kontrast ≥ 3.0

## Dersler (Yaban'dan damıtıldı, 2026-09-14)
- Şeffaflığı dosya adına, önizlemeye veya onaya güvenerek varsayma; entegrasyondan önce alfa kanalını ÖLÇ
- Her yeni dosyanın biçimi (alfa, bit derinliği, kanal) tek tek ölçülür; "aynı aile" varsayımı yanlış çıktı
- Alt katmanı örtmesi gereken görselin opaklığı ölçülür; en altta her zaman opak taban bulunur
- Parlak/yoğun saydam görsellerde alfası sıfır pikselin rengi de karartılır (premultiply), yoksa mipmap kir bulaştırır
- Kaynağın natif çözünürlüğü hedef kutuya göre orantısız büyükse hiçbir margin düzeltmez; kaynağı küçült
- Aynı ailedeki parçaları ayrı ayrı değil TEK sayfada üretip programatik böl (stil/kalınlık tutarlılığı)
- Izgara bölerken eşit çeyrek kırpma komşu hücreyi sızdırır; içeriğe göre kırp
- İki görseli hizalarken kutu kenarını değil ortak anatomik noktayı ölç
- Dış boyutu aynı iki varlık "birebir yedek" değildir; iç oran ve kenar boşluğu ölçülmeden değiştirme
- Konum/boyut kararını mockup'a bakarak değil gerçek render üzerinde ölçerek ver
- Parçacık dokusu atarken bbox kırpma + bleed yetmez, boyut da ayarlanır
