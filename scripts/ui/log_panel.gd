extends Control
## Scrollable history of everything said so far in the chapter.

signal closed

var history: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade := UI.dim(0.85)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(140, 50)
	panel.size = Vector2(1000, 620)
	add_child(panel)
	var v := UI.vbox(10)
	panel.add_child(v)
	v.add_child(UI.label("log", "Heading", HORIZONTAL_ALIGNMENT_CENTER))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	var list := UI.vbox(12)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if history.is_empty():
		list.add_child(UI.label("no_log", "Small"))
	for entry in history:
		var who: String = entry["who"]
		var l := Label.new()
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(940, 0)
		l.theme_type_variation = "Small" if who == "narr" else ""
		var prefix := "" if who == "narr" else Cast.display_name(who) + ": "
		l.text = prefix + Loc.pick(entry["pair"])
		if who != "narr":
			l.add_theme_color_override("font_color", Cast.name_color(who))
		UI.apply_dir(l)
		list.add_child(l)
	var back := UI.button("back", _close, "BigButton")
	v.add_child(back)
	back.grab_focus.call_deferred()
	await get_tree().process_frame
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	get_tree().paused = true


func _close() -> void:
	get_tree().paused = false
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("log"):
		get_viewport().set_input_as_handled()
		_close()
