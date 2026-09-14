# Fener Bekçisi — Tasarım Notları

Kaynak: ChatGPT danışma (2026-09-14), patron süzdü. Kurallarla çelişen madde yok.

## 1. Mekanik sayısı — V1'de SADECE iki yeni şey
70 bölümü "dönen ayna + kaya + sabit ayna" ile doldurmak matematiksel olarak
mümkün ama oyuncunun zihninde aynı bulmaca tekrar eder. V1'e eklenecek:
- **Işık bölücü** (~31. bölüm): 1 ışık → 2 ışık
- **Renk filtresi** (~41. bölüm): kırmızı gemi sadece kırmızı ışık ister
Bundan fazlası tek kişi için gereksiz kapsam.

## 2. Zorluk ritmi — düz çizgi DEĞİL
`kolay → orta → zor → nefes → yeni mekanik → kolay → orta → zor → nefes`
Sürekli zorlaşan eğri sakin oyun kimliğini bozar. Her 10 bölümde bir
"gösterişli ama kolay" nefes bölümü.

### Merdiven
| Bölüm | İçerik |
|---|---|
| 1-5 | 1→3 ayna, öğretici yazı 5'te tamamen kalkar |
| 6-9 | Daha uzun ışık yolu |
| 10 | Nefes (güzel, kolay) |
| 11 | **İlk kaya** |
| 12-19 | Kaya + aynalar, ilk gerçek düşünme |
| 20 | Nefes |
| 21 | **İlk sabit ayna** |
| 22-29 | Sabit + dönen + kaya, "aha" anları |
| 30 | Büyük ışık zinciri |
| 31 | **Işık bölücü** |
| 32-39 | Bölücü + iki hedef, çok kollu problem |
| 40 | Nefes |
| 41 | **Renk filtresi** |
| 42-49 | Renk + sabit ayna |
| 50 | Nefes (renk gösterisi) |
| 51-65 | Birleşik ileri seviye, 65 son nefes |
| 66-70 | En iyi "aha" bulmacaları, final |

### Yeni mekanik için 3 bölüm kuralı
A = öğret · B = yardımsız kullandır · C = eski sistemle birleştir.
**Tanıtım bölümü zor olmaz.** Yeni kuralı anlamak ile zor bulmaca çözmek
aynı anda istenmez.

## 3. "Tek çözüm" ≠ zor
Tek çözüm sadece "doğru dizilim benzersiz" der; kaç saniye düşündürdüğünü
söylemez. Çözücü karmaşıklığı ile insanın hissettiği zorluk otomatik olarak
örtüşmüyor. Ölçülecek metrikler:

`solution_count` · `solution_toggles` (kaç ayna çevrilmeli) ·
`solution_reflections` · `relevant_mirrors` / `irrelevant_mirrors` ·
`expanded_states` (çözücü kaç durum inceledi) · `max_backtrack` ·
`near_misses` · `beam_crossings`

Başlangıç zorluk puanı: %30 arama eforu · %25 geri dönüş · %20 çevirme
sayısı · %15 yansıma · %10 near-miss. Havuzda 0-1'e normalize edilir.
**Son kalibrasyonu oyuncu yapar, çözücü değil.**

### Hedef süreler (ilk çözüm, medyan)
1-10: 10-30 sn · 11-30: 25-75 sn · 31-50: 45-120 sn · 51-65: 75-180 sn ·
66-70: 2-5 dk. **20 dakika süren bölüm başarı değildir** — "zor" ile
"yorucu" ayrı şeyler.

### Testçiden toplanacak (20 kişi bile yeter)
`first_solve_seconds` · `total_taps` · `unique_states_seen` ·
`reset_count` · `idle_seconds`

## 4. Üreteç: önce çözüm, sonra bulmaca
Rastgele tahta üretip çözüm arama — TERSİ yapılır:
```
GÜZEL IŞIK YOLU ÜRET → kayaları koy → kestirmeleri kapat →
aynaları yanlış yöne çevir → çözücüyle doğrula → zorluk ölç →
kalite ölç → ELE / TUT
```
1000 üretimin 900'ünün çöpe gitmesi normaldir.
**"Çözülebiliyor = iyi bulmaca" YANLIŞTIR.**

### Kalite filtresi
| Ölçüt | İstenen |
|---|---|
| Çözülebilir | evet |
| Benzersiz final | tercihen evet |
| Kullanılan dönen ayna | ≥ %70 |
| Tamamen gereksiz ayna | 0-1 |
| Near-miss | 1-3 |
| Işık kesişmesi | 0-2 |
| Çözümde yansıma | 3-9 |
| Son 10 bölüme yapısal benzerlik | düşük |
| Görünmez/şansa bağlı bilgi | 0 |

### "Aha" metriği
Çözüm, ışığı hedeften ÖNCE uzaklaştırmayı gerektiriyorsa iyi ters köşedir.
"Aaa, oradan dolaştırmam gerekiyormuş." — iyi bulmacanın değeri burada.

## 5. Tıkanma: ipucu vermeden rahatlatma
- 12-15 sn hareketsizlik: ışık fenerden bittiği yere kadar hafifçe yeniden
  akar (ne yaptığını hatırlatır, yol göstermez)
- 20-25 sn: tüm döndürülebilir aynalar aynı anda çok hafif nefes alır
  (doğru aynayı göstermediği için ipucu değildir)
- **Odak modu:** dekoru %60 karart, ızgarayı netleştir, ışığı kalınlaştır
- **Undo ve reset sınırsız** (ceza sistemi zaten yok)
- **Yanlış yansıma da tatmin edici olsun:** kayada kıvılcım, denizde su
  parlaması, döngüde ışık döngüyü takip etsin. Oyuncu "yanlış yaptım"
  değil "bu yolun neden yanlış olduğunu gördüm" demeli

## 6. Başarı ölçütü (her şeyin üstünde)
İlk 10 oyuncudan 7-8'i, ilk ışık zinciri tamamlandığında
**"bir tane daha oynayayım"** diyor mu? Bu yoksa 70 bölüm de, reklam da,
pazarlama da kurtarmaz.
