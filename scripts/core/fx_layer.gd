class_name FxLayer
extends Node2D
## Small particle system for the things fights leave behind: blood that
## drips and stains the floor, sweat, dust, sparks, smoke and debris.

var floor_y := 640.0
var _parts: Array = []
var _stains: Array = []


func clear() -> void:
	_parts.clear()
	_stains.clear()
	queue_redraw()


func _add(pos: Vector2, vel: Vector2, life: float, size: float, color: Color, kind: String, grav := 900.0) -> void:
	_parts.append({"p": pos, "v": vel, "life": life, "max": life, "size": size, "c": color, "kind": kind, "g": grav})


func blood(pos: Vector2, dir: Vector2, count := 10, power := 1.0) -> void:
	for i in count:
		var v := dir.normalized().rotated(randf_range(-0.7, 0.7)) * randf_range(120, 420) * power + Vector2(0, -randf_range(40, 200))
		_add(pos, v, randf_range(0.5, 1.2), randf_range(2.0, 4.5), Color(0.55, 0.02, 0.02, 0.95), "blood")


func sweat(pos: Vector2, dir: Vector2, count := 6) -> void:
	for i in count:
		var v := dir.normalized().rotated(randf_range(-0.9, 0.9)) * randf_range(100, 300) + Vector2(0, -120)
		_add(pos, v, randf_range(0.3, 0.6), randf_range(1.5, 2.5), Color(0.85, 0.9, 0.95, 0.7), "drop")


func dust(pos: Vector2, count := 12) -> void:
	for i in count:
		var v := Vector2(randf_range(-160, 160), randf_range(-60, -10))
		_add(pos, v, randf_range(0.5, 1.0), randf_range(6, 14), Color(0.55, 0.52, 0.46, 0.25), "puff", 0.0)


func sparks(pos: Vector2, count := 14) -> void:
	for i in count:
		var v := Vector2.from_angle(randf() * TAU) * randf_range(150, 500)
		_add(pos, v, randf_range(0.2, 0.5), randf_range(1.5, 3.0), Color(1.0, 0.8, 0.4), "spark", 500.0)


func smoke(pos: Vector2, count := 10, c := Color(0.3, 0.3, 0.3, 0.35)) -> void:
	for i in count:
		var v := Vector2(randf_range(-40, 40), randf_range(-120, -40))
		_add(pos + Vector2(randf_range(-20, 20), 0), v, randf_range(1.5, 3.0), randf_range(20, 40), c, "puff", -10.0)


func debris(pos: Vector2, count := 16, c := Color(0.5, 0.48, 0.44)) -> void:
	for i in count:
		var v := Vector2.from_angle(randf_range(-PI, 0)) * randf_range(200, 600)
		_add(pos, v, randf_range(0.8, 1.6), randf_range(3, 8), c.lightened(randf_range(-0.2, 0.2)), "chunk")


func stain(pos: Vector2, r: float, c := Color(0.4, 0.02, 0.02, 0.75)) -> void:
	_stains.append({"p": pos, "r": r, "c": c})
	if _stains.size() > 160:
		_stains.pop_front()


func _process(delta: float) -> void:
	if _parts.is_empty():
		return
	var keep: Array = []
	for p in _parts:
		p["life"] -= delta
		p["v"].y += p["g"] * delta
		if p["kind"] == "puff":
			p["v"] *= 0.96
			p["size"] += delta * 18.0
		p["p"] += p["v"] * delta
		if p["kind"] in ["blood", "drop", "chunk"] and p["p"].y >= floor_y and p["v"].y > 0.0:
			if p["kind"] == "blood":
				stain(Vector2(p["p"].x, floor_y + randf_range(-6, 10)), p["size"] * randf_range(1.2, 2.4))
				continue
			p["p"].y = floor_y
			p["v"] = Vector2(p["v"].x * 0.4, -p["v"].y * 0.2)
		if p["life"] > 0.0:
			keep.append(p)
	_parts = keep
	queue_redraw()


func _draw() -> void:
	for s in _stains:
		var c: Color = s["c"]
		var r: float = s["r"]
		_ellipse(s["p"], r, r * 0.35, c)
	for p in _parts:
		var c: Color = p["c"]
		var k: float = clamp(p["life"] / p["max"], 0.0, 1.0)
		match p["kind"]:
			"blood", "drop":
				var tail: Vector2 = p["p"] - p["v"] * 0.02
				draw_line(tail, p["p"], Color(c, c.a * k), p["size"], true)
			"spark":
				draw_line(p["p"] - p["v"] * 0.03, p["p"], Color(c, k), p["size"], true)
			"puff":
				_ellipse(p["p"], p["size"], p["size"] * 0.8, Color(c, c.a * k))
			"chunk":
				draw_rect(Rect2(p["p"] - Vector2(p["size"], p["size"]) * 0.5, Vector2(p["size"], p["size"])), Color(c, k))


func _ellipse(center: Vector2, rx: float, ry: float, c: Color) -> void:
	var pts := PackedVector2Array()
	for i in 12:
		var t := TAU * i / 12.0
		pts.append(center + Vector2(cos(t) * rx, sin(t) * ry))
	draw_colored_polygon(pts, c)
