extends Location
## A detective's office: blinds, a metal desk, a coffee-stained file.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.56, 0.58, 0.56)
	grade = "cold"
	amb = "fluorescent"
	amb_db = -16.0


func lights() -> Array:
	return [
		{"pos": Vector2(640, 100), "radius": 700.0, "color": Color(0.9, 1.0, 0.95), "energy": 0.5, "flicker": 0.05},
		{"pos": Vector2(1050, 250), "radius": 360.0, "color": Color(0.9, 0.9, 1.0), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 480), Color(0.6, 0.64, 0.62))
	ci.draw_rect(Rect2(0, 320, 1280, 160), Color(0.48, 0.54, 0.52))
	Paint.window(ci, Rect2(880, 90, 300, 220), Color(0.5, 0.56, 0.62), Color(0.7, 0.72, 0.72), Color(0.3, 0.3, 0.3), true, true)
	ci.draw_rect(Rect2(120, 100, 320, 200), Color(0.6, 0.48, 0.32))
	for i in 6:
		ci.draw_rect(Rect2(134 + (i % 3) * 100, 114 + (i / 3) * 92, 84, 78), Color(0.92, 0.9, 0.84))
		Paint.ellipse(ci, Vector2(176 + (i % 3) * 100, 140 + (i / 3) * 92), 16, 18, Color(0.3, 0.3, 0.3))
	Paint.vgrad(ci, Rect2(0, 480, 1280, 240), Color(0.36, 0.38, 0.36), Color(0.22, 0.24, 0.22))
	Paint.counter(ci, Rect2(520, 480, 420, 170), Color(0.5, 0.52, 0.54), Color(0.4, 0.42, 0.44))
	ci.draw_rect(Rect2(560, 458, 120, 22), Color(0.82, 0.76, 0.6))
	ci.draw_rect(Rect2(760, 446, 26, 34), Color(0.92, 0.9, 0.86))
	ci.draw_rect(Rect2(820, 440, 60, 40), Color(0.15, 0.15, 0.16))
