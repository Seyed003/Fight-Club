extends Control
## In-chapter pause menu. Pauses the tree while open.

signal resumed
signal skip_challenge
signal to_menu

const SettingsPanel := preload("res://scripts/ui/settings_panel.gd")

var can_skip_challenge := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade := UI.dim(0.72)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var v := UI.vbox(14)
	v.custom_minimum_size = Vector2(420, 0)
	add_child(UI.center(v))
	v.add_child(UI.label("paused", "Heading", HORIZONTAL_ALIGNMENT_CENTER))
	var resume := UI.button("resume", _resume, "BigButton")
	v.add_child(resume)
	v.add_child(UI.button("lang_switch", func(): Settings.toggle_lang()))
	v.add_child(UI.button("settings", _open_settings))
	if can_skip_challenge:
		v.add_child(UI.button("skip_challenge", func():
			skip_challenge.emit()
			_resume()))
	v.add_child(UI.button("main_menu", func():
		get_tree().paused = false
		to_menu.emit()))
	resume.grab_focus.call_deferred()
	get_tree().paused = true


func _resume() -> void:
	get_tree().paused = false
	resumed.emit()
	queue_free()


func _open_settings() -> void:
	var s := SettingsPanel.new()
	s.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(s)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_resume()
