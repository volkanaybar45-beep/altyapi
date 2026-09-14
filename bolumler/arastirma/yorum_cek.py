"""
Google Play yorum toplayıcı — rakip match-3 oyunlarının yorumlarını çeker.

AMAÇ: Oyuncular bu türden oyunlarda NEYE kızıyor, NEYİ seviyor?
Tasarım kararlarını tahminle değil, gerçek oyuncu sözüyle vermek için.

KURULUM (bir kez):
    pip install google-play-scraper

ÇALIŞTIRMA:
    python yorum_cek.py

ÇIKTI:
    ham/<paket_adi>.json   — her oyunun ham yorumları
    ozet_girdi.md          — Claude'a verilecek, okunabilir özet

NOT: Sadece HERKESE AÇIK yorumlar çekilir. Kullanıcı adları çıktıya
YAZILMAZ (kişisel veri tutmuyoruz, sadece yorum metni + puan + tarih).
İstekler arasında bekleme var — sunucuyu yormayalım.
"""

import json
import pathlib
import time

try:
    from google_play_scraper import Sort, reviews
except ImportError:
    raise SystemExit(
        "Eksik kütüphane. Şunu çalıştır:\n\n    pip install google-play-scraper\n"
    )

# ---------------------------------------------------------------------------
# AYARLAR — buraya rakip oyunların paket adlarını yaz.
# Paket adını Play linkinden alırsın:
#   https://play.google.com/store/apps/details?id=BURASI
# ---------------------------------------------------------------------------

OYUNLAR = {
    # 2. TUR — bizim modelimize yakın oyunlar: bedava, reklamlı,
    # offline, orta/küçük stüdyo. (1. tur dev IAP oyunlarıydı, tr/tr.)
    "Relaxing Match Game": "home.match3.matching.puzzle.relaxing.brain.fun.lockdown.calm.forest.nature.stress.relief.games",
    "Jewel Match Dragon - No Wifi": "granddream.puzzlegame.jewelblast",
    "Jewel Blast Dragon - No Wifi": "com.go7game.jewelclassic",
    "MonsterBusters Match 3": "com.purplekiwii.mb",
    "Cookie Cats": "dk.tactile.cookiecats",
    "Match 3 Animals": "com.oniksstudio.match3animals",
}

DIL = "en"          # 2. tur İngilizce. 1. turun Türkçe verisi ham/ içinde duruyor.
ULKE = "us"
ADET = 400          # oyun başına yorum sayısı
BEKLEME = 1.5       # saniye, istekler arası

# ---------------------------------------------------------------------------

KOK = pathlib.Path(__file__).parent
HAM = KOK / "ham"
HAM.mkdir(exist_ok=True)


def cek(ad: str, paket: str) -> list[dict]:
    """Bir oyunun yorumlarını çeker. Kişisel veri (kullanıcı adı) atılır."""
    print(f"  {ad} ({paket}) ...", end=" ", flush=True)
    try:
        sonuc, _ = reviews(
            paket,
            lang=DIL,
            country=ULKE,
            sort=Sort.NEWEST,
            count=ADET,
        )
    except Exception as hata:
        print(f"HATA: {hata}")
        return []

    temiz = [
        {
            "puan": r.get("score"),
            "yorum": (r.get("content") or "").strip(),
            "tarih": str(r.get("at")),
            "begeni": r.get("thumbsUpCount", 0),
        }
        for r in sonuc
        if (r.get("content") or "").strip()
    ]
    print(f"{len(temiz)} yorum")
    return temiz


def main() -> None:
    print(f"Google Play yorumları çekiliyor (dil={DIL}, ülke={ULKE})\n")
    hepsi: dict[str, list[dict]] = {}

    for ad, paket in OYUNLAR.items():
        veri = cek(ad, paket)
        if veri:
            hepsi[ad] = veri
            (HAM / f"{paket}.json").write_text(
                json.dumps(veri, ensure_ascii=False, indent=2), encoding="utf-8"
            )
        time.sleep(BEKLEME)

    if not hepsi:
        print("\nHiç veri çekilemedi. İnternet bağlantısını ve paket adlarını kontrol et.")
        return

    # --- Claude'a verilecek özet ---
    satirlar = ["# Rakip Oyun Yorumları — 2. TUR (bize benzeyen oyunlar, İngilizce)", ""]
    satirlar.append(f"Çekim tarihi: {time.strftime('%Y-%m-%d %H:%M')}  ")
    satirlar.append(f"Dil/ülke: {DIL}/{ULKE}  ·  Oyun başına hedef: {ADET} yorum")
    satirlar.append("")

    for ad, veri in hepsi.items():
        dusuk = [r for r in veri if r["puan"] and r["puan"] <= 2]
        yuksek = [r for r in veri if r["puan"] and r["puan"] >= 4]
        ort = sum(r["puan"] for r in veri if r["puan"]) / max(len(veri), 1)

        satirlar += [
            f"## {ad}",
            "",
            f"- Toplam: {len(veri)} yorum · Ortalama puan: {ort:.2f}",
            f"- Düşük puan (1-2★): {len(dusuk)} · Yüksek puan (4-5★): {len(yuksek)}",
            "",
            "### En çok beğenilen ŞİKÂYETLER (1-2★, beğeniye göre)",
            "",
        ]
        for r in sorted(dusuk, key=lambda x: -x["begeni"])[:15]:
            satirlar.append(f"- **{r['puan']}★** ({r['begeni']} beğeni) — {r['yorum'][:300]}")

        satirlar += ["", "### En çok beğenilen ÖVGÜLER (4-5★, beğeniye göre)", ""]
        for r in sorted(yuksek, key=lambda x: -x["begeni"])[:10]:
            satirlar.append(f"- **{r['puan']}★** ({r['begeni']} beğeni) — {r['yorum'][:300]}")

        satirlar.append("")

    (KOK / "ozet_girdi_2.md").write_text("\n".join(satirlar), encoding="utf-8")

    print(f"\nBitti.")
    print(f"  Ham veri : {HAM}")
    print(f"  Özet     : {KOK / 'ozet_girdi_2.md'}")
    print("\nŞimdi 'ozet_girdi.md' dosyasını Claude'a ver, analiz etsin.")


if __name__ == "__main__":
    main()
