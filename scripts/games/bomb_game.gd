extends GameModule
## The van in the garage. A detonator with four tagged wires; a page torn
## from the Project Mayhem notebook shows the order to pull them. Wrong
## wire: sparks and lost seconds. Run out of time: start over.
##   @game bomb time=45

const COLORS := [Color(0.85, 0.15, 0.12), Color(0.2, 0.45, 0.9), Color(0.25, 0.75, 0.3), Color(0.95, 0.82, 0.2)]

var _order: Array = []
var _cut: Array = []
var _limit := 45.0
var _left := 45.0
var _w: Control
var _info: Label
var _wire_tags: Array = []
var _buttons: Array = []


func begin() -> void:
	_limit = kvf("time", 45.0)
	_left = _limit
	_order = [0, 1, 2, 3]
	_order.shuffle()
	_wire_tags = [0, 1, 2, 3]
	_wire_tags.shuffle()
	_w = Control.new()
	UI.full(_w)
	_w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_w.draw.connect(_draw_bomb)
	ui.add_child(_w)
	_info = hint_label(Loc.pick({"fa": "سیم‌ها را به ترتیبِ برگه‌ی دفترچه قطع کن. روی هر سیم بزن یا کلید ۱ تا ۴.",
		"en": "Pull the wires in the order on the notebook page. Click a wire or press 1 to 4."}), 24.0, 22)
	var row := UI.hbox(18)
	row.position = Vector2(300, 620)
	ui.add_child(row)
	for i in 4:
		var idx := i
		var b := Button.new()
		b.text = "%d" % (i + 1)
		b.custom_minimum_size = Vector2(150, 56)
		b.add_theme_font_override("font", Loc.font_fa_black)
		b.add_theme_font_size_override("font_size", 24)
		b.add_theme_color_override("font_color", COLORS[i].lightened(0.3))
		b.pressed.connect(func(): _pull(idx))
		row.add_child(b)
		_buttons.append(b)


func autoplay() -> void:
	for i in 10:
		await get_tree().process_frame
	finish("win")


func _unhandled_input(event: InputEvent) -> void:
	if done or not event is InputEventKey or not event.pressed or event.echo:
		return
	var k: int = event.physical_keycode
	if k >= KEY_1 and k <= KEY_4:
		_pull(k - KEY_1)


func _pull(wire: int) -> void:
	if done or wire in _cut:
		return
	var expected: int = _order[_cut.size()]
	if _wire_tags[wire] == expected:
		_cut.append(wire)
		Sound.sfx("wire_cut", -2.0)
		(_buttons[wire] as Button).disabled = true
		if _cut.size() == 4:
			_info.text = Loc.pick({"fa": "چاشنی از کار افتاد.", "en": "The detonator is dead."})
			Sound.sfx("ui_good", -2.0)
			var tw := create_tween()
			tw.tween_interval(1.4)
			tw.tween_callback(func(): finish("win"))
	else:
		_left -= 8.0
		Sound.sfx("spark", 0.0)
		Film.shake(6.0, 0.3)
		Film.white_flash(0.15, Color(1.0, 0.85, 0.5))
		stage.fx.sparks(Vector2(640, 380), 20)


func _process(delta: float) -> void:
	if done or _cut.size() == 4:
		return
	_left -= delta
	if _left <= 0.0:
		Film.white_flash(0.6, Color(1, 0.6, 0.3))
		Film.shake(10.0, 0.6)
		Sound.sfx("ui_wrong", 0.0)
		_info.text = Loc.pick({"fa": "دیر شد... از اول.", "en": "Too slow... again."})
		_left = _limit
		_cut.clear()
		for b in _buttons:
			(b as Button).disabled = false
	_w.queue_redraw()


func _draw_bomb() -> void:
	var c := _w
	# The explosive drums behind the detonator.
	for i in 6:
		var p := Vector2(260 + i * 150, 330)
		c.draw_rect(Rect2(p - Vector2(50, 90), Vector2(100, 180)), Color(0.32, 0.34, 0.3))
		c.draw_rect(Rect2(p - Vector2(50, 20), Vector2(100, 14)), Color(0.85, 0.75, 0.2))
	var det := Rect2(560, 300, 160, 110)
	c.draw_rect(det.grow(4), Color(0, 0, 0))
	c.draw_rect(det, Color(0.14, 0.15, 0.14))
	var secs := maxi(0, int(ceil(_left)))
	Paint.text(c, det.position + Vector2(22, 70), "%02d:%02d" % [secs / 60, secs % 60], 44, Color(1.0, 0.2, 0.15), Loc.font_fa_black)
	for i in 4:
		var from := Vector2(det.position.x + 30 + i * 33, det.end.y)
		var to := Vector2(330 + i * 200, 590)
		var col: Color = COLORS[i]
		if i in _cut:
			c.draw_line(from, from + Vector2(0, 40), col, 6.0)
			c.draw_line(to, to - Vector2(0, 40), col, 6.0)
		else:
			var pts := PackedVector2Array()
			for k in 12:
				var tt := k / 11.0
				pts.append(from.lerp(to, tt) + Vector2(sin(tt * PI) * 40.0 * (1 if i % 2 == 0 else -1), sin(tt * PI) * 30.0))
			c.draw_polyline(pts, col, 6.0, true)
		c.draw_circle(to + Vector2(0, 26), 22, Color(0.95, 0.93, 0.85))
		_symbol(c, _wire_tags[i], to + Vector2(0, 26), 13.0, Color(0.1, 0.1, 0.1))
		Paint.text(c, to + Vector2(28, 36), str(i + 1), 24, Color.WHITE, Loc.font_fa_black)
	# The notebook page.
	var page := Rect2(1000, 120, 220, 170)
	c.draw_rect(page, Color(0.95, 0.93, 0.85))
	for i in 6:
		c.draw_line(Vector2(page.position.x, page.position.y + 30 + i * 22), Vector2(page.end.x, page.position.y + 30 + i * 22), Color(0.6, 0.7, 0.9, 0.5), 1.0)
	for i in 4:
		_symbol(c, _order[i], page.position + Vector2(36 + i * 50, 88), 15.0, Color(0.15, 0.1, 0.1) if i >= _cut.size() else Color(0.65, 0.65, 0.65))


func _symbol(c: CanvasItem, kind: int, at: Vector2, r: float, col: Color) -> void:
	match kind:
		0:
			c.draw_colored_polygon(PackedVector2Array([at + Vector2(0, -r), at + Vector2(r, r * 0.8), at + Vector2(-r, r * 0.8)]), col)
		1:
			c.draw_circle(at, r, col)
		2:
			c.draw_rect(Rect2(at - Vector2(r, r) * 0.85, Vector2(r, r) * 1.7), col)
		3:
			c.draw_colored_polygon(PackedVector2Array([at + Vector2(0, -r), at + Vector2(r, 0), at + Vector2(0, r), at + Vector2(-r, 0)]), col)
