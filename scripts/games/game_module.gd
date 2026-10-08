class_name GameModule
extends Node2D
## Base for every playable segment launched from a screenplay with
## `@game <kind>` or `@qte <mode>`. A module draws in the stage (world
## space), puts its HUD in `ui`, and calls finish("win" | "lose").

signal finished(result: String)

var player: Node
var stage: Stage
var ui: Control
var step: Dictionary = {}
var kv: Dictionary = {}
var done := false


func setup(story_player: Node, s: Dictionary) -> void:
	player = story_player
	stage = story_player.stage
	step = s
	kv = s.get("kv", {})
	ui = UI.root()
	story_player.ui_layer.add_child(ui)
	z_index = 50


## Override: build the segment and start it.
func begin() -> void:
	pass


## Test mode: finish quickly so whole chapters can be run unattended.
func autoplay() -> void:
	for i in 20:
		await get_tree().process_frame
	finish("win")


func finish(result := "win") -> void:
	if done:
		return
	done = true
	if is_instance_valid(ui):
		ui.queue_free()
	finished.emit.call_deferred(result)


func prompt() -> String:
	return Loc.pick({"fa": step.get("fa", ""), "en": step.get("en", "")})


func kvf(key: String, default: float) -> float:
	return float(kv[key]) if kv.has(key) else default


func kvi(key: String, default: int) -> int:
	return int(kv[key]) if kv.has(key) else default


func kvs(key: String, default: String) -> String:
	return String(kv[key]) if kv.has(key) else default


## A line of text at the top of the screen for instructions.
func hint_label(text: String, y := 34.0, size := 24) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(140, y)
	l.size = Vector2(1000, 40)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 6)
	l.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.add_child(l)
	return l


## Shows a line from the screenplay's speaker while the game runs.
func bark(who: String, pair: Dictionary, time := 2.4) -> void:
	if player != null and player.has_method("bark"):
		player.bark(who, pair, time)
