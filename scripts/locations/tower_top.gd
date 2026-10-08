extends Location
## The top floor of a half-built tower at night. The opening and the end:
## a wall of glass, the city below, the buildings across the way.
## `collapse` > 0 starts the demolition seen through the windows.

var collapse := 0.0
var _boom_t := -1.0
var _flashes: Array = []


func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.42, 0.45, 0.55)
	grade = "night"
	animated = true
	amb = "wind"
	amb_db = -14.0


func lights() -> Array:
	return [
		{"pos": Vector2(640, 420), "radius": 700.0, "color": Color(0.55, 0.65, 0.95), "energy": 0.55},
		{"pos": Vector2(640, 640), "radius": 360.0, "color": Color(1.0, 0.75, 0.5), "energy": 0.25},
	]


func update(delta: float) -> void:
	t += delta
	if collapse > 0.0:
		if _boom_t < 0.0:
			_boom_t = 0.0
		_boom_t += delta


func _building_progress(i: int) -> float:
	if _boom_t < 0.0:
		return 0.0
	return clamp((_boom_t - i * 1.4) / 5.0, 0.0, 1.0)


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 720), Color(0.03, 0.035, 0.05))
	Paint.vgrad(ci, Rect2(0, 600, 1280, 120), Color(0.06, 0.06, 0.08), Color(0.02, 0.02, 0.03))


func draw_anim(ci: CanvasItem) -> void:
	var win := Rect2(60, 70, 1160, 500)
	Paint.vgrad(ci, win, Color(0.04, 0.05, 0.12), Color(0.28, 0.18, 0.16))
	Paint.skyline(ci, Rect2(win.position.x, win.position.y + 300, win.size.x, 200), true, 31, 0.22)
	# The three credit card towers across the street.
	var towers := [Rect2(170, 170, 150, 400), Rect2(560, 120, 170, 450), Rect2(930, 190, 140, 380)]
	for i in towers.size():
		var r: Rect2 = towers[i]
		var p := _building_progress(i)
		var drop := p * p * r.size.y
		var tr := Rect2(r.position.x, r.position.y + drop, r.size.x, r.size.y - drop)
		if tr.size.y > 4.0:
			ci.draw_rect(tr, Color(0.07, 0.08, 0.1))
			var rng := RandomNumberGenerator.new()
			rng.seed = 100 + i
			var wy := tr.position.y + 10
			while wy < tr.end.y - 8:
				var wx := tr.position.x + 8
				while wx < tr.end.x - 10:
					var lit := rng.randf() < 0.45 and p < 0.05
					ci.draw_rect(Rect2(wx, wy, 8, 6), Color(1.0, 0.88, 0.6, 0.85) if lit else Color(0.12, 0.13, 0.16))
					wx += 14
				wy += 13
		if p > 0.0 and p < 1.0:
			var dust_y := r.end.y - 40
			for k in 6:
				Paint.glow_ellipse(ci, Vector2(r.get_center().x + sin(k * 2.1 + t) * 60, dust_y - k * 30 * p), r.size.x * (0.6 + p), 60 + p * 80, Color(0.55, 0.5, 0.45, 0.32 * (1.0 - p * 0.5)))
		if p > 0.0 and p < 0.12:
			Paint.glow(ci, Vector2(r.get_center().x, r.end.y - 30), 220, Color(1.0, 0.7, 0.3, 0.8 * (1.0 - p / 0.12)))
	# Mullions and reflections.
	ci.draw_rect(win, Color(0.1, 0.11, 0.12), false, 14.0)
	var x := win.position.x
	while x <= win.end.x:
		ci.draw_line(Vector2(x, win.position.y), Vector2(x, win.end.y), Color(0.1, 0.11, 0.12), 10.0)
		x += win.size.x / 5.0
	ci.draw_line(Vector2(win.position.x, 330), Vector2(win.end.x, 330), Color(0.1, 0.11, 0.12), 6.0)
	Paint.poly(ci, [Vector2(120, 80), Vector2(200, 80), Vector2(110, 560), Vector2(60, 560)], Color(1, 1, 1, 0.03))
	Paint.poly(ci, [Vector2(760, 80), Vector2(800, 80), Vector2(720, 560), Vector2(690, 560)], Color(1, 1, 1, 0.025))
	# Window light pooled on the floor.
	Paint.glow_ellipse(ci, Vector2(640, 650), 600, 50, Color(0.4, 0.45, 0.7, 0.12))
	Paint.chair(ci, Vector2(640, 640), Color(0.14, 0.14, 0.15), 1.5, 1)
