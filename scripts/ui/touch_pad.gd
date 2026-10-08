extends Control
## On-screen buttons for phones and tablets. Each button presses an input
## action while a finger is on it, so games read touch exactly like keys.

## [action, label, centre, radius]
var buttons: Array = []
var _held: Dictionary = {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


static func wanted() -> bool:
	return DisplayServer.is_touchscreen_available() or Game.test_args.has("touch")


func fight_layout() -> void:
	buttons = [
		["left", "<", Vector2(96, 600), 54.0],
		["right", ">", Vector2(228, 600), 54.0],
		["block", "S", Vector2(162, 490), 44.0],
		["jab", "J", Vector2(1060, 610), 50.0],
		["cross", "K", Vector2(1176, 560), 50.0],
		["kick", "I", Vector2(1080, 490), 46.0],
		["dodge", "O", Vector2(960, 640), 40.0],
		["special", "U", Vector2(1190, 440), 40.0],
	]
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			var a := _hit(event.position)
			if a != "":
				_held[event.index] = a
				Input.action_press(a)
				get_viewport().set_input_as_handled()
		elif _held.has(event.index):
			Input.action_release(_held[event.index])
			_held.erase(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag and _held.has(event.index):
		var a := _hit(event.position)
		if a != _held[event.index]:
			Input.action_release(_held[event.index])
			_held.erase(event.index)
			if a != "":
				_held[event.index] = a
				Input.action_press(a)
		queue_redraw()


func _hit(screen_pos: Vector2) -> String:
	var local := get_global_transform_with_canvas().affine_inverse() * screen_pos
	for b in buttons:
		if local.distance_to(b[2]) <= b[3] * 1.15:
			return b[0]
	return ""


func _exit_tree() -> void:
	for idx in _held:
		Input.action_release(_held[idx])
	_held.clear()


func _draw() -> void:
	var f: Font = Loc.font_fa_bold
	var held_actions := _held.values()
	for b in buttons:
		var on: bool = b[0] in held_actions
		draw_circle(b[2], b[3], Color(0, 0, 0, 0.35 if not on else 0.6))
		draw_arc(b[2], b[3], 0, TAU, 32, Color(1, 1, 1, 0.35 if not on else 0.8), 2.0, true)
		var s: String = b[1]
		if s == "<" or s == ">":
			var d := -1.0 if s == "<" else 1.0
			var c: Vector2 = b[2]
			draw_colored_polygon(PackedVector2Array([c + Vector2(d * 16, 0), c + Vector2(-d * 10, -16), c + Vector2(-d * 10, 16)]), Color(1, 1, 1, 0.8))
			continue
		var size := 26
		var w := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
		draw_string(f, b[2] - Vector2(w.x * 0.5, -size * 0.35), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(1, 1, 1, 0.8))
