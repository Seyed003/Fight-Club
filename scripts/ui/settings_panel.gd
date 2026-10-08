extends Control
## Settings, shared by the main menu and the pause menu.

signal closed

var allow_reset := false
var _reset_armed := false
var _reset_btn: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade := UI.dim(0.7)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	add_child(UI.center(panel))
	var v := UI.vbox(14)
	panel.add_child(v)
	var title := UI.label("settings", "Heading", HORIZONTAL_ALIGNMENT_CENTER)
	v.add_child(title)
	v.add_child(_row("language", _lang_button()))
	v.add_child(_row("music", UI.slider(Settings.music_volume, func(x):
		Settings.music_volume = x
		Settings.apply_audio()
		Settings.save_settings())))
	v.add_child(_row("sfx", UI.slider(Settings.sfx_volume, func(x):
		Settings.sfx_volume = x
		Settings.apply_audio()
		Settings.save_settings()
		Sound.sfx("punch_light", -10.0))))
	v.add_child(_row("voice", UI.slider(Settings.voice_volume, func(x):
		Settings.voice_volume = x
		Settings.apply_audio()
		Settings.save_settings())))
	v.add_child(_row("text_speed", UI.slider(Settings.text_speed, func(x):
		Settings.text_speed = x
		Settings.save_settings(), 0.4, 3.0, 0.1)))
	v.add_child(UI.check("film_grain", Settings.film_grain, func(on):
		Settings.film_grain = on
		Settings.save_settings()
		Settings.apply_audio()))
	v.add_child(UI.check("story_mode", Settings.story_mode, func(on):
		Settings.story_mode = on
		Settings.save_settings()))
	if not OS.has_feature("web") and not OS.has_feature("mobile"):
		v.add_child(UI.check("fullscreen", Settings.fullscreen, func(on):
			Settings.fullscreen = on
			Settings.save_settings()
			Settings.apply_window()))
	if allow_reset:
		_reset_btn = UI.button("reset", _on_reset)
		v.add_child(_reset_btn)
	var back := UI.button("back", func():
		closed.emit()
		queue_free(), "BigButton")
	v.add_child(back)
	back.grab_focus.call_deferred()


func _row(key: String, control: Control) -> Control:
	var h := UI.hbox(18)
	var l := UI.label(key)
	l.custom_minimum_size = Vector2(260, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	h.add_child(control)
	return h


func _lang_button() -> Button:
	var b := UI.button("lang_switch", func(): Settings.toggle_lang())
	b.custom_minimum_size = Vector2(260, 0)
	return b


func _on_reset() -> void:
	if not _reset_armed:
		_reset_armed = true
		Loc.bind(_reset_btn, "reset_confirm")
		return
	Settings.reset_progress()
	Loc.bind(_reset_btn, "reset_done")
	_reset_btn.disabled = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		closed.emit()
		queue_free()
