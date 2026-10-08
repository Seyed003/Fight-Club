extends Control
## A short menu of replies. `ask()` resolves to the chosen index.

signal chosen(index: int)

var _box: VBoxContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func ask(options: Array) -> int:
	for c in get_children():
		c.queue_free()
	var shade := UI.dim(0.35)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	_box = UI.vbox(14)
	_box.custom_minimum_size = Vector2(760, 0)
	add_child(UI.center(_box))
	for i in options.size():
		var opt: Dictionary = options[i]
		var idx := i
		var b := UI.button({"fa": opt.get("fa", ""), "en": opt.get("en", "")}, func(): chosen.emit(idx), "BigButton")
		b.alignment = HORIZONTAL_ALIGNMENT_RIGHT if Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(760, 64)
		b.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
		_box.add_child(b)
	visible = true
	if _box.get_child_count() > 0:
		(_box.get_child(0) as Button).grab_focus.call_deferred()
	var result: int = await chosen
	visible = false
	for c in get_children():
		c.queue_free()
	return result
