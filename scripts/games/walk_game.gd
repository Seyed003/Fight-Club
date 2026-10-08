extends GameModule
## Walk a character to a point: A/D or the arrow keys, or hold a finger on
## either half of the screen.
##   @game walk actor=jack to=980 speed=150

var _actor: Puppet
var _to := 900.0
var _speed := 150.0
var _t := 0.0


func begin() -> void:
	_actor = stage.get_actor(kvs("actor", "jack"))
	_to = kvf("to", 900.0)
	_speed = kvf("speed", 150.0)
	if _actor == null:
		finish("win")
		return
	var l := hint_label(prompt() if prompt() != "" else Loc.pick({"fa": "با A و D راه برو.", "en": "Walk with A and D."}), 30.0, 24)
	l.add_theme_color_override("font_color", Loc.PAPER)


func autoplay() -> void:
	for i in 5:
		await get_tree().process_frame
	if _actor != null:
		_actor.position.x = _to
	finish("win")


func _process(delta: float) -> void:
	if done or _actor == null:
		return
	_t += delta
	var dir := Input.get_axis("left", "right")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mx := get_viewport().get_mouse_position().x
		dir = 1.0 if mx > 640.0 else -1.0
	if absf(dir) > 0.1:
		_actor.position.x = clamp(_actor.position.x + dir * _speed * delta, 60.0, 1220.0)
		_actor.facing = 1 if dir > 0.0 else -1
		if _actor.anim != "walk":
			_actor.anim = "walk"
			_actor.set_pose("walk")
	elif _actor.anim == "walk":
		_actor.anim = ""
		_actor.set_pose("stand")
	if absf(_actor.position.x - _to) < 30.0:
		_actor.anim = ""
		_actor.set_pose("stand")
		finish("win")
