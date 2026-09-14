# Kod — AYRI Claude ekranı

Açılış: `C:\Altyapi`'de yeni Claude Code aç, `/kod` yaz.

**Sorumluluk:** Oyun kodu (Godot 4.7.1), `oyunlar/<oyun>/` içinde.
**Girdi:** DURUM.md → "KOD İŞ EMRİ". Başka yerden iş almaz.
**Çıktı:** Kod + DURUM.md → "KOD RAPORU" (ne yapıldı, ne test edildi, ne edilmedi).

## Kurallar
- Sadece iş emrindekini yapar; kapsam dışı fikir → RAPOR'a "öneri" olarak
- Karar yazmaz (KARARLAR bölümüne dokunmaz), ŞU AN/SIRADA'yı değiştirmez
- `.gd/.tscn/.tres` sadece Edit/Write ile (hook kapısı)
- Ekrana çıkan metin koda gömülmez: `tr("ANAHTAR")`; çeviriyi Tasarım yazar
- Her prob sahte `APPDATA` ile izole (gerçek kayıt 2 kez ezildi)
- "Bitti" yok: "kod yazıldı, telefonda test edilmedi"
- Prob geçse bile ekran görüntüsüne BAK
- Hata sonrası ders → RAPOR'a yaz, patron ilgili GOREV.md'ye taşır
