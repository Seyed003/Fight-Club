extends Location
## Lou's Tavern: a long bar, cheap beer, neon, smoke.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.42, 0.38, 0.34)
	grade = "warm"
	animated = true
	amb = "bar_murmur"
	amb_db = -12.0


func lights() -> Array:
	return [
		{"pos": Vector2(420, 180), "radius": 380.0, "color": Color(1.0, 0.75, 0.45), "energy": 0.8},
		{"pos": Vector2(900, 180), "radius": 380.0, "color": Color(1.0, 0.75, 0.45), "energy": 0.8},
		{"pos": Vector2(1100, 260), "radius": 300.0, "color": Color(1.0, 0.3, 0.3), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.wood_panels(ci, Rect2(0, 0, 1280, 500), Color(0.22, 0.14, 0.1), 60)
	ci.draw_rect(Rect2(140, 120, 860, 230), Color(0.14, 0.1, 0.08))
	Paint.bottles(ci, Rect2(160, 130, 820, 220), 12)
	ci.draw_rect(Rect2(140, 120, 860, 230), Color(0.3, 0.2, 0.12), false, 6.0)
	Paint.neon(ci, Vector2(1040, 200), "BEER", Color(1.0, 0.35, 0.3), 40)
	Paint.neon(ci, Vector2(30, 220), "OPEN", Color(0.5, 0.9, 0.5), 30)
	Paint.vgrad(ci, Rect2(0, 500, 1280, 220), Color(0.18, 0.12, 0.09), Color(0.08, 0.06, 0.05))
	# Bar counter.
	Paint.counter(ci, Rect2(100, 430, 940, 230), Color(0.36, 0.22, 0.12), Color(0.24, 0.15, 0.09))
	for i in 6:
		var x := 180 + i * 150
		ci.draw_rect(Rect2(x, 460, 10, 22), Color(0.4, 0.25, 0.08, 0.9))
	for i in 5:
		var x := 220.0 + i * 170.0
		ci.draw_rect(Rect2(x - 4, 560, 8, 90), Color(0.15, 0.15, 0.15))
		Paint.ellipse(ci, Vector2(x, 556), 34, 8, Color(0.5, 0.12, 0.1))


func draw_anim(ci: CanvasItem) -> void:
	for i in 3:
		var y := fposmod(300.0 - t * 12.0 - i * 120.0, 400.0)
		Paint.glow_ellipse(ci, Vector2(400 + i * 300 + sin(t * 0.3 + i) * 60, y), 280, 50, Color(0.8, 0.75, 0.65, 0.06))
