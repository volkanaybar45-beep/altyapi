# Altyapı — oyunlar silinince kalan şey

Bu klasör bir oyun değildir. Yaban/Maden silindiğinde ayakta
kalması istenen şeyleri taşır (kullanıcının kararı, 2026-09-14).

| Dosya | Ne |
|---|---|
| `CLAUDE.md` | Çalışma kuralları, roller, karar yetkisi — oyundan bağımsız |
| `URETIM_HATTI.md` | ChatGPT → Tripo → toon_render hattı, ayarlar, lisans zemini |
| `arastirma/` | **4401 gerçek Play yorumu** + çekme betikleri |
| `tools/toon_render.py` | 3B → 2B toon render betiği |
| `lessons.md` | Yaban boyunca çıkarılan dersler |
| `RENK_PALETI.md` | Palet YÖNTEMİ örneği (Yaban'a özgü değerler içerir) |
| `.claude/` | Hook ve ayar yapılandırması (auto-commit dahil) |
| `CLAUDE_yaban_arsiv.md` | Yaban'ın tam kural dosyası, referans olarak |

## Araştırma verisi — en değerli varlık
`arastirma/ham/*.json` içinde iki tur, 4401 yorum:
- **Tur 1:** 2400 Türkçe yorum, satın almalı oyunlar → `ozet_girdi.md`
- **Tur 2:** 2001 İngilizce yorum, bedava reklamlı oyunlar →
  `ozet_girdi_2.md`

Tekrar çekmek için: `oyun_bul.py` paket adı bulur,
`yorum_cek.py` yorumları çeker.

### Veriden çıkan ve unutulmaması gereken altı şey
1. Bu türün oyuncusu **sakinlik** arıyor, heyecan değil
2. **Reklam sıklığı oyun öldürür** — "her bölüm sonrası reklam"
   nefret edilen 1 numaralı şey
3. **Ödüllü reklamın ödülü GARANTİ** verilir — reklam yüklenmese,
   kesilse, internet gitse bile
4. **Zorunlu hiçbir şey olmayacak** — zorunlu etkinlik, turnuva,
   hesap, kapatılamayan ipucu
5. **Offline ve Türkçe** bedava avantajlar, öne çıkarılır
6. **Çökme = doğrudan 1 yıldız.** Kararlılık her özellikten değerli
