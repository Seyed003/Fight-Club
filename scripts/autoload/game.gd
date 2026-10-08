extends Node
## Flow between screens, the chapter list, and the command-line test modes.

const CHAPTERS := [
	{"file": "res://story/ch00_prologue.txt", "title": {"fa": "اسلحه", "en": "The Gun"}},
	{"file": "res://story/ch01_insomnia.txt", "title": {"fa": "بی‌خوابی", "en": "Insomnia"}},
	{"file": "res://story/ch02_single_serving.txt", "title": {"fa": "دوستان یک‌بارمصرف", "en": "Single-Serving Friends"}},
	{"file": "res://story/ch03_paper_street.txt", "title": {"fa": "خیابان پیپر", "en": "Paper Street"}},
	{"file": "res://story/ch04_soap.txt", "title": {"fa": "صابون", "en": "Soap"}},
	{"file": "res://story/ch05_rules.txt", "title": {"fa": "قوانین", "en": "The Rules"}},
	{"file": "res://story/ch06_mayhem.txt", "title": {"fa": "پروژه‌ی مِیهِم", "en": "Project Mayhem"}},
	{"file": "res://story/ch07_paulson.txt", "title": {"fa": "اسم او رابرت پالسون بود", "en": "His Name Was Robert Paulson"}},
	{"file": "res://story/ch08_trail.txt", "title": {"fa": "ردِ تایلر", "en": "Tyler's Trail"}},
	{"file": "res://story/ch09_endgame.txt", "title": {"fa": "پایان بازی", "en": "Endgame"}},
]

const MENU := preload("res://scripts/ui/main_menu.gd")
const PLAYER := preload("res://scripts/story/story_player.gd")
const CREDITS := preload("res://scripts/ui/credits.gd")

## Test switches, read from the command line after `--`.
var autoplay := false
var test_args: Dictionary = {}

var _root: Node
var _current: Node


func boot(root: Node) -> void:
	_root = root
	for arg in OS.get_cmdline_user_args():
		var kv: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
		test_args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	autoplay = test_args.has("autoplay")
	Settings.apply_window()
	if test_args.has("lang"):
		Settings.set_lang(test_args["lang"])
	if test_args.has("test"):
		var tester = load("res://scripts/debug/tester.gd").new()
		_switch(tester)
		return
	if test_args.has("shot"):
		_shot_later(test_args["shot"], float(test_args.get("secs", "3")))
	if test_args.has("chapter"):
		play_chapter(int(test_args["chapter"]))
		return
	goto_menu()


## Test helper: capture the screen after a delay and quit.
func _shot_later(path: String, secs: float) -> void:
	await get_tree().create_timer(secs, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("saved ", path)
	get_tree().quit()


func _switch(node: Node) -> void:
	if _current != null and is_instance_valid(_current):
		_current.queue_free()
	_current = node
	get_tree().paused = false
	Film.reset()
	Sound.stop_ambience()
	_root.add_child(node)


func goto_menu() -> void:
	_switch(MENU.new())


func play_chapter(index: int) -> void:
	index = clamp(index, 0, CHAPTERS.size() - 1)
	Settings.current_chapter = index
	Settings.unlock(index)
	var player = PLAYER.new()
	player.chapter_index = index
	player.chapter_file = CHAPTERS[index]["file"]
	_switch(player)


func chapter_finished(index: int) -> void:
	if autoplay:
		print("CHAPTER DONE ", index)
		if not test_args.has("all") or index + 1 >= CHAPTERS.size():
			get_tree().quit()
			return
	if index + 1 < CHAPTERS.size():
		Settings.unlock(index + 1)
		play_chapter(index + 1)
	else:
		Settings.current_chapter = -1
		Settings.save_progress()
		show_credits()


func show_credits() -> void:
	_switch(CREDITS.new())


func chapter_title(index: int) -> String:
	return Loc.pick(CHAPTERS[index]["title"])


func chapter_label(index: int) -> String:
	if index == 0:
		return Loc.t("prologue")
	return Loc.t("chapter_n") % Loc.num(index)


func quit() -> void:
	get_tree().quit()
