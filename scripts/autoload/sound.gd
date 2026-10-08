extends Node
## Music with crossfades, a pool of one-shot effects, looping ambience
## beds, and optional per-line voice files.
##
## Voice files are looked up as res://assets/voice/<lang>/<line_id>.ogg.
## Lines without a file are simply silent, so voice acting can be added
## one recording at a time.

const MUSIC_DIR := "res://assets/audio/music/%s.ogg"
const SFX_DIR := "res://assets/audio/sfx/%s.ogg"
const VOICE_DIR := "res://assets/voice/%s/%s.ogg"

var _music: Array[AudioStreamPlayer] = []
var _music_idx := 0
var _music_name := ""
var _sfx: Array[AudioStreamPlayer] = []
var _sfx_next := 0
var _amb: Dictionary = {}
var _voice: AudioStreamPlayer
var _cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		add_child(p)
		_music.append(p)
	for i in 14:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx.append(p)
	_voice = AudioStreamPlayer.new()
	_voice.bus = "Voice"
	add_child(_voice)


func _stream(path: String, loop := false) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		_cache[path] = null
		return null
	var s: AudioStream = load(path)
	if loop and s is AudioStreamOggVorbis:
		s = s.duplicate()
		s.loop = true
	_cache[path] = s
	return s


func play_music(track: String, fade := 1.5) -> void:
	if track == _music_name:
		return
	if track == "" or track == "stop":
		stop_music(fade)
		return
	var stream := _stream(MUSIC_DIR % track, true)
	if stream == null:
		push_warning("Sound: no music track %s" % track)
		return
	_music_name = track
	var old := _music[_music_idx]
	_music_idx = 1 - _music_idx
	var cur := _music[_music_idx]
	cur.stream = stream
	cur.volume_db = -40.0
	cur.play()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(cur, "volume_db", 0.0, fade)
	if old.playing:
		tw.tween_property(old, "volume_db", -40.0, fade)
		tw.chain().tween_callback(old.stop)


func stop_music(fade := 1.0) -> void:
	_music_name = ""
	for p in _music:
		if p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, fade)
			tw.tween_callback(p.stop)


func current_music() -> String:
	return _music_name


## One-shot effect. `pitch_jitter` adds a little variation so repeated
## punches don't sound identical.
func sfx(sfx_name: String, volume_db := 0.0, pitch := 1.0, pitch_jitter := 0.06) -> void:
	var stream := _stream(SFX_DIR % sfx_name)
	if stream == null:
		return
	var p := _sfx[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx.size()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch * (1.0 + randf_range(-pitch_jitter, pitch_jitter))
	p.play()


func ambience(amb_name: String, volume_db := -6.0, fade := 1.2) -> void:
	if _amb.has(amb_name):
		return
	var stream := _stream(SFX_DIR % amb_name, true)
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = stream
	p.volume_db = -40.0
	add_child(p)
	p.play()
	_amb[amb_name] = p
	create_tween().tween_property(p, "volume_db", volume_db, fade)


func stop_ambience(amb_name := "", fade := 1.0) -> void:
	var names: Array = _amb.keys() if amb_name == "" else [amb_name]
	for n in names:
		if not _amb.has(n):
			continue
		var p: AudioStreamPlayer = _amb[n]
		_amb.erase(n)
		var tw := create_tween()
		tw.tween_property(p, "volume_db", -40.0, fade)
		tw.tween_callback(p.queue_free)


## Plays the recorded line if one exists. Returns true when it did.
func voice(line_id: String) -> bool:
	_voice.stop()
	if line_id == "":
		return false
	var stream := _stream(VOICE_DIR % [Settings.lang, line_id])
	if stream == null:
		return false
	_voice.stream = stream
	_voice.play()
	return true


func voice_playing() -> bool:
	return _voice.playing


func stop_voice() -> void:
	_voice.stop()
