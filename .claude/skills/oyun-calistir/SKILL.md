---
name: oyun-calistir
description: Yaban'u (Godot 4.7.1) çalıştır, ekran görüntüsü al veya bir tanı (probe) betiği koştur. Bir değişikliğin gerçekten çalıştığını görmek, sahneyi render etmek, hata çıktısı okumak veya "screenshot al" istendiğinde kullan.
---

# Yaban'u çalıştır / ekran görüntüsü al

Godot bu makinede ÇALIŞIYOR. "Test edemiyorum, sen F5'le" deme — aşağıdaki
komutlarla kendin doğrula.

## Sabitler

- Godot: `C:\DevTools\Godot\4.7.1\Godot_v4.7.1-stable_win64_console.exe`
  (`_console.exe` olan sürümü kullan — stdout/stderr'i gerçekten veriyor)
- Proje: `C:\Yaban\yaban`
- Tanı betikleri: `yaban/tools/*.gd` (hepsi `extends SceneTree`)
- Ekran görüntüleri: `yaban/assets/gorseller/Screenshots`

## ZORUNLU: sahte APPDATA

Godot'u ÇALIŞTIRAN her komutta `APPDATA`'yı geçici bir klasöre yönlendir.
Aksi halde gerçek kayıt/istatistik dosyası (`user://`) ezilir — bu daha önce
İKİ KEZ gerçek kullanıcı verisini sildi (bkz. `tasks/lessons.md`).

```bash
export APPDATA="C:/Users/VOLKAG~1/AppData/Local/Temp/claude/godot_test_appdata"
mkdir -p "$APPDATA"
```

## 1. Sözdizimi/import kapısı (en hızlı kontrol)

```bash
"C:/DevTools/Godot/4.7.1/Godot_v4.7.1-stable_win64_console.exe" \
  --headless --path "C:/Yaban/yaban" --import
```

Çıktıda `SCRIPT ERROR` / `Parse Error` yoksa temiz. (Bu ayrıca `.gd` dosyası
her düzenlendiğinde PostToolUse hook'u olarak OTOMATİK çalışır; hook hata
bulursa sana geri bildirir.)

## 2. Ekran görüntüsü almak (GPU render)

Ekran görüntüsü için `--headless` KULLANMA. Bir `SceneTree` betiği
`main.tscn`'i bir `SubViewport`'a yükler, birkaç kare bekler, PNG yazar:

```bash
"C:/DevTools/Godot/4.7.1/Godot_v4.7.1-stable_win64_console.exe" \
  --path "C:/Yaban/yaban" -s tools/<probe>.gd -- <cikti.png> [ek args]
```

Hazır probe'lar (`--` sonrası argümanları için dosyanın başındaki yorum
satırına bak): `anasayfa_screenshot.gd`, `game_screen_probe.gd`,
`magaza_leak_probe.gd`, `magaza_confirm_probe.gd`, `ana_sayfa_settings_probe.gd`,
`ana_sayfa_dialog_probe.gd`, `critter_overlap_probe.gd`, `owl_pose_probe.gd`,
`viewport_resize_probe.gd`, `fairgen_probe.gd`.

Yeni bir ekran için yeni probe yaz — mevcut birini kopyala, kalıp aynı:
`SubViewport(720x1280)` → `main.tscn` instantiate → ~10 kare bekle →
`main._apply_ambiance(<tema>, false)` → ilgili ekranı açan fonksiyonu çağır
(`main._on_ana_sayfa_magaza_pressed()` gibi) → birkaç kare daha → PNG yaz.

Ürettiğin PNG'yi **Read ile aç ve gerçekten bak** — "kod doğru görünüyor"
demek doğrulama değildir.

## 3. Mantık testi (ekran gerekmiyorsa)

`--headless --path . -s tools/<test>.gd` ile `board.place()` /
`try_place_piece()` gibi gerçek üretim fonksiyonlarını çağırıp konsol
çıktısını oku.

## Notlar

- Probe betikleri kalıcı araçtır, silme — sonraki oturumda tekrar lazım olur.
- Bir probe için `main.gd`/`game.gd` içinde geçici test değişikliği yaptıysan
  (örn. `owned=true` zorlamak) doğrulama bitince GERİ AL.
- `.gd` dosyasında yaptığın her değişiklik otomatik commit+push edilir.
