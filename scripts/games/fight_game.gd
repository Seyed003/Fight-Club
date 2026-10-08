extends GameModule
## A fight, launched from a screenplay:
##   @game fight a1=jack a2=bob l1=jack_fight l2=bob_fight ai=bob must_win
## Keys:
##   a1/a2     stage actor ids (created when missing), a1 is the player
##   l1/l2     looks to put on them for the fight
##   ai        opponent personality (see FightAI.PRESETS)
##   variant   standard | first_punch | spar | final
##   x1/x2     start positions; time= limit in seconds for spar
##   tapout=0  stop the opponent from tapping out

const TouchPad := preload("res://scripts/ui/touch_pad.gd")

const HINTS := [
	{"fa": "با A و D جلو و عقب برو.", "en": "Move with A and D."},
	{"fa": "J مشت سریع است. چند بار پشت سر هم بزن: ضربه‌ی سوم قلاب می‌شود.", "en": "J is a jab. Chain three: the third becomes a hook."},
	{"fa": "K مشت سنگین است. کندتر، ولی محکم‌تر.", "en": "K is a cross. Slower, harder."},
	{"fa": "I لگد است. از دور می‌رسد و از دفاع رد می‌شود.", "en": "I is a kick. Long reach, cuts through a guard."},
	{"fa": "Shift را نگه دار تا دفاع کنی.", "en": "Hold Shift to block."},
	{"fa": "O جاخالی می‌دهد.", "en": "O slips back out of reach."},
	{"fa": "وقتی نوار خشم پر شد، U را بزن.", "en": "When the rage bar is full, press U."},
]

var p1: Fighter
var p2: Fighter
var ai: FightAI
var variant := "standard"
var must_win := false
var allow_tapout := true
var time_limit := 0.0

var _t := 0.0
var _hitstop := 0.0
var _over := false
var _bars: Control
var _msg: Label
var _help: Label
var _combo: Label
var _cam_label: Label
var _trail1 := 1.0
var _trail2 := 1.0
var _pad: Control
var _hint_i := -1
var _cam_on := false
var _cam_next := 6.0
var _tap_t := 0.0
var _demo_ai: FightAI


func begin() -> void:
	variant = kvs("variant", "standard")
	must_win = kv.has("must_win") or step.get("args", []).has("must_win")
	allow_tapout = kvs("tapout", "1") != "0"
	time_limit = kvf("time", 0.0)
	var preset := kvs("ai", "member")
	ai = FightAI.new(preset)
	var pup1 := _puppet(kvs("a1", "jack"), kvs("l1", "jack_fight"), kvf("x1", 430.0))
	var pup2 := _puppet(kvs("a2", "opp"), kvs("l2", "member1"), kvf("x2", 850.0))
	p1 = Fighter.new(pup1, pup1.who, 100.0)
	p1.is_player = true
	p2 = Fighter.new(pup2, pup2.who, float(ai.p["hp"]))
	p2.speed = ai.p["speed"]
	p2.power = ai.p["power"]
	p2.toughness = ai.p.get("tough", 1.0)
	if Settings.story_mode:
		p2.power *= 0.55
		p1.power *= 1.4
		p1.toughness = 1.3
	for f in [p1, p2]:
		f.fx = stage.fx
		f.hit_landed.connect(_on_hit)
		f.knocked_out.connect(_on_ko)
	match variant:
		"first_punch":
			ai.passive = true
			p2.puppet.set_pose("taunt")
			p2.puppet.anim = ""
		"spar":
			if time_limit <= 0.0:
				time_limit = 40.0
			p1.can_die = false
			p2.can_die = false
		"final":
			p1.can_die = false
			p2.can_die = false
	if kv.has("demo"):
		_demo_ai = FightAI.new("angel")
	_build_hud()
	stage.move_camera(Vector2(640, 380), 1.08, 0.6)
	Sound.sfx("crowd_cheer", -6.0)
	_flash_message({"fa": "مبارزه!", "en": "FIGHT!"}, 1.0)
	if variant == "first_punch":
		_help.text = Loc.pick({"fa": "J یا K را بزن. هر جا که شد.", "en": "Press J or K. Anywhere you like."})


func autoplay() -> void:
	for i in 30:
		await get_tree().process_frame
	if not done:
		finish("win")


func _puppet(id: String, look: String, x: float) -> Puppet:
	var p := stage.get_actor(id)
	if p == null:
		p = stage.add_actor(id, look)
		p.scale = Vector2.ONE
	elif kv.has("l1") and id == kvs("a1", "jack") or kv.has("l2") and id == kvs("a2", "opp"):
		p.set_look(look)
	p.position = Vector2(x, stage.floor_y())
	p.alpha = 1.0
	p.prop = ""
	return p


func _build_hud() -> void:
	_bars = Control.new()
	UI.full(_bars)
	_bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bars.draw.connect(_draw_bars)
	ui.add_child(_bars)
	for i in 2:
		var l := Label.new()
		l.theme_type_variation = "Name"
		l.text = Cast.display_name((p1 if i == 0 else p2).who)
		l.position = Vector2(60, 12) if i == 0 else Vector2(760, 12)
		l.size = Vector2(460, 30)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		l.add_theme_color_override("font_color", Cast.name_color((p1 if i == 0 else p2).who))
		ui.add_child(l)
	_msg = Label.new()
	_msg.theme_type_variation = "Title"
	_msg.position = Vector2(0, 250)
	_msg.size = Vector2(1280, 120)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_msg.add_theme_constant_override("outline_size", 12)
	_msg.modulate.a = 0.0
	ui.add_child(_msg)
	_combo = Label.new()
	_combo.theme_type_variation = "Heading"
	_combo.position = Vector2(60, 96)
	_combo.size = Vector2(400, 50)
	_combo.add_theme_color_override("font_color", Loc.SOAP)
	_combo.modulate.a = 0.0
	ui.add_child(_combo)
	_help = Label.new()
	_help.theme_type_variation = "Small"
	_help.position = Vector2(40, 688)
	_help.size = Vector2(1200, 28)
	_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_help.text = Loc.t("fight_help")
	ui.add_child(_help)
	_cam_label = Label.new()
	_cam_label.theme_type_variation = "Heading"
	_cam_label.position = Vector2(110, 110)
	_cam_label.size = Vector2(600, 50)
	_cam_label.add_theme_font_override("font", Loc.font_en)
	_cam_label.visible = false
	ui.add_child(_cam_label)
	if TouchPad.wanted():
		_pad = TouchPad.new()
		ui.add_child(_pad)
		_pad.fight_layout()
		_help.visible = false


func _player_input() -> Dictionary:
	if _over:
		return {"move": 0.0}
	if _demo_ai != null:
		return _demo_ai.input(p1, p2, get_process_delta_time())
	return {
		"move": Input.get_axis("left", "right"),
		"jab": Input.is_action_just_pressed("jab"),
		"cross": Input.is_action_just_pressed("cross"),
		"kick": Input.is_action_just_pressed("kick"),
		"block": Input.is_action_pressed("block"),
		"dodge": Input.is_action_just_pressed("dodge"),
		"special": Input.is_action_just_pressed("special"),
	}


func _process(delta: float) -> void:
	if done or p1 == null:
		return
	_t += delta
	_bars.queue_redraw()
	_trail1 = move_toward(_trail1, p1.hp / p1.max_hp, delta * 0.35)
	_trail2 = move_toward(_trail2, p2.hp / p2.max_hp, delta * 0.35)
	if _hitstop > 0.0:
		_hitstop -= delta
		return
	var in1 := _player_input()
	var in2 := ai.input(p2, p1, delta) if not _over else {"move": 0.0}
	p1.update(delta, p2, in1)
	p2.update(delta, p1, in2)
	_separate()
	_follow_camera(delta)
	if _over:
		return
	match variant:
		"spar":
			_tick_hints()
			if _t >= time_limit or p1.hp < p1.max_hp * 0.3 or p2.hp < p2.max_hp * 0.3:
				_end("win", {"fa": "کافیه...", "en": "Enough..."})
		"final":
			_tick_final(delta)
	if variant == "standard" and allow_tapout and p2.alive() and p2.hp < p2.max_hp * 0.13:
		_tap_t += delta
		if _tap_t > 0.6 and randf() < delta * 1.2:
			p2.tap_out()


func _separate() -> void:
	var min_d := (40.0 * p1.puppet.girth() + 40.0 * p2.puppet.girth()) * p1.puppet.scale.x
	var d := p2.x - p1.x
	if absf(d) < min_d and p1.alive() and p2.alive():
		var push := (min_d - absf(d)) * 0.5 * (1.0 if d >= 0.0 else -1.0)
		p1.x = clamp(p1.x - push, p1.min_x, p1.max_x)
		p2.x = clamp(p2.x + push, p2.min_x, p2.max_x)
		p1.puppet.position.x = p1.x
		p2.puppet.position.x = p2.x


func _follow_camera(delta: float) -> void:
	var z := 1.08
	var half := 640.0 / z
	var mid := clampf((p1.x + p2.x) * 0.5, half, 1280.0 - half)
	stage.camera.position.x = lerpf(stage.camera.position.x, mid, 1.0 - exp(-3.0 * delta))


func _on_hit(attacker: Fighter, target: Fighter, dmg: float, blocked: bool) -> void:
	if blocked:
		_hitstop = 0.03
		return
	_hitstop = 0.05 if dmg < 10.0 else 0.1
	Film.shake(4.0 + dmg * 0.6, 0.25)
	if target == p1:
		Film.red_flash(0.35 + dmg * 0.03)
	if dmg > 15.0:
		Film.white_flash(0.18)
	if "excite" in stage.loc:
		stage.loc.set("excite", clamp(float(stage.loc.get("excite")) + dmg * 0.02, 0.3, 1.0))
	if randf() < 0.25 or dmg > 11.0:
		Sound.sfx("crowd_cheer", -10.0 + dmg * 0.3)
	if attacker == p1 and attacker.combo >= 2:
		_combo.text = Loc.pick({"fa": "%s ضربه!", "en": "%s hits!"}) % Loc.num(attacker.combo + 1)
		_combo.modulate.a = 1.0
		create_tween().tween_property(_combo, "modulate:a", 0.0, 0.9).set_delay(0.4)
	if variant == "first_punch" and attacker == p1:
		_end("win", {}, 0.6)
	if variant == "final" and attacker == p1:
		# Every blow lands on the narrator too.
		p1.hp = max(1.0, p1.hp - dmg * 0.4)
		p1.puppet.bruise = clamp(p1.puppet.bruise + 0.03, 0.0, 1.0)
		p1.puppet.blood = clamp(p1.puppet.blood + 0.025, 0.0, 1.0)
		stage.fx.blood(p1.puppet.point("head"), Vector2(-p1.facing, -0.3), 4)


func _on_ko(f: Fighter) -> void:
	if _over:
		return
	if f == p2:
		var tapped := f.puppet.target_name == "kneel_down"
		_end("win", {"fa": Loc.S["tapped_out"]["fa"], "en": Loc.S["tapped_out"]["en"]} if tapped else {"fa": Loc.S["ko"]["fa"], "en": Loc.S["ko"]["en"]})
	else:
		_end("lose", {"fa": Loc.S["you_lost"]["fa"], "en": Loc.S["you_lost"]["en"]})


func _tick_hints() -> void:
	var i := int(_t / 5.5)
	if i != _hint_i and i < HINTS.size():
		_hint_i = i
		bark("", HINTS[i], 4.6)


func _tick_final(delta: float) -> void:
	_cam_next -= delta
	if not _cam_on and _cam_next <= 0.0:
		_cam_on = true
		_cam_next = 1.8
		Film.set_grade("cam")
		Sound.sfx("cam_click", -6.0)
		p2.puppet.alpha = 0.0
		_cam_label.visible = true
	elif _cam_on:
		_cam_label.text = "CAM 04  P2 GARAGE   ● REC  %02d:%02d:%02d" % [23, 41 + int(_t / 60.0), int(_t) % 60]
		if _cam_next <= 0.0:
			_cam_on = false
			_cam_next = randf_range(5.0, 8.0)
			Film.set_grade(stage.loc.grade)
			p2.puppet.alpha = 1.0
			_cam_label.visible = false
	if p1.hp <= 14.0 or _t > 80.0:
		_end("lose", {}, 0.4)
	elif p2.hp <= 2.0:
		_end("win", {}, 0.4)


func _flash_message(pair: Dictionary, time := 1.6) -> void:
	_msg.text = Loc.pick(pair)
	_msg.modulate.a = 1.0
	_msg.scale = Vector2.ONE
	var tw := create_tween()
	tw.tween_interval(time)
	tw.tween_property(_msg, "modulate:a", 0.0, 0.5)


func _end(result: String, pair: Dictionary, delay := 2.4) -> void:
	if _over:
		return
	_over = true
	if _cam_on:
		Film.set_grade(stage.loc.grade)
		p2.puppet.alpha = 1.0
		_cam_label.visible = false
	if not pair.is_empty():
		_flash_message(pair, delay)
		Sound.sfx("crowd_cheer", -2.0)
	var tw := create_tween()
	tw.tween_interval(delay)
	await tw.finished
	if result == "lose" and must_win:
		_offer_retry()
		return
	_cleanup()
	finish(result)


func _offer_retry() -> void:
	var v := UI.vbox(12)
	v.custom_minimum_size = Vector2(360, 0)
	var holder := UI.center(v)
	ui.add_child(holder)
	v.add_child(UI.label("you_lost", "Heading", HORIZONTAL_ALIGNMENT_CENTER))
	var retry := UI.button("retry", func():
		holder.queue_free()
		_restart(), "BigButton")
	v.add_child(retry)
	v.add_child(UI.button("continue_story", func():
		_cleanup()
		finish("lose"), "BigButton"))
	retry.grab_focus.call_deferred()


func _restart() -> void:
	_over = false
	_t = 0.0
	for f in [p1, p2]:
		f.hp = f.max_hp
		f.state = "idle"
		f.rage = 0.0
		f.vx = 0.0
		f.puppet.set_pose("guard")
		f.puppet.anim = "bounce"
	p1.x = kvf("x1", 430.0)
	p2.x = kvf("x2", 850.0)
	p1.puppet.bruise = 0.2
	p1.puppet.blood = 0.1
	_flash_message({"fa": "دوباره!", "en": "Again!"}, 0.8)


func _cleanup() -> void:
	stage.move_camera(Vector2(640, 360), 1.0, 0.6)
	for f in [p1, p2]:
		f.puppet.anim = ""
		f.puppet.alpha = 1.0


func _draw_bars() -> void:
	var c := _bars
	var bw := 460.0
	for i in 2:
		var f: Fighter = p1 if i == 0 else p2
		var trail := _trail1 if i == 0 else _trail2
		var frac: float = clamp(f.hp / f.max_hp, 0.0, 1.0)
		var r := Rect2(60, 44, bw, 16) if i == 0 else Rect2(760, 44, bw, 16)
		c.draw_rect(r.grow(3), Color(0, 0, 0, 0.75))
		c.draw_rect(r, Color(0.16, 0.05, 0.05))
		var tr := r
		tr.size.x = bw * trail
		if i == 1:
			tr.position.x = r.end.x - tr.size.x
		c.draw_rect(tr, Color(0.92, 0.88, 0.8, 0.7))
		var fr := r
		fr.size.x = bw * frac
		if i == 1:
			fr.position.x = r.end.x - fr.size.x
		c.draw_rect(fr, Color(0.78, 0.12, 0.10).lerp(Color(0.9, 0.7, 0.3), frac * 0.4))
	var rr := Rect2(60, 66, 220, 7)
	c.draw_rect(rr.grow(2), Color(0, 0, 0, 0.7))
	var rage_frac := p1.rage / 100.0
	var rc := Loc.SOAP if p1.rage < 100.0 else Color(1, 1, 1).lerp(Loc.SOAP, 0.5 + 0.5 * sin(_t * 12.0))
	c.draw_rect(Rect2(rr.position, Vector2(rr.size.x * rage_frac, rr.size.y)), rc)
	if variant == "spar" and time_limit > 0.0:
		var left: float = max(0.0, time_limit - _t)
		c.draw_rect(Rect2(560, 40, 160 * left / time_limit, 4), Color(Loc.PAPER, 0.5))
