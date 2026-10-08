extends Node
## Command-line test harness. Examples (after `--` on the Godot command line):
##   --test=cast --loc=basement --pose=stand --shot=/tmp/a.png
##   --test=loc --loc=office --shot=/tmp/b.png

var stage: Stage


func _ready() -> void:
	var args: Dictionary = Game.test_args
	stage = Stage.new()
	add_child(stage)
	stage.set_location(args.get("loc", "basement"))
	match args.get("test", "cast"):
		"cast":
			_lineup(args.get("pose", "stand"), args.get("from", "0").to_int(), args.get("count", "10").to_int())
		"loc":
			_pair()
	var frames := int(args.get("frames", "20"))
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
