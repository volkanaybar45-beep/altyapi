# Fener Bekçisi — Görsel Defteri

Lisans kanıt zinciri. Kayıtsız dosya oyuna giremez.
İzinli zemin: ChatGPT (OpenAI) + Tripo Pro **Gizli**. Dreamina YASAK.
Tripo `.glb` üretim anında indirilir (7 günde siliniyor).

## Oyuna giren 3B zincir (2026-09-14)
Beş referans PNG → **Tripo Pro (Gizli)** → `.glb` (`glb/` klasöründe, indirildi) →
`bolumler/sanat/toon_render.py` → saydam PNG. Prompt'lar aşağıdaki tabloda,
referans satırlarında.

| Oyun dosyası | .glb | Render komutu | Not |
|---|---|---|---|
| fener_kulesi.png | glb/fener_kulesi.glb | `toon_render.py … z` | 512 px |
| ayna_plaka.png | glb/ayna_plaka.glb | `toon_render.py … z` | 512 px, kod 2B döndürür |
| ayna_taban.png | glb/ayna_taban.glb | `toon_render.py … z` | 256 px |
| tekne.png | glb/tekne.glb | `toon_render.py … z 0.30 - 0.72` | 512 px. **`x` yanlış çıktı** (tekne önden göründü), `z` doğru. 2026-09-15 (İŞ 6): gövde gece denizinde 1.95 kontrasttı, parlaklık 0.33→0.55 ile yeniden render → gövde/zemin 3.1-3.8. Eskisi `cop/fener_is6/tekne_eski_parlak032.png`. 2026-09-15 (İŞ 7): canlı denizde sis bandı üstünde 2.3 kaldı → parlaklık 0.72 (sis bandında 3.6); 0.55 sürümü `cop/fener_is7/tekne_parlak055.png` |
| kayalik.png | glb/kayalik.glb | `toon_render.py … z 0.30 - 0.32` | 512 px. Varsayılan render gece sahnesinde fazla açıktı, parlaklık 0.52→0.32 |

Gözle kontrol: hepsi gerçek arka plan üzerinde gerçek ölçekte bakıldı (540×960).
İki hata bulundu ve düzeltildi (tekne açısı, kayalık parlaklığı).

| Dosya adı | Tarih | Araç | Prompt | Format |
|---|---|---|---|---|
| ref_fener_kulesi.png | 2026-09-14 | ChatGPT (OpenAI) | A single stylized lighthouse tower for a mobile game icon, front three-quarter view, standing upright and centered, tapered cylindrical body in pale bone-white stone with one narrow horizontal band of weathered slate grey, a small glazed lamp room at the top glowing warm lantern yellow, a simple railing, no rocks and no ground beneath it, clean toon shading with flat color areas and a bold uniform dark outline, no more than two tones per surface, no fine texture detail, soft cartoon proportions, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects. | PNG 1232×1232, 2B referans (Tripo girdisi) |
| ref_ayna_plaka.png | 2026-09-14 | ChatGPT (OpenAI) | A single stylized mirror plate for a mobile game icon, viewed straight on from the front, a wide flat rectangular plate with softly rounded corners, clearly wider than tall, a pale silvery light-toned polished metal face set inside a chunky warm brass border frame, the plate has visible thickness like a solid slab, no reflected scenery drawn on the face, no stand and no base and no post, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, perfectly symmetrical left to right, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects. | PNG 1232×1232, 2B referans (Tripo girdisi) |
| ref_ayna_taban.png | 2026-09-14 | ChatGPT (OpenAI) | A single stylized short pedestal stand for a mobile game icon, front three-quarter view, a heavy round weathered brass base with a thick stubby vertical post on top ending in a simple pivot knob, nothing mounted on the post, chunky simplified shape wider at the bottom, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects. | PNG 1232×1232, 2B referans (Tripo girdisi) |
| ref_tekne.png | 2026-09-14 | ChatGPT (OpenAI) | A single stylized small fishing boat for a mobile game icon, pure side view facing right, short chunky wooden hull in cold dark blue-grey with a pale lighter stripe along the gunwale, one short mast with a tiny lantern hanging from it glowing warm lantern yellow, a small furled sail, rounded cartoon proportions wider than tall, no water and no waves under it, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects. | PNG 1232×1232, 2B referans (Tripo girdisi) |
| ref_kayalik.png | 2026-09-14 | ChatGPT (OpenAI) | A single stylized sea rock formation for a mobile game icon, front three-quarter view, a compact cluster of three or four blocky angular boulders in cold blue-grey slate with pale lighter tops, wider than tall, flat bottom so it can sit on a surface, no water and no plants, chunky simplified silhouette readable at small size, clean toon shading with flat color areas and a bold uniform dark outline, at most two tones per surface, isolated object on a plain flat neutral grey background, no shadow, no text, no other objects. | PNG 1232×1232, 2B referans (Tripo girdisi) |
| arkaplan_gece_denizi.png | 2026-09-14 (İŞ 7'de düzenlendi, 2026-09-15) | ChatGPT (OpenAI) + Python/PIL | A calm night sea scene as a vertical mobile game background, tall portrait composition, very dark navy water filling the lower two thirds with soft gentle horizontal wave bands and a faint pale moonlight streak on the surface, a slightly lighter deep blue night sky above with a low soft horizon line, empty center area with nothing in it so game objects can be placed on top, no lighthouse, no boat, no rocks, no moon, no star clusters, no text, no characters, smooth painterly flat toon style with soft gradients and no visible brush texture, low saturation, keep extra empty margin at the top and bottom edges for cropping. | PNG 941×1672, doğrudan oyuna girer (Tripo'ya uğramaz). Baskın ton ölçüldü: #082047. **İŞ 7 düzenlemesi:** ufuk altındaki (satır 519+) parlak ay izi ve dalga parıltıları o satırın deniz rengine çekildi, deniz en açık luminans 0.019'a sınırlandı (tekne kontrastı; ay yolu artık koddan). Gök değişmedi. Ham hali `cop/fener_is7/arkaplan_gece_denizi_eski.png` |
| sis_katmani.png | 2026-09-14 | ChatGPT (OpenAI) + `bolumler/sanat/sis_hazirla.py` | A horizontal band of soft pale blue-grey fog wisps on a fully transparent background, wide panoramic strip much wider than tall, smooth soft-edged cloudy shapes with feathered semi-transparent edges, low contrast and low saturation, no sharp lines, no objects, no text, the left and right edges must match so the strip tiles seamlessly when repeated horizontally, nothing else in the image. | PNG 2160×540 RGBA. Ham çıktıda mavi-beyaz saçak ve keskin sınır vardı; betikle RGB #5E7C99'a sabitlendi, kenar tüylendirildi, sol yarı aynalanarak tile edildi. Ölçüm: sol/sağ kenar farkı 0, opak piksel 0 |
| ay.png | 2026-09-14 | ChatGPT (OpenAI) + `bolumler/sanat/sacak_temizle.py` | A single stylized full moon for a mobile game, a plain pale cool white-blue disc with a very soft faint glow halo, two or three barely visible lighter craters, no face, no clouds, no stars, isolated on a fully transparent background, no text. | PNG 1254×1254 RGBA. Ham çıktının halesinde camgöbeği/yeşil saçak vardı; betikle düşük alfalı pikseller #E3EDF7'ye çekildi (1.018.212 piksel). Gerçek zeminde 140 px'e küçültülüp gözle bakıldı |

<!-- Satır örneği için gorsel_plan.md bölüm 2'deki prompt'lar kullanılır.
     Prompt sütununa promptun TAMAMI yazılır, özeti değil. -->


## İŞ 10 — Diyorama seti (2026-09-15) · kaynak: `diyorama_deneme/` (promptlar.md)
Akış: ChatGPT görseli → **Tripo Pro (kurucunun ücretli hesabı)** image-to-3D → `.glb` →
`bolumler/sanat/toon_render.py` (**yaw −40°, pitch 30°**, ışık soldan; `TR_YAW/TR_PITCH`) →
`proto/tools/is10_varlik.py` (kırpma/kopya/temizlik) → `proto/gorseller/`.
Lisans: Tripo ücretli hesap + ChatGPT (OpenAI) görselleri, ticari kullanım serbest.

| Dosya | Tarih | Araç | Prompt | Format / işlem |
|---|---|---|---|---|
| diyorama_deneme/diyorama_liman.glb | 2026-09-15 | ChatGPT → Tripo Pro (aydınlatma kapalı, PBR) | **YAZILI DEĞİL** — `promptlar.md`'de yalnız model adı var (`coastal village 3d model (1)`). Kurucuya soruldu | GLB 10 MB |
| diyorama_deneme/ayna.glb | 2026-09-15 | ChatGPT → Tripo Pro | Single game asset on plain background: a stylized brass harbor signal mirror. A round polished silver mirror disc held in an ornate golden brass ring, mounted on a short cylindrical stone-and-brass base with rivets. Cozy stylized 3D render, soft toon shading, warm lamp light from the left against cool blue night. Three-quarter view, centered, no text, no background scenery. | GLB 11 MB |
| diyorama_deneme/kaya_taban_duz.glb | 2026-09-15 | ChatGPT → Tripo Pro | Single game asset on plain background: a small rocky sea islet, grey weathered stone with green moss patches, FLAT TOP surface, wet dark stone at the waterline. Cozy stylized 3D render, soft toon shading, warm lamp light from the left against cool blue night. Three-quarter view, centered, no text, no background scenery. | GLB 11 MB |
| diyorama_deneme/kaya_engel_sivri.glb | 2026-09-15 | ChatGPT → Tripo Pro | Single game asset on plain background: a cluster of jagged sea rocks, grey weathered stone with green moss, POINTED uneven sharp tops, wet dark stone at the waterline. Cozy stylized 3D render, soft toon shading, warm lamp light from the left against cool blue night. Three-quarter view, centered, no text, no background scenery. | GLB 11 MB |
| diyorama_deneme/tekne.glb | 2026-09-15 | ChatGPT → Tripo Pro | Single game asset on plain background: a small stylized fishing boat, white hull with blue trim and a red waterline stripe, wooden deck, a small cabin with a warmly lit window, a lantern on the mast, rope fenders on the side. Cozy stylized 3D render, soft toon shading, warm lamp light from the left against cool blue night. Three-quarter view from slightly above, centered, no text, no background scenery. | GLB 11 MB |
| diyorama_deneme/gokyuzu_panorama.png | 2026-09-15 | ChatGPT (OpenAI), düz resim | Wide panoramic night sky over a distant sea horizon. Deep blue gradient from near-black at the top to soft indigo at the horizon, scattered stars, a few thin wispy clouds. Cozy stylized game art, soft painterly shading, no moon, no land, no boats, no text. | PNG 1672×941 |
| diyorama_deneme/ay.png | 2026-09-15 | ChatGPT (OpenAI), şeffaf zemin | Single game asset on transparent background: a large detailed full moon, pale silver-white with soft craters and a warm gentle halo glow. Cozy stylized game art, centered, no text, no background. | PNG 1254×1254 RGBA |

**Oyuna giren türevler** (`proto/gorseller/`, hepsi yukarıdaki kaynaklardan; render'lar `render/`'da):
| Oyun dosyası | Kaynak | İşlem |
|---|---|---|
| diyorama_levha.png | diyorama_liman.glb | render 1300 px, doygunluk dokunulmadı · y 90-670 kırpıldı (**iskele kesildi, E1**), alt 24 px yumuşak kenar · modelin kendi su plakası (koyu mavi) %75 saydam · 1228×580. Lamba (751.9, 78.9), kule 123 px |
| ayna_0..3.png | ayna.glb | 4 yön: model θ = 336.6 / 103.4 / 156.6 / 283.4 (kamera yaw = θ−40). Mil ekseni render'da 135.2° / 45.1° / 135.1° / 45.0° ölçüldü · parlaklık 0.60 (K6) |
| kaya_taban.png | kaya_taban_duz.glb | parlaklık 0.50 |
| kaya_engel.png | kaya_engel_sivri.glb | parlaklık 0.55 (K6) |
| tekne.png | tekne.glb (İŞ 10) | parlaklık 0.62 (K6). Eski 2B-kaynaklı tekne `cop/fener_is10/proto_tekne.png` |
| gokyuzu.png | gokyuzu_panorama.png | ufuk satırı 737'nin altı kesildi (1672×737) |
| ay.png | diyorama_deneme/ay.png | yarı saydam piksellerin rengi hale tonuna (#F2E3C0) çekildi (benek temizliği), 512 px. Eski ay `cop/fener_is10/proto_ay.png` |
