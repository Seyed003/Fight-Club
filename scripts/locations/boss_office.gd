extends Location
## The boss's corner office: a desk, a glass coffee table, a view.

var broken := false


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.66, 0.68, 0.66)
	grade = "office"


func lights() -> Array:
	return [{"pos": Vector2(900, 260), "radius": 700.0, "color": Color(0.95, 0.97, 1.0), "energy": 0.55}]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 480), Color(0.7, 0.7, 0.66))
	Paint.window(ci, Rect2(640, 70, 560, 330), Color(0.6, 0.66, 0.72), Color(0.78, 0.8, 0.8), Color(0.3, 0.3, 0.3), true, true)
	ci.draw_rect(Rect2(60, 120, 260, 300), Color(0.36, 0.26, 0.18))
	for i in 4:
		ci.draw_rect(Rect2(70, 180 + i * 64, 240, 6), Color(0.26, 0.18, 0.12))
		for k in 8:
			ci.draw_rect(Rect2(76 + k * 28, 140 + i * 64, 20, 40), Color(0.3 + fmod(k * 0.17, 0.4), 0.25, 0.2))
	Paint.vgrad(ci, Rect2(0, 480, 1280, 240), Color(0.4, 0.38, 0.36), Color(0.28, 0.26, 0.25))
	Paint.counter(ci, Rect2(700, 470, 420, 180), Color(0.36, 0.24, 0.16), Color(0.28, 0.18, 0.12))
	ci.draw_rect(Rect2(760, 446, 80, 24), Color(0.2, 0.2, 0.2))
	ci.draw_rect(Rect2(940, 452, 120, 18), Color(0.9, 0.9, 0.86))
	# Glass coffee table.
	if broken:
		for i in 14:
			var a := i * 0.7
			Paint.poly(ci, [Vector2(330 + cos(a) * 80, 620), Vector2(350 + cos(a + 0.4) * 110, 628), Vector2(340 + cos(a) * 60, 634)], Color(0.75, 0.9, 0.95, 0.6))
	else:
		ci.draw_rect(Rect2(240, 560, 220, 10), Color(0.75, 0.9, 0.95, 0.55))
		ci.draw_rect(Rect2(256, 570, 6, 70), Color(0.6, 0.6, 0.6))
		ci.draw_rect(Rect2(440, 570, 6, 70), Color(0.6, 0.6, 0.6))
