extends Node
## Plays one chapter: reads its screenplay and runs it step by step on a
## Stage, with the subtitle box, choices, title cards and playable
## segments. Waits use this node's own signals and tweens, so leaving the
## chapter (freeing this node) cleanly abandons whatever was in progress.

signal ticked

const DialogueBox := preload("res://scripts/ui/dialogue_box.gd")
const ChoiceBox := preload("res://scripts/ui/choice_box.gd")
const PauseMenu := preload("res://scripts/ui/pause_menu.gd")
const LogPanel := preload("res://scripts/ui/log_panel.gd")
const GAMES_PATH := "res://scripts/games/%s_game.gd"

var chapter_index := 0
var chapter_file := ""
var script_data: StoryScript
var stage: Stage
var ui_layer: CanvasLayer
var ui: Control
var dialogue: Control
var choices: Control
var last_result := ""
var history: Array = []
var skipping := false
var auto := false

var _pc := 0
var _dt := 0.0
var _dark := true
var _advance := false
var _game: GameModule
var _overlay_layer: CanvasLayer
var _menu_layer: CanvasLayer
var _hud: HBoxContainer
var _auto_btn: Button
var _skip_btn: Button
var _caption: Label
var _bark: Label
var _menu_open := false
var _speaking: Puppet


func _ready() -> void:
	stage = Stage.new()
	add_child(stage)
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	ui = UI.root()
	ui_layer.add_child(ui)
	dialogue = DialogueBox.new()
	ui.add_child(dialogue)
	choices = ChoiceBox.new()
	ui.add_child(choices)
	_build_hud()
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 106
	add_child(_overlay_layer)
	_menu_layer = CanvasLayer.new()
	_menu_layer.layer = 125
	_menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_menu_layer)
	script_data = StoryScript.load_file(chapter_file)
	for e in script_data.errors:
		push_warning("%s: %s" % [chapter_file.get_file(), e])
	Film.black()
	_run.call_deferred()


func _build_hud() -> void:
	_hud = UI.hbox(8)
	_hud.position = Vector2(860, 14)
	_hud.size = Vector2(406, 36)
	_hud.alignment = BoxContainer.ALIGNMENT_END
	ui.add_child(_hud)
	_hud.add_child(UI.button("log", _open_log, "HudButton"))
	_auto_btn = UI.button("auto", func(): auto = _auto_btn.button_pressed, "HudButton")
	_auto_btn.toggle_mode = true
	_hud.add_child(_auto_btn)
	_skip_btn = UI.button("skip", func(): skipping = _skip_btn.button_pressed, "HudButton")
	_skip_btn.toggle_mode = true
	_hud.add_child(_skip_btn)
	_hud.add_child(UI.button("menu", _open_pause, "HudButton"))
	for b in _hud.get_children():
		(b as Button).focus_mode = Control.FOCUS_NONE
	_caption = Label.new()
	_caption.theme_type_variation = "Caption"
	_caption.position = Vector2(40, 22)
	_caption.size = Vector2(760, 40)
	_caption.modulate.a = 0.0
	ui.add_child(_caption)
	_bark = Label.new()
	_bark.theme_type_variation = "Line"
	_bark.position = Vector2(140, 600)
	_bark.size = Vector2(1000, 90)
	_bark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bark.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bark.modulate.a = 0.0
	ui.add_child(_bark)


func _process(delta: float) -> void:
	_dt = delta
	if _speaking != null and is_instance_valid(_speaking):
		_speaking.talking = dialogue.typing or Sound.voice_playing()
	ticked.emit()


func _unhandled_input(event: InputEvent) -> void:
	if _menu_open:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_open_pause()
		return
	if event.is_action_pressed("log"):
		_open_log()
		return
	if event.is_action_pressed("advance") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_advance = true


# --- Running -------------------------------------------------------------

func _run() -> void:
	_pc = 0
	var steps: Array = script_data.steps
	while _pc < steps.size():
		var step: Dictionary = steps[_pc]
		_pc += 1
		if Game.autoplay:
			print("[%s:%d] %s" % [script_data.chapter_id, step.get("line", 0), step.get("cmd", "")])
		if step["cmd"] == "end":
			break
		await _exec(step)
	await _finish()


func _finish() -> void:
	dialogue.hide_box()
	await _fade_to(1.0, 1.2)
	Sound.stop_ambience()
	var pair := {"fa": Loc.S["chapter_done"]["fa"], "en": Loc.S["chapter_done"]["en"]}
	await _show_card(pair, false, 2.0)
	Game.chapter_finished(chapter_index)


func _jump(label: String) -> void:
	if script_data.labels.has(label):
		_pc = script_data.labels[label]
	else:
		push_warning("Story: unknown label %s" % label)


func _sleep(sec: float) -> void:
	var left := sec
	while left > 0.0:
		await ticked
		if Game.autoplay:
			return
		left -= _dt * (10.0 if _is_skipping() else 1.0)


func _is_skipping() -> bool:
	return skipping or Input.is_action_pressed("skip")


func _fade_to(alpha: float, time: float) -> void:
	var rect := Film.fade_rect()
	if Game.autoplay or _is_skipping():
		time = min(time, 0.05)
	if is_equal_approx(rect.color.a, alpha):
		_dark = alpha > 0.5
		return
	var tw := create_tween()
	tw.tween_property(rect, "color:a", alpha, max(time, 0.01))
	await tw.finished
	_dark = alpha > 0.5


func _flush_fade() -> void:
	if _dark:
		await _fade_to(0.0, 0.8)


func _wait_advance(has_voice := false) -> void:
	_advance = false
	var waited := 0.0
	while true:
		await ticked
		waited += _dt
		if Game.autoplay:
			dialogue.complete()
			return
		if _is_skipping():
			dialogue.complete()
			if waited > 0.07:
				return
			continue
		if _advance:
			_advance = false
			if dialogue.typing:
				dialogue.complete()
			else:
				Sound.stop_voice()
				return
		if auto and not dialogue.typing:
			if has_voice and Sound.voice_playing():
				waited = 0.0
				continue
			if waited > 1.2 + dialogue.text_length() * 0.04 / Settings.text_speed:
				return
		elif dialogue.typing:
			waited = 0.0


func _exec(step: Dictionary) -> void:
	var cmd: String = step["cmd"]
	var a: Array = step.get("args", [])
	var kv: Dictionary = step.get("kv", {})
	match cmd:
		"say":
			await _say(step)
		"scene":
			dialogue.hide_box()
			if not _dark:
				await _fade_to(1.0, float(kv.get("fade", 0.7)))
			if not a.has("keep"):
				stage.clear_actors()
			stage.set_location(a[0] if a.size() > 0 else "black")
			if kv.has("music"):
				Sound.play_music(kv["music"])
		"cut":
			if not a.has("keep"):
				stage.clear_actors()
			stage.set_location(a[0] if a.size() > 0 else "black")
		"actor":
			_actor(a[0], kv)
		"remove":
			for id in a:
				stage.remove_actor(id)
		"clear":
			stage.clear_actors()
		"move":
			await _move(a[0], kv, a.has("wait"), a.has("run"), a.has("slide"))
		"pose":
			var p := stage.get_actor(a[0])
			if p != null and a.size() > 1:
				if a.has("snap"):
					p.snap_pose(a[1])
				else:
					p.set_pose(a[1], float(kv.get("speed", 8.0)))
		"face":
			var p := stage.get_actor(a[0])
			if p != null and a.size() > 1:
				var other := stage.get_actor(a[1])
				if other != null:
					p.facing = 1 if other.position.x > p.position.x else -1
				else:
					p.facing = -1 if a[1] in ["l", "left"] else 1
		"anim":
			var p := stage.get_actor(a[0])
			if p != null:
				p.anim = "" if a.size() < 2 or a[1] == "none" else a[1]
		"expr":
			var p := stage.get_actor(a[0])
			if p != null:
				p.expr = "" if a.size() < 2 or a[1] == "none" else a[1]
		"prop":
			var p := stage.get_actor(a[0])
			if p != null:
				p.prop = "" if a.size() < 2 or a[1] == "none" else a[1]
		"look":
			var p := stage.get_actor(a[0])
			if p != null and a.size() > 1:
				p.set_look(a[1])
		"hurt":
			var p := stage.get_actor(a[0])
			if p != null:
				p.bruise = clamp(p.bruise + float(kv.get("bruise", 0.0)), 0.0, 1.0)
				p.blood = clamp(p.blood + float(kv.get("blood", 0.0)), 0.0, 1.0)
		"heal":
			var p := stage.get_actor(a[0])
			if p != null:
				p.bruise = float(kv.get("bruise", 0.0))
				p.blood = float(kv.get("blood", 0.0))
		"alpha":
			var p := stage.get_actor(a[0])
			if p != null:
				var to := float(a[1]) if a.size() > 1 else 1.0
				var time := float(kv.get("t", 0.0))
				if time <= 0.0 or Game.autoplay:
					p.alpha = to
				else:
					var tw := create_tween()
					tw.tween_property(p, "alpha", to, time)
					if a.has("wait"):
						await tw.finished
		"wait":
			await _flush_fade()
			await _sleep(float(a[0]) if a.size() > 0 else 1.0)
		"music":
			var track: String = a[0] if a.size() > 0 else "stop"
			if track == "stop":
				Sound.stop_music(float(kv.get("fade", 1.5)))
			else:
				Sound.play_music(track, float(kv.get("fade", 1.5)))
		"amb":
			if a.size() > 0 and a[0] == "stop":
				Sound.stop_ambience(a[1] if a.size() > 1 else "")
			elif a.size() > 0:
				Sound.ambience(a[0], float(kv.get("db", -8.0)))
		"sfx":
			Sound.sfx(a[0], float(kv.get("db", 0.0)), float(kv.get("pitch", 1.0)))
		"flash":
			var look: String = a[0] if a.size() > 0 else "tyler"
			Film.subliminal(look, Vector2(float(kv.get("x", 640)), float(kv.get("y", stage.floor_y()))),
				float(kv.get("scale", 1.0)), int(kv.get("frames", 2)), kv.get("pose", "stand"), -1 if kv.get("face", "r") == "l" else 1)
		"white":
			var c := Color.WHITE
			if a.has("red"):
				c = Color(0.7, 0.05, 0.05)
			Film.white_flash(float(kv.get("t", 0.35)), c)
		"burn":
			Film.cigarette_burn()
			Sound.sfx("film_burn", -8.0)
		"shake":
			Film.shake(float(a[0]) if a.size() > 0 else 8.0, float(kv.get("t", 0.4)))
		"glitch":
			Film.glitch(float(a[0]) if a.size() > 0 else 0.6, float(kv.get("t", 0.4)))
		"baseglitch":
			Film.set_base_glitch(float(a[0]) if a.size() > 0 else 0.0)
		"grade":
			Film.set_grade(a[0] if a.size() > 0 else "normal", float(kv.get("t", 0.0)))
		"ambient":
			if a.size() >= 3:
				stage.set_ambient(Color(float(a[0]), float(a[1]), float(a[2])), float(kv.get("t", 0.0)))
		"fade":
			var dir: String = a[0] if a.size() > 0 else "out"
			await _fade_to(1.0 if dir == "out" else 0.0, float(kv.get("t", 0.8)))
		"black":
			Film.black()
			_dark = true
		"letterbox":
			Film.letterbox(a.size() == 0 or a[0] == "on")
		"camera":
			if a.has("reset"):
				stage.move_camera(Vector2(640, 360), 1.0, float(kv.get("t", 0.8)))
			else:
				stage.move_camera(Vector2(float(kv.get("x", 640)), float(kv.get("y", 360))), float(kv.get("zoom", 1.0)),
					0.0 if Game.autoplay else float(kv.get("t", 1.0)))
		"fx":
			var kind: String = a[0] if a.size() > 0 else "dust"
			var pos := Vector2(float(kv.get("x", 640)), float(kv.get("y", 400)))
			var n := int(kv.get("n", 12))
			match kind:
				"blood":
					stage.fx.blood(pos, Vector2(float(kv.get("dx", 1)), -0.3), n)
				"smoke":
					stage.fx.smoke(pos, n)
				"sparks":
					stage.fx.sparks(pos, n)
				"debris":
					stage.fx.debris(pos, n)
				"dust":
					stage.fx.dust(pos, n)
				"sweat":
					stage.fx.sweat(pos, Vector2(1, -1), n)
		"set":
			Settings.set_flag(a[0], a[1] if a.size() > 1 else true)
		"goto":
			_jump(a[0])
		"if":
			if Settings.get_flag(a[0], false):
				_jump(a[1])
		"ifnot":
			if not Settings.get_flag(a[0], false):
				_jump(a[1])
		"iflose":
			if last_result == "lose":
				_jump(a[0])
		"ifwin":
			if last_result == "win":
				_jump(a[0])
		"choice":
			await _choice(step)
		"title":
			dialogue.hide_box()
			if not _dark:
				await _fade_to(1.0, 0.8)
			await _show_title(step)
		"card":
			dialogue.hide_box()
			if not _dark:
				await _fade_to(1.0, 0.8)
			await _show_card({"fa": step.get("fa", ""), "en": step.get("en", "")}, true, float(kv.get("hold", 0.0)))
		"caption":
			await _flush_fade()
			_show_caption({"fa": step.get("fa", ""), "en": step.get("en", "")}, float(kv.get("t", 4.5)))
		"hint":
			await _flush_fade()
			bark("", {"fa": step.get("fa", ""), "en": step.get("en", "")}, float(kv.get("t", 3.0)))
		"crowd":
			if "excite" in stage.loc:
				stage.loc.set("excite", float(a[0]) if a.size() > 0 else 0.5)
		"set_loc":
			if a.size() >= 2 and a[0] in stage.loc:
				stage.loc.set(a[0], _parse_value(a[1]))
				stage.refresh_location()
		"game", "qte":
			dialogue.hide_box()
			await _flush_fade()
			await _play_game(step)
		_:
			push_warning("Story: unknown command @%s (line %d)" % [cmd, step.get("line", 0)])


func _parse_value(s: String) -> Variant:
	if s.is_valid_float():
		return float(s)
	if s == "true":
		return true
	if s == "false":
		return false
	return s


# --- Actors --------------------------------------------------------------

func _actor(id: String, kv: Dictionary) -> void:
	var p := stage.get_actor(id)
	var fresh := p == null
	if fresh:
		var look: String = kv.get("look", id if Cast.has_look(id) else "jack_office")
		p = stage.add_actor(id, look)
		p.position = Vector2(640, stage.floor_y())
		p.snap_pose("stand")
	elif kv.has("look"):
		p.set_look(kv["look"])
	if kv.has("x"):
		p.position.x = float(kv["x"])
	if kv.has("y") or fresh:
		p.position.y = stage.floor_y() + float(kv.get("y", 0.0))
	if kv.has("scale"):
		var s := float(kv["scale"])
		p.scale = Vector2(s, s)
	elif fresh:
		p.scale = Vector2.ONE * float(stage.loc.get("actor_scale") if "actor_scale" in stage.loc else 1.0)
	if kv.has("pose"):
		if fresh:
			p.snap_pose(kv["pose"])
		else:
			p.set_pose(kv["pose"])
	if kv.has("face"):
		p.facing = -1 if kv["face"] in ["l", "left"] else 1
	if kv.has("z"):
		p.z_index = int(kv["z"])
	if kv.has("alpha"):
		p.alpha = float(kv["alpha"])
	if kv.has("prop"):
		p.prop = "" if kv["prop"] == "none" else kv["prop"]
	if kv.has("expr"):
		p.expr = "" if kv["expr"] == "none" else kv["expr"]
	if kv.has("anim"):
		p.anim = "" if kv["anim"] == "none" else kv["anim"]
	if kv.has("bruise"):
		p.bruise = float(kv["bruise"])
	if kv.has("blood"):
		p.blood = float(kv["blood"])
	if kv.has("shadow"):
		p.show_shadow = kv["shadow"] != "off"
	if kv.has("sil"):
		var v := float(kv["sil"])
		p.silhouette = Color(0.02, 0.02, 0.02, v)


func _move(id: String, kv: Dictionary, wait: bool, run: bool, slide: bool) -> void:
	var p := stage.get_actor(id)
	if p == null:
		return
	var to := float(kv.get("x", p.position.x))
	var dist: float = abs(to - p.position.x)
	var speed := 260.0 if run else 150.0
	var time := float(kv.get("t", dist / speed / max(p.scale.x, 0.4)))
	if not slide:
		if not kv.has("noface") and dist > 1.0:
			p.facing = 1 if to > p.position.x else -1
		p.anim = "run" if run else "walk"
		p.walk_speed = clamp(dist / max(time, 0.05) / speed * 1.0, 0.6, 1.6)
	if Game.autoplay:
		time = 0.01
	var tw := create_tween()
	tw.tween_property(p, "position:x", to, max(time, 0.01))
	if kv.has("y"):
		tw.parallel().tween_property(p, "position:y", stage.floor_y() + float(kv["y"]), max(time, 0.01))
	tw.tween_callback(func():
		if is_instance_valid(p) and not slide:
			p.anim = ""
			p.set_pose(kv.get("pose", "stand")))
	if wait:
		await _flush_fade()
		await tw.finished


# --- Dialogue and choices -------------------------------------------------

func _say(step: Dictionary) -> void:
	await _flush_fade()
	var who: String = step["who"]
	var pair := {"fa": step.get("fa", ""), "en": step.get("en", "")}
	history.append({"who": who, "pair": pair})
	_speaking = stage.get_actor(who)
	var has_voice := Sound.voice(step.get("id", ""))
	dialogue.show_line(who, pair)
	await _wait_advance(has_voice)
	if _speaking != null and is_instance_valid(_speaking):
		_speaking.talking = false
	_speaking = null


func _choice(step: Dictionary) -> void:
	await _flush_fade()
	dialogue.hide_box()
	var options: Array = step.get("options", [])
	if options.is_empty():
		return
	var idx := 0
	if not Game.autoplay:
		idx = await choices.ask(options)
	var opt: Dictionary = options[idx]
	history.append({"who": "jack", "pair": {"fa": opt.get("fa", ""), "en": opt.get("en", "")}})
	if opt.get("kv", {}).has("set"):
		Settings.set_flag(opt["kv"]["set"], true)
	if opt.get("to", "") != "":
		_jump(opt["to"])


## A short line over gameplay or as an on-screen hint. `who` may be "".
func bark(who: String, pair: Dictionary, time := 2.4) -> void:
	var text := Loc.pick(pair)
	if who != "" and who != "narr":
		text = Cast.display_name(who) + ": " + text
		_bark.add_theme_color_override("font_color", Cast.name_color(who))
	else:
		_bark.add_theme_color_override("font_color", Loc.PAPER)
	_bark.text = text
	_bark.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
	var tw := create_tween()
	tw.tween_property(_bark, "modulate:a", 1.0, 0.15)
	tw.tween_interval(time)
	tw.tween_property(_bark, "modulate:a", 0.0, 0.4)


func _show_caption(pair: Dictionary, time: float) -> void:
	_caption.text = Loc.pick(pair)
	UI.apply_dir(_caption)
	_caption.position.x = 480.0 if Loc.is_rtl() else 40.0
	var tw := create_tween()
	tw.tween_property(_caption, "modulate:a", 1.0, 0.8)
	tw.tween_interval(time)
	tw.tween_property(_caption, "modulate:a", 0.0, 1.0)


# --- Cards ---------------------------------------------------------------

func _overlay() -> Control:
	var root := UI.root()
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.01, 0.01)
	UI.full(bg)
	root.add_child(bg)
	_overlay_layer.add_child(root)
	return root


func _show_title(step: Dictionary) -> void:
	var root := _overlay()
	var v := UI.vbox(16)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(UI.center(v))
	var label := UI.label(Game.chapter_label(chapter_index), "Heading", HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_color_override("font_color", Loc.SOAP)
	v.add_child(label)
	var title_pair: Variant = Game.CHAPTERS[chapter_index]["title"]
	if step.get("fa", "") != "":
		title_pair = {"fa": step.get("fa", ""), "en": step.get("en", "")}
	var title := UI.label(title_pair, "Title", HORIZONTAL_ALIGNMENT_CENTER)
	v.add_child(title)
	var line := ColorRect.new()
	line.color = Color(Loc.SOAP, 0.7)
	line.custom_minimum_size = Vector2(220, 2)
	line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(line)
	Film.clear()
	_dark = false
	title.visible_ratio = 0.0
	var tw := create_tween()
	tw.tween_property(title, "visible_ratio", 1.0, 0.9 if not Game.autoplay else 0.01)
	Sound.sfx("typewriter", -6.0)
	await _sleep(3.2)
	await _fade_to(1.0, 0.9)
	root.queue_free()


func _show_card(pair: Dictionary, need_click: bool, hold: float) -> void:
	var root := _overlay()
	var l := Label.new()
	l.theme_type_variation = "Line"
	l.add_theme_font_size_override("font_size", 32)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = Vector2(170, 160)
	l.size = Vector2(940, 400)
	l.text = Loc.pick(pair)
	l.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
	root.add_child(l)
	Film.clear()
	_dark = false
	l.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	l.visible_ratio = 0.0
	var total := l.get_total_character_count()
	var tw := create_tween()
	tw.tween_property(l, "visible_ratio", 1.0, 0.01 if Game.autoplay else total / 30.0 / Settings.text_speed)
	if need_click:
		_advance = false
		while true:
			await ticked
			if Game.autoplay or (_is_skipping() and l.visible_ratio >= 1.0):
				break
			if _advance:
				_advance = false
				if l.visible_ratio < 1.0:
					tw.kill()
					l.visible_ratio = 1.0
				else:
					break
	else:
		await _sleep(hold)
	await _fade_to(1.0, 0.7)
	root.queue_free()


# --- Playable segments ---------------------------------------------------

func _play_game(step: Dictionary) -> void:
	var a: Array = step.get("args", [])
	var kind: String = a[0] if a.size() > 0 else ""
	var path := GAMES_PATH % ("qte" if step["cmd"] == "qte" else kind)
	if not ResourceLoader.exists(path):
		push_warning("Story: no game module %s" % path)
		last_result = "win"
		return
	var g: GameModule = load(path).new()
	stage.add_child(g)
	g.setup(self, step)
	_game = g
	_hud.visible = false
	g.begin()
	if Game.autoplay:
		g.autoplay()
	last_result = await g.finished
	_game = null
	_hud.visible = true
	if is_instance_valid(g):
		g.queue_free()


# --- Menus ---------------------------------------------------------------

func _open_pause() -> void:
	if _menu_open:
		return
	_menu_open = true
	var m := PauseMenu.new()
	m.can_skip_challenge = _game != null
	m.resumed.connect(func(): _menu_open = false)
	m.skip_challenge.connect(func():
		if _game != null and is_instance_valid(_game):
			_game.finish("win"))
	m.to_menu.connect(func():
		Settings.save_progress()
		Game.goto_menu())
	var root := UI.root()
	_menu_layer.add_child(root)
	root.add_child(m)
	m.tree_exited.connect(root.queue_free)


func _open_log() -> void:
	if _menu_open:
		return
	_menu_open = true
	var l := LogPanel.new()
	l.history = history
	l.closed.connect(func(): _menu_open = false)
	var root := UI.root()
	_menu_layer.add_child(root)
	root.add_child(l)
	l.tree_exited.connect(root.queue_free)
