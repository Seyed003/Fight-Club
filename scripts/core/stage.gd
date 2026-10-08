class_name Stage
extends Node2D
## The world the story plays in: a location, its lights, the actors,
## particles and a camera. Coordinates are a fixed 1280x720 frame.

const LOCATION_PATH := "res://scripts/locations/%s.gd"

var loc: Location
var actors: Dictionary = {}
var camera: Camera2D
var fx: FxLayer

var _back: Node2D
var _anim: Node2D
var _actors_root: Node2D
var _front: Node2D
var _lights_root: Node2D
var _modulate: CanvasModulate
var _lights: Array = []
var _light_defs: Array = []


func _ready() -> void:
	_back = Node2D.new()
	_back.z_index = -100
	_back.draw.connect(_on_back_draw)
	add_child(_back)
	_anim = Node2D.new()
	_anim.z_index = -90
	_anim.draw.connect(_on_anim_draw)
	add_child(_anim)
	_actors_root = Node2D.new()
	_actors_root.y_sort_enabled = true
	add_child(_actors_root)
	fx = FxLayer.new()
	fx.z_index = 60
	add_child(fx)
	_front = Node2D.new()
	_front.z_index = 80
	_front.draw.connect(_on_front_draw)
	add_child(_front)
	_lights_root = Node2D.new()
	add_child(_lights_root)
	_modulate = CanvasModulate.new()
	add_child(_modulate)
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	add_child(camera)
	camera.make_current()
	if loc == null:
		set_location("black")


func set_location(loc_id: String) -> void:
	var path := LOCATION_PATH % loc_id
	if not ResourceLoader.exists(path):
		push_warning("Stage: unknown location %s" % loc_id)
		path = LOCATION_PATH % "black"
	loc = load(path).new()
	loc.id = loc_id
	loc.refresh()
	if fx != null:
		fx.clear()
		fx.floor_y = loc.floor_y
	if _modulate != null:
		_modulate.color = loc.ambient
	Film.set_grade(loc.grade)
	if loc.amb != "":
		Sound.stop_ambience()
		Sound.ambience(loc.amb, loc.amb_db)
	else:
		Sound.stop_ambience()
	_build_lights()
	if _back != null:
		_back.queue_redraw()
		_anim.queue_redraw()
		_front.queue_redraw()
	reset_camera()


## Re-applies a location's look after one of its properties changed.
func refresh_location() -> void:
	if loc == null:
		return
	loc.refresh()
	_modulate.color = loc.ambient
	_build_lights()
	_back.queue_redraw()
	_anim.queue_redraw()
	_front.queue_redraw()


func floor_y() -> float:
	return loc.floor_y if loc != null else 640.0


func _build_lights() -> void:
	for l in _lights:
		l.queue_free()
	_lights.clear()
	if _lights_root == null:
		return
	_light_defs = loc.lights()
	for def in _light_defs:
		var light := PointLight2D.new()
		light.texture = Paint.radial_tex()
		light.position = def.get("pos", Vector2(640, 200))
		light.texture_scale = float(def.get("radius", 400.0)) / 128.0
		light.color = def.get("color", Color(1, 0.9, 0.7))
		light.energy = def.get("energy", 1.0)
		light.blend_mode = Light2D.BLEND_MODE_ADD
		_lights_root.add_child(light)
		_lights.append(light)


func _process(delta: float) -> void:
	if loc == null:
		return
	loc.update(delta)
	for i in _lights.size():
		var def: Dictionary = _light_defs[i]
		var light: PointLight2D = _lights[i]
		var base_pos: Vector2 = def.get("pos", Vector2(640, 200))
		light.position = base_pos + loc.swing_offset(def)
		var fl: float = def.get("flicker", 0.0)
		var e: float = def.get("energy", 1.0)
		if fl > 0.0:
			light.energy = e * (1.0 - fl * 0.5 + randf() * fl * 0.5) * (0.2 if randf() < fl * 0.04 else 1.0)
		else:
			light.energy = e
	if loc.animated:
		_anim.queue_redraw()
	if loc.front_animated:
		_front.queue_redraw()


func set_ambient(c: Color, time := 0.0) -> void:
	if time <= 0.0:
		_modulate.color = c
	else:
		create_tween().tween_property(_modulate, "color", c, time)


func _on_back_draw() -> void:
	if loc != null:
		loc.draw_static(_back)


func _on_anim_draw() -> void:
	if loc != null:
		loc.draw_anim(_anim)


func _on_front_draw() -> void:
	if loc != null:
		loc.draw_front(_front)


func add_actor(actor_id: String, look_id: String) -> Puppet:
	var p: Puppet = actors.get(actor_id)
	if p == null or not is_instance_valid(p):
		p = Puppet.new()
		p.name = actor_id
		_actors_root.add_child(p)
		actors[actor_id] = p
	p.set_look(look_id)
	return p


func get_actor(actor_id: String) -> Puppet:
	var p: Puppet = actors.get(actor_id)
	if p != null and is_instance_valid(p):
		return p
	return null


func remove_actor(actor_id: String) -> void:
	var p := get_actor(actor_id)
	if p != null:
		p.queue_free()
	actors.erase(actor_id)


func clear_actors() -> void:
	for k in actors.keys():
		remove_actor(k)
	actors.clear()


func actors_root() -> Node2D:
	return _actors_root


func reset_camera() -> void:
	if camera == null:
		return
	camera.position = Vector2(640, 360)
	camera.zoom = Vector2.ONE


func move_camera(pos: Vector2, zoom: float, time := 1.0) -> void:
	if time <= 0.0:
		camera.position = pos
		camera.zoom = Vector2(zoom, zoom)
		return
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(camera, "position", pos, time)
	tw.tween_property(camera, "zoom", Vector2(zoom, zoom), time)
