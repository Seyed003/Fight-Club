extends Location
## Behind an all-night convenience store. One lamp, a back door, a wall.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.32, 0.34, 0.4)
	grade = "night"
	animated = true
	amb = "night_city"
	amb_db = -14.0


func lights() -> Array:
	return [
		{"pos": Vector2(560, 250), "radius": 520.0, "color": Color(0.9, 1.0, 0.85), "energy": 0.9, "flicker": 0.12},
		{"pos": Vector2(1100, 360), "radius": 320.0, "color": Color(1.0, 0.3, 0.3), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.02, 0.04), Color(0.05, 0.05, 0.07))
	ci.draw_rect(Rect2(0, 100, 1280, 440), Color(0.5, 0.48, 0.42))
	var y := 100.0
	while y < 540.0:
		ci.draw_line(Vector2(0, y), Vector2(1280, y), Color(0.42, 0.4, 0.35), 2.0)
		y += 30.0
	Paint.grime(ci, Rect2(0, 100, 1280, 440), Color(0.05, 0.05, 0.03, 0.5), 33, 16)
	Paint.door(ci, Rect2(480, 300, 120, 240), Color(0.55, 0.15, 0.12))
	ci.draw_rect(Rect2(520, 230, 50, 14), Color(0.25, 0.25, 0.25))
	Paint.neon(ci, Vector2(980, 260), "OPEN 24", Color(1.0, 0.3, 0.3), 30)
	for i in 4:
		ci.draw_rect(Rect2(820 + i * 34, 440 - (i % 2) * 34, 30, 30), Color(0.55, 0.42, 0.28))
	Paint.vgrad(ci, Rect2(0, 540, 1280, 180), Color(0.15, 0.15, 0.16), Color(0.06, 0.06, 0.07))
	Paint.dumpster(ci, Vector2(220, 560), Color(0.2, 0.25, 0.32))


func draw_anim(ci: CanvasItem) -> void:
	Paint.glow(ci, Vector2(545, 250), 80, Color(0.9, 1.0, 0.85, 0.5 + 0.1 * sin(t * 30.0)))
