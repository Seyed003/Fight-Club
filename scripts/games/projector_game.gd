extends GameModule
## The changeover. A family film runs on the screen; when the first
## cigarette burn flashes in the corner, start the second projector's
## motor; at the second burn, switch over. Do it for `reels` reels.

var _reels := 2
var _done_reels := 0
var _t := 0.0
var _cue_at := 0.0
var _cue := 0
var _window := 0.0
var _state := "running"
var _w: Control
var _info: Label
var _film_t := 0.0


func begin() -> void:
	_reels = kvi("reels", 2)
	_w = Control.new()
	UI.full(_w)
	_w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_w.draw.connect(_draw_screen)
	ui.add_child(_w)
	_info = hint_label(Loc.pick({"fa": "به گوشه‌ی بالا-راست تصویر نگاه کن. با اولین سوختگی سیگار Space را بزن تا موتور روشن شود؛ با دومی، دستگاه را عوض کن.",
		"en": "Watch the top-right corner. At the first cigarette burn press Space to start the motor; at the second, change over."}), 26.0, 20)
	_schedule()


func autoplay() -> void:
	for i in 10:
		await get_tree().process_frame
	finish("win")


func _schedule() -> void:
	_cue = 0
	_cue_at = _t + randf_range(3.0, 5.5)
	_state = "running"


func _process(delta: float) -> void:
	if done:
		return
	_t += delta
	_film_t += delta
	if _state == "running" and _t >= _cue_at:
		_state = "cue"
		_cue += 1
		_window = 0.9 if _cue == 1 else 0.6
		Film.cigarette_burn()
		Sound.sfx("film_burn", -6.0)
	elif _state == "cue":
		_window -= delta
		if _window <= 0.0:
			_miss()
	_w.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if done:
		return
	var pressed: bool = event.is_action_pressed("act") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not pressed:
		return
	if _state == "cue":
		Sound.sfx("cam_click", -2.0)
		if _cue == 1:
			_state = "running"
			_cue_at = _t + 1.6
			_info.text = Loc.pick({"fa": "موتور روشن شد. منتظر دومی باش...", "en": "Motor's running. Wait for the second..."})
		else:
			_done_reels += 1
			Sound.sfx("ui_good", -4.0)
			_info.text = Loc.pick({"fa": "عوض شد. تماشاگرها هیچ‌چیز نفهمیدند.", "en": "Changed over. Nobody in the audience noticed a thing."})
			if _done_reels >= _reels:
				_state = "done"
				var tw := create_tween()
				tw.tween_interval(1.4)
				tw.tween_callback(func(): finish("win"))
			else:
				_schedule()
	elif _state == "running":
		Sound.sfx("ui_wrong", -6.0)
		_info.text = Loc.pick({"fa": "زود بود. صبر کن تا علامت بیاید.", "en": "Too early. Wait for the mark."})


func _miss() -> void:
	Sound.sfx("ui_wrong", -2.0)
	Film.white_flash(0.4)
	_info.text = Loc.pick({"fa": "از دستش دادی؛ پرده سفید شد و تماشاگرها سوت زدند. دوباره.", "en": "Missed it. The screen went white and the audience booed. Again."})
	_schedule()


func _draw_screen() -> void:
	# The audience's view through the port window: a cheerful family film.
	var r := Rect2(120, 150, 520, 300)
	var c := _w
	c.draw_rect(r.grow(10), Color(0, 0, 0, 0.85))
	Paint.vgrad(c, r, Color(0.55, 0.75, 0.95), Color(0.75, 0.9, 0.7))
	var dog_x := r.position.x + fposmod(_film_t * 80.0, r.size.x + 120.0) - 60.0
	var hop := absf(sin(_film_t * 6.0)) * 20.0
	Paint.ellipse(c, Vector2(dog_x, r.end.y - 50 - hop), 34, 18, Color(0.7, 0.45, 0.25))
	Paint.ellipse(c, Vector2(dog_x + 30, r.end.y - 66 - hop), 14, 12, Color(0.7, 0.45, 0.25))
	c.draw_rect(Rect2(r.position.x, r.end.y - 40, r.size.x, 40), Color(0.35, 0.6, 0.3))
	Paint.circle(c, Vector2(r.end.x - 70, r.position.y + 60), 30, Color(1.0, 0.95, 0.6))
	if _state == "cue":
		Paint.circle(c, r.position + Vector2(r.size.x * 0.9, r.size.y * 0.12), 12, Color(0.95, 0.9, 0.75))
		c.draw_arc(r.position + Vector2(r.size.x * 0.9, r.size.y * 0.12), 14, 0, TAU, 20, Color(0.1, 0.05, 0.02), 3.0)
	for i in _reels:
		c.draw_circle(Vector2(140 + i * 30, 480), 10, Loc.SOAP if i < _done_reels else Color(1, 1, 1, 0.25))
