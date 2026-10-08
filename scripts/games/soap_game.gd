extends GameModule
## Making soap in the Paper Street kitchen, in three steps:
## render the fat (keep the heat in the band), pour the lye (stop on the
## line), and pick a scent. Ends with a tray of pink bars.

var _phase := 0
var _t := 0.0
var _heat := 0.3
var _progress := 0.0
var _pour := 0.0
var _pouring := false
var _scent := ""
var _w: Control
var _title: Label
var _sub: Label
var _choice_box: HBoxContainer


func begin() -> void:
	_w = Control.new()
	UI.full(_w)
	_w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_w.draw.connect(_draw_widget)
	ui.add_child(_w)
	_title = hint_label("", 30.0, 28)
	_sub = hint_label("", 74.0, 20)
	_sub.add_theme_color_override("font_color", Loc.SOAP)
	_enter(0)


func autoplay() -> void:
	for i in 10:
		await get_tree().process_frame
	_scent = "rose"
	Settings.set_flag("soap_scent", _scent)
	finish("win")


func _enter(p: int) -> void:
	_phase = p
	_t = 0.0
	match p:
		0:
			_title.text = Loc.pick({"fa": "۱. چربی را آب کن", "en": "1. Render the fat"})
			_sub.text = Loc.pick({"fa": "Space را نگه دار تا حرارت بالا برود، رها کن تا پایین بیاید. عقربه را در نوار سبز نگه دار.",
				"en": "Hold Space to raise the heat, let go to lower it. Keep the needle in the green band."})
		1:
			_title.text = Loc.pick({"fa": "۲. سود سوزآور را بریز", "en": "2. Pour the lye"})
			_sub.text = Loc.pick({"fa": "Space را نگه دار تا بریزی. درست روی خط رها کن. زیادش پوست را می‌سوزاند.",
				"en": "Hold Space to pour. Let go right on the line. Too much burns the skin."})
			_pour = 0.0
		2:
			_title.text = Loc.pick({"fa": "۳. عطر را انتخاب کن", "en": "3. Choose a scent"})
			_sub.text = ""
			_show_scents()


func _holding() -> bool:
	return Input.is_action_pressed("act") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _process(delta: float) -> void:
	if done:
		return
	_t += delta
	match _phase:
		0:
			_heat += (0.42 if _holding() else -0.32) * delta
			_heat += sin(_t * 1.7) * 0.05 * delta
			_heat = clamp(_heat, 0.0, 1.0)
			var in_band := _heat > 0.55 and _heat < 0.75
			_progress += (delta / 6.0) if in_band else -delta / 20.0
			_progress = clamp(_progress, 0.0, 1.0)
			if _heat > 0.92 and randf() < delta * 3.0:
				Film.shake(3.0, 0.2)
				Sound.sfx("sizzle", -8.0)
			if _progress >= 1.0:
				Sound.sfx("ui_good", -4.0)
				_enter(1)
		1:
			if _holding():
				_pouring = true
				_pour += delta * 0.32
				if randf() < delta * 6.0:
					Sound.sfx("pour", -12.0)
				if _pour > 0.86:
					Sound.sfx("ui_wrong", -2.0)
					Film.shake(5.0, 0.3)
					_sub.text = Loc.pick({"fa": "زیادی ریختی. دوباره.", "en": "Too much. Again."})
					_pour = 0.0
					_pouring = false
			elif _pouring:
				_pouring = false
				if absf(_pour - 0.7) < 0.06:
					Sound.sfx("ui_good", -4.0)
					_enter(2)
				else:
					_sub.text = Loc.pick({"fa": "کم ریختی. ادامه بده.", "en": "Not enough. Keep going."})
	_w.queue_redraw()


func _show_scents() -> void:
	_choice_box = UI.hbox(14)
	_choice_box.position = Vector2(340, 560)
	ui.add_child(_choice_box)
	var options := [["rose", {"fa": "گل سرخ", "en": "Rose"}], ["lavender", {"fa": "اسطوخودوس", "en": "Lavender"}],
		["none", {"fa": "بی‌عطر", "en": "Unscented"}]]
	for o in options:
		var id: String = o[0]
		var b := UI.button(o[1], func():
			_scent = id
			Settings.set_flag("soap_scent", id)
			Sound.sfx("ui_good", -4.0)
			_choice_box.queue_free()
			_phase = 3
			_title.text = Loc.pick({"fa": "صابون آماده است.", "en": "The soap is ready."})
			var tw := create_tween()
			tw.tween_interval(1.8)
			tw.tween_callback(func(): finish("win")), "BigButton")
		b.custom_minimum_size = Vector2(190, 56)
		_choice_box.add_child(b)


func _draw_widget() -> void:
	var c := _w
	match _phase:
		0:
			var r := Rect2(390, 600, 500, 30)
			c.draw_rect(r.grow(4), Color(0, 0, 0, 0.75))
			c.draw_rect(r, Color(0.15, 0.13, 0.12))
			c.draw_rect(Rect2(r.position.x + r.size.x * 0.55, r.position.y, r.size.x * 0.2, r.size.y), Color(0.3, 0.7, 0.35, 0.8))
			c.draw_rect(Rect2(r.position.x + r.size.x * 0.88, r.position.y, r.size.x * 0.12, r.size.y), Color(0.8, 0.2, 0.15, 0.7))
			var nx := r.position.x + r.size.x * _heat
			c.draw_line(Vector2(nx, r.position.y - 10), Vector2(nx, r.end.y + 10), Color.WHITE, 4.0)
			c.draw_rect(Rect2(r.position.x, r.end.y + 12, r.size.x * _progress, 6), Loc.SOAP)
			Paint.text(c, Vector2(r.position.x - 70, r.end.y - 6), Loc.t("heat"), 18, Loc.PAPER, Loc.body_font())
		1:
			var jar := Rect2(590, 360, 100, 240)
			c.draw_rect(jar.grow(4), Color(0.85, 0.9, 0.95, 0.5))
			c.draw_rect(jar, Color(0.1, 0.12, 0.14, 0.8))
			var level := jar.size.y * _pour
			c.draw_rect(Rect2(jar.position.x, jar.end.y - level, jar.size.x, level), Color(0.94, 0.66, 0.72))
			var line_y := jar.end.y - jar.size.y * 0.7
			c.draw_line(Vector2(jar.position.x - 30, line_y), Vector2(jar.end.x + 30, line_y), Color(1, 1, 1, 0.9), 3.0)
			if _pouring:
				c.draw_line(Vector2(640, 300), Vector2(640, jar.end.y - level), Color(0.95, 0.95, 0.9, 0.8), 6.0)
		3:
			for i in 6:
				var p := Vector2(470 + (i % 3) * 120, 520 + (i / 3) * 70)
				var col := Color(0.95, 0.66, 0.74)
				if _scent == "lavender":
					col = Color(0.8, 0.7, 0.92)
				elif _scent == "none":
					col = Color(0.95, 0.9, 0.84)
				c.draw_rect(Rect2(p, Vector2(100, 52)), col.darkened(0.2))
				c.draw_rect(Rect2(p + Vector2(4, 4), Vector2(92, 40)), col)
