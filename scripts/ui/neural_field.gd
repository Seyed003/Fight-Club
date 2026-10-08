extends Node2D
## The film's opening: a slow flight through the narrator's brain, out
## of the fear centre. Points drift toward the camera; nearby neurons are
## joined by dendrites and the occasional synapse fires.

const COUNT := 150
const FOCAL := 340.0
const FAR := 5.0
const LINK := 0.85

var speed := 0.35
var tint := Color(0.36, 0.86, 0.72)
var _pts: Array[Vector3] = []
var _seed: Array[float] = []
var _fires: Array = []
var _t := 0.0


func _ready() -> void:
	for i in COUNT:
		_pts.append(_spawn(randf_range(0.2, FAR)))
		_seed.append(randf() * TAU)


func _spawn(z: float) -> Vector3:
	return Vector3(randf_range(-2.4, 2.4), randf_range(-1.5, 1.5), z)


func _process(delta: float) -> void:
	_t += delta
	for i in COUNT:
		var p := _pts[i]
		p.z -= speed * delta
		p.x += sin(_t * 0.3 + _seed[i]) * 0.02 * delta
		if p.z < 0.15:
			p = _spawn(FAR)
		_pts[i] = p
	if randf() < delta * 3.0:
		_fires.append({"a": randi() % COUNT, "b": randi() % COUNT, "t": 0.0})
	var keep: Array = []
	for f in _fires:
		f["t"] += delta * 1.6
		if f["t"] < 1.0:
			keep.append(f)
	_fires = keep
	queue_redraw()


func _project(p: Vector3) -> Vector2:
	var sway := Vector2(sin(_t * 0.17) * 40.0, cos(_t * 0.13) * 24.0)
	return Vector2(640, 360) + Vector2(p.x, p.y) / p.z * FOCAL + sway / p.z


func _draw() -> void:
	Paint.vgrad(self, Rect2(0, 0, 1280, 720), Color(0.01, 0.04, 0.035), Color(0.0, 0.015, 0.02))
	Paint.glow(self, Vector2(640, 360), 520, Color(0.1, 0.35, 0.3, 0.25))
	var screen: Array[Vector2] = []
	screen.resize(COUNT)
	for i in COUNT:
		screen[i] = _project(_pts[i])
	for i in COUNT:
		var a := _pts[i]
		for j in range(i + 1, COUNT):
			var b := _pts[j]
			var dz: float = absf(a.z - b.z)
			if dz > LINK:
				continue
			var d := a.distance_to(b)
			if d < LINK:
				var depth: float = clamp(1.0 - (a.z + b.z) * 0.5 / FAR, 0.0, 1.0)
				var al := (1.0 - d / LINK) * depth * 0.55
				draw_line(screen[i], screen[j], Color(tint, al), 1.0 + depth * 1.5, true)
	for i in COUNT:
		var p := _pts[i]
		var depth: float = clamp(1.0 - p.z / FAR, 0.0, 1.0)
		var r := 1.5 + 9.0 / p.z
		var pulse := 0.6 + 0.4 * sin(_t * 2.0 + _seed[i])
		Paint.glow(self, screen[i], r * 3.0, Color(tint, 0.18 * depth * pulse))
		draw_circle(screen[i], r * 0.45, Color(tint.lightened(0.4), depth * 0.9))
	for f in _fires:
		var pa: Vector2 = screen[f["a"]]
		var pb: Vector2 = screen[f["b"]]
		if pa.distance_to(pb) > 420.0:
			continue
		var head: Vector2 = pa.lerp(pb, f["t"])
		draw_line(pa, head, Color(0.85, 1.0, 0.95, 0.5 * (1.0 - f["t"])), 2.0, true)
		Paint.glow(self, head, 26.0, Color(0.85, 1.0, 0.95, 0.7 * (1.0 - f["t"])))
