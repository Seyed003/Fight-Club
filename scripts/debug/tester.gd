extends Node
## Command-line test harness. Examples (after `--` on the Godot command line):
##   --test=cast --loc=basement --pose=stand --shot=/tmp/a.png
##   --test=loc --loc=office --shot=/tmp/b.png

var stage: Stage
var ui_layer: CanvasLayer


func _ready() -> void:
	var args: Dictionary = Game.test_args
	if args.get("test", "") == "compile":
		_compile_all("res://scripts")
		_check_stories()
		get_tree().quit()
		return
	stage = Stage.new()
	add_child(stage)
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	stage.set_location(args.get("loc", "basement"))
	match args.get("test", "cast"):
		"game":
			var g: GameModule = load("res://scripts/games/%s_game.gd" % args.get("game", "fight")).new()
			stage.add_child(g)
			var kv := {"demo": "1"}
			for k in args:
				if k.begins_with("k_"):
					kv[k.substr(2)] = args[k]
			g.setup(self, {"kv": kv, "args": [], "fa": "آزمایش", "en": "Test prompt"})
			g.begin()
		"cast":
			_lineup(args.get("pose", "stand"), args.get("from", "0").to_int(), args.get("count", "10").to_int())
		"loc":
			_pair()
		"sheet":
			pass
	var frames := int(args.get("frames", "20"))
	if args.has("secs"):
		await get_tree().create_timer(float(args["secs"])).timeout
	for i in frames:
		await get_tree().process_frame
	if args.has("shot"):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(args["shot"])
		print("saved ", args["shot"])
	if not args.has("stay"):
		get_tree().quit()


func _lineup(pose_name: String, from: int, count: int) -> void:
	var ids: Array = Cast.LOOKS.keys()
	var shown := ids.slice(from, from + count)
	var n := shown.size()
	for i in n:
		var p := stage.add_actor("a%d" % i, shown[i])
		p.position = Vector2(80 + i * (1120.0 / max(1, n - 1)), stage.floor_y())
		p.scale = Vector2(0.95, 0.95)
		p.snap_pose(pose_name)
		p.facing = 1 if i % 2 == 0 else -1
		p.talking = i % 3 == 0
		print(shown[i])


func _pair() -> void:
	var a := stage.add_actor("jack", "jack_fight")
	a.position = Vector2(500, stage.floor_y())
	a.snap_pose("guard")
	var b := stage.add_actor("tyler", "tyler_fight")
	b.position = Vector2(780, stage.floor_y())
	b.facing = -1
	b.snap_pose("jab")
	b.expr = "smirk"
	a.bruise = 0.5
	a.blood = 0.5


## Loads every script so parse errors show up in one run.
func _compile_all(dir_path: String) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			var path := dir_path + "/" + f
			var s = load(path)
			if s == null or not (s as GDScript).can_instantiate():
				print("COMPILE FAIL ", path)
	for sub in d.get_directories():
		_compile_all(dir_path + "/" + sub)
	print("compiled ", dir_path)


## Parses every chapter and reports unknown commands, looks, poses, locations.
func _check_stories() -> void:
	var known := ["say", "scene", "cut", "actor", "remove", "clear", "move", "pose", "face", "anim", "expr", "prop", "look",
		"hurt", "heal", "alpha", "wait", "music", "amb", "sfx", "flash", "white", "burn", "shake", "glitch", "baseglitch",
		"grade", "ambient", "fade", "black", "letterbox", "camera", "fx", "set", "goto", "if", "ifnot", "iflose", "ifwin",
		"choice", "title", "card", "caption", "hint", "crowd", "set_loc", "game", "qte", "end"]
	for ch in Game.CHAPTERS:
		var path: String = ch["file"]
		if not FileAccess.file_exists(path):
			print("MISSING ", path)
			continue
		var sc := StoryScript.load_file(path)
		for e in sc.errors:
			print("STORY ", path.get_file(), " ", e)
		var lines := 0
		for st in sc.steps:
			var cmd: String = st["cmd"]
			var ln: int = st.get("line", 0)
			if cmd == "say":
				lines += 1
				if st.get("en", "") == "" or st.get("fa", "") == "":
					print("STORY %s:%d missing translation" % [path.get_file(), ln])
				continue
			if cmd not in known:
				print("STORY %s:%d unknown command @%s" % [path.get_file(), ln, cmd])
			var a: Array = st.get("args", [])
			var kv: Dictionary = st.get("kv", {})
			if cmd in ["scene", "cut"] and a.size() > 0 and not ResourceLoader.exists("res://scripts/locations/%s.gd" % a[0]):
				print("STORY %s:%d unknown location %s" % [path.get_file(), ln, a[0]])
			if kv.has("look") and not Cast.has_look(kv["look"]):
				print("STORY %s:%d unknown look %s" % [path.get_file(), ln, kv["look"]])
			if cmd == "look" and a.size() > 1 and not Cast.has_look(a[1]):
				print("STORY %s:%d unknown look %s" % [path.get_file(), ln, a[1]])
			if cmd == "actor" and not kv.has("look") and not Cast.has_look(a[0]):
				pass
			if kv.has("pose") and not Poses.has_pose(kv["pose"]):
				print("STORY %s:%d unknown pose %s" % [path.get_file(), ln, kv["pose"]])
			if cmd == "pose" and a.size() > 1 and not Poses.has_pose(a[1]):
				print("STORY %s:%d unknown pose %s" % [path.get_file(), ln, a[1]])
			if cmd == "game" and a.size() > 0 and not ResourceLoader.exists("res://scripts/games/%s_game.gd" % a[0]):
				print("STORY %s:%d unknown game %s" % [path.get_file(), ln, a[0]])
			if cmd in ["music"] and a.size() > 0 and a[0] != "stop" and not ResourceLoader.exists("res://assets/audio/music/%s.ogg" % a[0]):
				print("STORY %s:%d missing music %s" % [path.get_file(), ln, a[0]])
			if cmd in ["sfx", "amb"] and a.size() > 0 and a[0] != "stop" and not ResourceLoader.exists("res://assets/audio/sfx/%s.ogg" % a[0]):
				print("STORY %s:%d missing sfx %s" % [path.get_file(), ln, a[0]])
			if cmd in ["card", "caption", "hint", "qte"] and (st.get("fa", "") == "" or st.get("en", "") == ""):
				if not (cmd == "qte" and st.get("fa", "") == "" and st.get("en", "") == ""):
					print("STORY %s:%d missing text for @%s" % [path.get_file(), ln, cmd])
			if cmd == "choice":
				for opt in st["options"]:
					if opt.get("fa", "") == "" or opt.get("en", "") == "":
						print("STORY %s:%d option missing text" % [path.get_file(), ln])
		print("story ", path.get_file(), ": ", sc.steps.size(), " steps, ", lines, " lines")
