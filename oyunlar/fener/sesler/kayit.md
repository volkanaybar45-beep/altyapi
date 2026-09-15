# Ses defteri — Fener Bekçisi

**Bu defter lisans kanıt zinciridir.** Kayıtsız ses oyuna girmez.
Kaynak: **Pixabay** — ticari kullanım serbest, atıf gerekmiyor (Pixabay Content License).

| Dosya (oyunda) | Tarih | Pixabay orijinal adı / ID | Boyut |
|---|---|---|---|
| `ortam_deniz.mp3` | 2026-09-15 | `dragon-studio-soothing-ocean-waves-372489` · ID 372489 | 4.2 MB |
| `ortam_ruzgar.mp3` | 2026-09-15 | `storegraphic-soft-wind-477404` · ID 477404 | 251 KB |
| `ayna_cevir.mp3` | 2026-09-15 | `matthewvakaliuk73627-mouse-click-290204` · ID 290204 | 11 KB |
| `isin_ulasti.mp3` | 2026-09-15 | `universfield-magic-spell-278824` · ID 278824 | 184 KB |
| `bolum_tamam.mp3` | 2026-09-15 | `freesound_community-success-1-6297` · ID 6297 | 66 KB |
| `dugme.mp3` | 2026-09-15 | `existentialtaco-confirm-tap-394001` · ID 394001 | 34 KB |
| `tekne_korna.mp3` | 2026-09-15 | `universfield-cargo-ship-horn-352063` · ID 352063 | 77 KB |

Link biçimi: `https://pixabay.com/sound-effects/<orijinal-ad>/` (ID dosya adının sonunda).
Orijinal dosyalar kurucunun `Downloads` klasöründe de duruyor.

## Notlar (KOD için)
- `ortam_deniz.mp3` 4.2 MB — APK'yı en çok şişiren dosya. Gerekirse kısaltılıp
  dikişsiz döngüye alınabilir (30-60 sn yeter)
- Godot'ta döngü: import ayarında **Loop** açık olmalı (deniz ve rüzgâr için)
- `ayna_cevir` fare tıkı — oyunda kuru duruyorsa ses seviyesi kısılır

## Oyuna giren biçim (İŞ 8, 2026-09-15, KOD)
Lisans: **Pixabay Content License** (ticari kullanım serbest, atıf gerekmez).
Sayfa: `https://pixabay.com/sound-effects/<orijinal-ad>/`.

| Oyundaki dosya (`proto/sesler/`) | Kaynak (bu klasör) | Pixabay sayfası | Ham süre | Oyundaki | İşlem |
|---|---|---|---|---|---|
| `ortam_deniz.ogg` | `ortam_deniz.mp3` | https://pixabay.com/sound-effects/dragon-studio-soothing-ocean-waves-372489/ | 132.1 sn | 45 sn döngü, 366 KB | 20. sn'den 48 sn alındı, son 3 sn başa eşit güçte çapraz geçişle bağlandı (dikişsiz), mono, OGG Vorbis q3 |
| `ortam_ruzgar.ogg` | `ortam_ruzgar.mp3` | https://pixabay.com/sound-effects/storegraphic-soft-wind-477404/ | 8.0 sn | 6.2 sn döngü, 42 KB | aynı yöntem, 1.5 sn çapraz geçiş, mono, OGG Vorbis q3 |
| `ayna_cevir.mp3` | aynı | https://pixabay.com/sound-effects/matthewvakaliuk73627-mouse-click-290204/ | 0.37 sn | değişmedi, 11 KB | — |
| `isin_ulasti.mp3` | aynı | https://pixabay.com/sound-effects/universfield-magic-spell-278824/ | 5.88 sn | değişmedi, 184 KB | — |
| `bolum_tamam.mp3` | aynı | https://pixabay.com/sound-effects/freesound_community-success-1-6297/ | 3.36 sn | değişmedi, 66 KB | — |
| `dugme.mp3` | aynı | https://pixabay.com/sound-effects/existentialtaco-confirm-tap-394001/ | 1.10 sn | değişmedi, 34 KB | — |

Dönüştürme: ffmpeg 9.0 + numpy (KOD, bu oturum). Linkler dosya adından kuruldu; tarayıcıda açılıp doğrulanmadı.
