extends Node
## Player preferences and story progress. Both live in user:// so they
## survive restarts; every read and write tolerates a missing file.

signal language_changed(lang: String)
signal audio_changed

const SETTINGS_PATH := "user://settings.cfg"
const SAVE_PATH := "user://save.cfg"

var lang := "fa"
var music_volume := 0.75
var sfx_volume := 0.9
var voice_volume := 1.0
var text_speed := 1.0
var film_grain := true
var story_mode := false
var fullscreen := false

## Highest chapter index the player may start from the chapter list.
var unlocked := 0
## Chapter to resume with "Continue". -1 means no game in progress.
var current_chapter := -1
var flags: Dictionary = {}


func _ready() -> void:
	_setup_buses()
	_setup_input()
	load_settings()
	load_progress()
	apply_audio()


func set_lang(value: String) -> void:
	if value == lang:
		return
	lang = value
	save_settings()
	language_changed.emit(lang)


func toggle_lang() -> void:
	set_lang("en" if lang == "fa" else "fa")


func apply_audio() -> void:
	_set_bus("Music", music_volume)
	_set_bus("SFX", sfx_volume)
	_set_bus("Voice", voice_volume)
	audio_changed.emit()


func apply_window() -> void:
	if OS.has_feature("web") or OS.has_feature("mobile"):
		return
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func unlock(chapter: int) -> void:
	unlocked = max(unlocked, chapter)
	save_progress()


func set_flag(name: String, value: Variant = true) -> void:
	flags[name] = value
	save_progress()


func get_flag(name: String, default: Variant = null) -> Variant:
	return flags.get(name, default)


func reset_progress() -> void:
	unlocked = 0
	current_chapter = -1
	flags.clear()
	save_progress()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	lang = cfg.get_value("ui", "lang", lang)
	text_speed = cfg.get_value("ui", "text_speed", text_speed)
	film_grain = cfg.get_value("video", "film_grain", film_grain)
	fullscreen = cfg.get_value("video", "fullscreen", fullscreen)
	story_mode = cfg.get_value("game", "story_mode", story_mode)
	music_volume = cfg.get_value("audio", "music", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
	voice_volume = cfg.get_value("audio", "voice", voice_volume)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ui", "lang", lang)
	cfg.set_value("ui", "text_speed", text_speed)
	cfg.set_value("video", "film_grain", film_grain)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("game", "story_mode", story_mode)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("audio", "voice", voice_volume)
	cfg.save(SETTINGS_PATH)


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	unlocked = cfg.get_value("story", "unlocked", 0)
	current_chapter = cfg.get_value("story", "current", -1)
	flags = cfg.get_value("story", "flags", {})


func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("story", "unlocked", unlocked)
	cfg.set_value("story", "current", current_chapter)
	cfg.set_value("story", "flags", flags)
	cfg.save(SAVE_PATH)


func _setup_buses() -> void:
	for bus_name in ["Music", "SFX", "Voice"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus_name)
			AudioServer.set_bus_send(i, "Master")


func _set_bus(bus_name: String, linear: float) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	if i == -1:
		return
	AudioServer.set_bus_mute(i, linear <= 0.001)
	AudioServer.set_bus_volume_db(i, linear_to_db(max(linear, 0.001)))


## Input actions are registered here instead of in project.godot so the
## bindings stay readable in one place.
func _setup_input() -> void:
	var binds := {
		"advance": [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER],
		"skip": [KEY_CTRL],
		"pause": [KEY_ESCAPE, KEY_P],
		"log": [KEY_L],
		"left": [KEY_A, KEY_LEFT],
		"right": [KEY_D, KEY_RIGHT],
		"up": [KEY_W, KEY_UP],
		"down": [KEY_S, KEY_DOWN],
		"jab": [KEY_J, KEY_Z],
		"cross": [KEY_K, KEY_X],
		"kick": [KEY_I, KEY_C],
		"block": [KEY_SHIFT, KEY_S, KEY_DOWN],
		"dodge": [KEY_O, KEY_V],
		"special": [KEY_U, KEY_B],
		"act": [KEY_SPACE, KEY_E, KEY_ENTER],
	}
	var pads := {
		"advance": [JOY_BUTTON_A],
		"pause": [JOY_BUTTON_START],
		"jab": [JOY_BUTTON_X],
		"cross": [JOY_BUTTON_Y],
		"kick": [JOY_BUTTON_B],
		"block": [JOY_BUTTON_RIGHT_SHOULDER],
		"dodge": [JOY_BUTTON_LEFT_SHOULDER],
		"special": [JOY_BUTTON_RIGHT_STICK],
		"act": [JOY_BUTTON_A],
		"left": [JOY_BUTTON_DPAD_LEFT],
		"right": [JOY_BUTTON_DPAD_RIGHT],
		"up": [JOY_BUTTON_DPAD_UP],
		"down": [JOY_BUTTON_DPAD_DOWN],
	}
	for action in binds:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.3)
		for key in binds[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
	for action in pads:
		for button in pads[action]:
			var ev := InputEventJoypadButton.new()
			ev.button_index = button
			InputMap.action_add_event(action, ev)
	for axis_bind in [["left", JOY_AXIS_LEFT_X, -1.0], ["right", JOY_AXIS_LEFT_X, 1.0],
			["up", JOY_AXIS_LEFT_Y, -1.0], ["down", JOY_AXIS_LEFT_Y, 1.0]]:
		var ev := InputEventJoypadMotion.new()
		ev.axis = axis_bind[1]
		ev.axis_value = axis_bind[2]
		InputMap.action_add_event(axis_bind[0], ev)
