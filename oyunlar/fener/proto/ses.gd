extends Node
## Ses (autoload "Ses", İŞ 8). Ortam: deniz + çok kısık rüzgâr, sürekli döngü;
## sahne değişince kesilmez. Efekt: ayna, ışın ulaştı, bölüm tamam, düğme.
## Müzik yok. Ayar (efekt aç/kapa, ortam aç/kapa) cihazda saklanır: user://ayarlar.cfg
## Dosya yoksa ya da ayar dosyası bozuksa oyun çalışmaya devam eder: sessiz
## kalır / varsayılana döner. Ayar dosyasından sadece iki bool okunur.

const SETTINGS_PATH := "user://ayarlar.cfg"
const AMBIENT := {  # ad → [yol, ses (dB)]
	"deniz": ["res://sesler/ortam_deniz.ogg", -8.0],
	"ruzgar": ["res://sesler/ortam_ruzgar.ogg", -24.0],
}
const SFX := {
	"ayna": ["res://sesler/ayna_cevir.mp3", -10.0],
	"isin": ["res://sesler/isin_ulasti.mp3", -6.0],
	"tamam": ["res://sesler/bolum_tamam.mp3", -4.0],
	"dugme": ["res://sesler/dugme.mp3", -8.0],
}
const SFX_VOICES := 4  # aynı anda çalabilecek efekt sayısı

var sfx_on := true
var ambient_on := true
var _ambient: Array = []
var _voices: Array = []
var _streams := {}
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()
	for key in SFX:
		_streams[key] = _load(SFX[key][0])
	for key in AMBIENT:
		var p := AudioStreamPlayer.new()
		p.stream = _load(AMBIENT[key][0])
		p.volume_db = AMBIENT[key][1]
		add_child(p)
		_ambient.append(p)
	for i in SFX_VOICES:
		var v := AudioStreamPlayer.new()
		add_child(v)
		_voices.append(v)
	_apply_ambient()


## Dosya yoksa null (oyun sessiz devam eder, hata ekrana çıkmaz).
func _load(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("ses dosyasi yok: " + path)
		return null
	return load(path) as AudioStream


func play(key: String) -> void:
	if not sfx_on or not _streams.has(key) or _streams[key] == null:
		return
	var v: AudioStreamPlayer = _voices[_next]
	_next = (_next + 1) % _voices.size()
	v.stream = _streams[key]
	v.volume_db = SFX[key][1]
	v.play()


func set_sfx(on: bool) -> void:
	sfx_on = on
	_save_settings()


func set_ambient(on: bool) -> void:
	ambient_on = on
	_apply_ambient()
	_save_settings()


func _apply_ambient() -> void:
	for p in _ambient:
		if p.stream == null:
			continue
		if ambient_on and not p.playing:
			p.play()
		elif not ambient_on:
			p.stop()


## Bozuk/eksik dosya ya da yanlış tip → varsayılan (açık). Başka alan okunmaz.
func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	var s = cfg.get_value("ses", "efekt", true)
	var a = cfg.get_value("ses", "ortam", true)
	sfx_on = s if s is bool else true
	ambient_on = a if a is bool else true


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ses", "efekt", sfx_on)
	cfg.set_value("ses", "ortam", ambient_on)
	cfg.save(SETTINGS_PATH)
