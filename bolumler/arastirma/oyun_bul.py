"""
Google Play oyun arayıcı — paket adlarını BULUR (uydurmaz).

NEDEN: yorum_cek.py'ye oyun eklemek için paket adı lazım
(com.sirket.oyun). Bunları tahmin etmek yerine Play'de arayıp
gerçeğini buluruz.

ÇALIŞTIRMA:
    python oyun_bul.py

Çıktı hem ekrana basılır hem `oyunlar_bulundu.txt` dosyasına yazılır.
Beğendiğin satırları yorum_cek.py içindeki OYUNLAR sözlüğüne
kopyalarsın.
"""

import pathlib
import time

try:
    from google_play_scraper import search
except ImportError:
    raise SystemExit("Eksik kütüphane:\n\n    pip install google-play-scraper\n")

# Aranacak terimler — bizim modelimize (reklamlı, bedava, offline)
# benzeyen oyunları hedefliyor. Ağırlık İngilizce'de.
# (arama terimi, dil, ülke)
ARAMALAR = [
    ("match 3 offline", "en", "us"),
    ("match 3 no internet no wifi", "en", "us"),
    ("match 3 animals", "en", "us"),
    ("free match 3 no ads", "en", "us"),
    ("relaxing match 3 puzzle", "en", "us"),
    ("mining puzzle game", "en", "us"),
    ("hayvan bulmaca oyunu", "tr", "tr"),
    ("madenci bulmaca", "tr", "tr"),
]
ADET = 8  # arama başına gösterilecek sonuç


def main() -> None:
    satirlar: list[str] = ["Google Play arama sonuclari", ""]

    for terim, dil, ulke in ARAMALAR:
        satirlar += ["", "=" * 78, f"ARAMA: {terim}   [{dil}/{ulke}]", "=" * 78]
        try:
            sonuclar = search(terim, lang=dil, country=ulke, n_hits=ADET)
        except Exception as hata:
            satirlar.append(f"  HATA: {hata}")
            continue

        for s in sonuclar:
            puan = s.get("score")
            puan_str = f"{puan:.2f}" if puan else " -- "
            ucretsiz = "bedava" if s.get("free") else "UCRETLI"
            baslik = (s.get("title") or "")[:38]
            satirlar.append(f"  {puan_str}  {ucretsiz:8s}  {baslik:40s} {s.get('appId')}")

        time.sleep(1.0)

    satirlar += [
        "",
        "",
        "Begendiklerini yorum_cek.py icindeki OYUNLAR sozlugune ekle:",
        '    "Oyun Adi": "com.paket.adi",',
    ]

    metin = "\n".join(satirlar)
    pathlib.Path("oyunlar_bulundu.txt").write_text(metin, encoding="utf-8")

    # Windows konsolu Turkce kod sayfasinda bazi karakterleri basamiyor.
    print(metin.encode("ascii", "replace").decode("ascii"))
    print("\nDosyaya da yazildi: oyunlar_bulundu.txt")


if __name__ == "__main__":
    main()
