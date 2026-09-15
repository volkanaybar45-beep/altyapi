# proto/gorseller — kopya klasörü

Bu klasördeki PNG'ler **kopyadır**; kaynak, araç, prompt ve lisans zinciri
asıl defterdedir: `oyunlar/fener/gorseller/kayit.md`.
Godot proje dışındaki dosyayı APK'ya koyamadığı için kopyalandı (2026-09-14, İŞ 5).

| Dosya | Asıl | Kopyalanma |
|---|---|---|
| fener_kulesi.png | ../../gorseller/fener_kulesi.png | 2026-09-14, değiştirilmeden |
| ayna_plaka.png | ../../gorseller/ayna_plaka.png | 2026-09-14, değiştirilmeden |
| ayna_taban.png | ../../gorseller/ayna_taban.png | 2026-09-14, değiştirilmeden |
| tekne.png | ../../gorseller/tekne.png | 2026-09-15, İŞ 7 yeniden render (parlaklık 0.72) |
| kayalik.png | ../../gorseller/kayalik.png | 2026-09-14, değiştirilmeden |
| arkaplan_gece_denizi.png | ../../gorseller/arkaplan_gece_denizi.png | 2026-09-15, İŞ 7 ufuk düzenlemesi |
| sis_katmani.png | ../../gorseller/sis_katmani.png | 2026-09-14, değiştirilmeden |
| ay.png | ../../gorseller/ay.png | 2026-09-14, değiştirilmeden |

Asıl dosya değişirse buraya yeniden kopyalanır. Sabit ayna ayrı görsel
değildir: `ayna_plaka.png` kodda karartılır (mirror.gd).

| ikon_gecici.png | — | 2026-09-15 (İŞ 6) | **Geçici uygulama ikonu.** Bu klasördeki `fener_kulesi.png` + `tekne.png` üst üste konup koddan çizilen ışınla birleştirildi (Python/PIL, yeni üretim yok, kaynakları kayıtlı). Mağaza ikonu ayrı iş |

## İŞ 10 (2026-09-15)
Oyundan çıkanlar (kopyaları `cop/fener_is10/proto_*`; asılları `../../gorseller/`'de, defterde):
`fener_kulesi.png` (tek fener artık diyoramanın kendisi), `ayna_plaka.png`, `ayna_taban.png`,
`kayalik.png`, eski `tekne.png`, eski `ay.png`.
Yeni (asıl defter: `../../gorseller/kayit.md` → "İŞ 10 — Diyorama seti"): `diyorama_levha.png` ·
`gokyuzu.png` · `ay.png` · `ayna_0..3.png` · `kaya_taban.png` · `kaya_engel.png` · `tekne.png`.
Hepsi `tools/is10_varlik.py` ile üretildi (render → kırpma/kopya).
