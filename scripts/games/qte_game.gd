extends GameModule
## Quick-time moments, launched with `@qte <mode> ...` and a fa/en prompt.
##   mash    press Space (or tap) fast enough to fill the meter
##   hold    keep Space held through the pain
##   timing  press when the needle is inside the marked zone
##   resist  don't press anything until the time runs out
## Keys:
##   time=   seconds (mash, hold, resist) or seconds per pass (timing)
##   target= presses needed (mash), hits needed (timing)
##   actor=  who reacts; pose_a/pose_b alternate on each press
##   victim= who gets hurt on each press; blood=/bruise= per press
##   sfx=    sound per press; zone= timing zone width (0..1)
##   fails=  failures before the moment simply plays out (default 3)

var mode := "mash"
var _t := 0.0
var _limit := 6.0
var _meter := 0.0
var _hits := 0
var _target := 20
var _fails := 0
var _max_fails := 3
var _needle := 0.0
var _needle_dir := 1.0
var _zone := Vector2(0.62, 0.8)
var _flash := 0.0
var _released := 0.0
var _toggle := false
var _w: Control
var _prompt: Label
var _sub: Label
var _ended := false


func begin() -> void:
	var a: Array = step.get("args", [])
	mode = a[0] if a.size() > 0 else "mash"
	_max_fails = kvi("fails", 3)
	match mode:
		"mash":
			_limit = kvf("time", 6.0)
			_target = kvi("target", 22)
		"hold":
			_limit = kvf("time", 5.0)
		"timing":
			_limit = kvf("time", 1.4)
			_target = kvi("target", 3)
			_new_zone()
		"resist":
			_limit = kvf("time", 5.0)
	_w = Control.new()
	UI.full(_w)
	_w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_w.draw.connect(_draw_widget)
	ui.add_child(_w)
	_prompt = hint_label(prompt(), 40.0, 30)
	_prompt.add_theme_color_override("font_color", Loc.PAPER)
	var how := ""
	match mode:
		"mash":
			how = Loc.t("tap_fast")
		"hold":
			how = Loc.t("hold_space")
		"timing":
			how = Loc.t("press_space")
		"resist":
			how = Loc.t("dont_touch")
	_sub = hint_label(how, 498.0, 22)
	_sub.add_theme_color_override("font_color", Loc.SOAP)
	var actor := _actor()
	if actor != null and kv.has("pose_a"):
		actor.set_pose(kv["pose_a"], 14.0)
	if mode == "hold" and actor != null:
		actor.anim = "shiver"


func autoplay() -> void:
	for i in 15:
		await get_tree().process_frame
	_finish_ok()


func _actor() -> Puppet:
	return stage.get_actor(kv["actor"]) if kv.has("actor") else null


func _victim() -> Puppet:
	return stage.get_actor(kv["victim"]) if kv.has("victim") else null


func _new_zone() -> void:
	var width := kvf("zone", 0.16)
	var start := randf_range(0.25, 0.92 - width)
	_zone = Vector2(start, start + width)


func _unhandled_input(event: InputEvent) -> void:
	if done or _ended:
		return
	var pressed: bool = event.is_action_pressed("act") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not pressed or event.is_echo():
		return
	match mode:
		"mash":
			_meter += 1.0 / float(_target)
			_flash = 1.0
			_react()
			if _meter >= 1.0:
				_finish_ok()
		"timing":
			if _needle >= _zone.x and _needle <= _zone.y:
				_hits += 1
				_flash = 1.0
				_react()
				_new_zone()
				if _hits >= _target:
					_finish_ok()
			else:
				Sound.sfx("ui_wrong", -4.0)
				_hits = maxi(0, _hits - 1)
				Film.shake(4.0, 0.2)
		"resist":
			_t = 0.0
			Film.shake(3.0, 0.15)
			_flash = 1.0
			Sound.sfx("ui_wrong", -8.0)


func _react() -> void:
	var actor := _actor()
	if actor != null and kv.has("pose_b"):
		_toggle = not _toggle
		actor.set_pose(kv["pose_b"] if _toggle else kv.get("pose_a", "stand"), 30.0)
	var victim := _victim()
	if victim != null:
		victim.bruise = clamp(victim.bruise + kvf("bruise", 0.03), 0.0, 1.0)
		victim.blood = clamp(victim.blood + kvf("blood", 0.03), 0.0, 1.0)
		stage.fx.blood(victim.point("head"), Vector2(randf_range(-1, 1), -0.5), 5, 0.8)
	if kv.has("sfx"):
		Sound.sfx(kv["sfx"], -2.0)
	if kv.has("shake"):
		Film.shake(kvf("shake", 5.0), 0.2)


func _process(delta: float) -> void:
	if done or _ended:
		return
	_t += delta
	_flash = max(0.0, _flash - delta * 4.0)
	match mode:
		"mash":
			_meter = max(0.0, _meter - delta * kvf("decay", 0.12))
			if _t >= _limit:
				_fail()
		"hold":
			var holding := Input.is_action_pressed("act") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
			if holding:
				_meter += delta / _limit
				_released = 0.0
				if randf() < delta * 4.0:
					Film.shake(2.0 + _meter * 6.0, 0.15)
				if kv.has("sfx") and randf() < delta * 1.5:
					Sound.sfx(kv["sfx"], -8.0)
				if _meter >= 1.0:
					_finish_ok()
			else:
				_released += delta
				_meter = max(0.0, _meter - delta * 0.25)
				if _released > 1.2 and _meter > 0.05:
					_fail()
		"timing":
			_needle += _needle_dir * delta / _limit
			if _needle >= 1.0:
				_needle = 1.0
				_needle_dir = -1.0
			elif _needle <= 0.0:
				_needle = 0.0
				_needle_dir = 1.0
		"resist":
			_meter = _t / _limit
			if _t >= _limit:
				_finish_ok()
	_w.queue_redraw()


func _fail() -> void:
	_fails += 1
	if _fails >= _max_fails:
		_finish_ok()
		return
	Sound.sfx("ui_wrong", -2.0)
	_sub.text = Loc.t("failed")
	_t = 0.0
	_meter = 0.0
	_hits = 0
	_released = 0.0


func _finish_ok() -> void:
	if _ended:
		return
	_ended = true
	var actor := _actor()
	if actor != null and mode == "hold":
		actor.anim = ""
	_sub.text = Loc.t("success")
	Sound.sfx("ui_good", -4.0)
	var tw := create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(func(): finish("win"))


func _draw_widget() -> void:
	var c := _w
	var center := Vector2(640, 600)
	match mode:
		"mash", "hold", "resist":
			var r := Rect2(center.x - 300, center.y - 14, 600, 28)
			c.draw_rect(r.grow(4), Color(0, 0, 0, 0.7))
			c.draw_rect(r, Color(0.15, 0.12, 0.12))
			var fill := r
			fill.size.x = r.size.x * clamp(_meter, 0.0, 1.0)
			var col := Loc.SOAP.lerp(Color.WHITE, _flash * 0.6)
			if mode == "hold":
				col = Color(0.95, 0.55, 0.2).lerp(Color(1, 0.95, 0.8), _flash)
			elif mode == "resist":
				col = Color(0.6, 0.75, 0.7)
			c.draw_rect(fill, col)
			if mode == "mash":
				var left: float = clamp(1.0 - _t / _limit, 0.0, 1.0)
				c.draw_rect(Rect2(r.position.x, r.end.y + 10, r.size.x * left, 4), Color(Loc.PAPER, 0.6))
		"timing":
			var r := Rect2(center.x - 320, center.y - 18, 640, 36)
			c.draw_rect(r.grow(4), Color(0, 0, 0, 0.7))
			c.draw_rect(r, Color(0.14, 0.13, 0.12))
			var zr := Rect2(r.position.x + r.size.x * _zone.x, r.position.y, r.size.x * (_zone.y - _zone.x), r.size.y)
			c.draw_rect(zr, Color(Loc.SOAP, 0.55 + _flash * 0.4))
			var nx := r.position.x + r.size.x * _needle
			c.draw_line(Vector2(nx, r.position.y - 10), Vector2(nx, r.end.y + 10), Color.WHITE, 4.0)
			for i in _target:
				var dot := Vector2(center.x - (_target - 1) * 14 + i * 28, r.end.y + 26)
				c.draw_circle(dot, 8, Loc.SOAP if i < _hits else Color(1, 1, 1, 0.2))
