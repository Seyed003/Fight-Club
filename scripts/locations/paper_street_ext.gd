extends Location
## The house on Paper Street: a rotting three-storey Victorian alone in an
## industrial wasteland. `day` for the recruits waiting on the porch.

var day := false


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.38, 0.4, 0.46)
	grade = "night"
	animated = true
	amb = "rain"
	amb_db = -10.0


func refresh() -> void:
	ambient = Color(0.72, 0.72, 0.68) if day else Color(0.38, 0.4, 0.46)
	amb = "" if day else "rain"
	grade = "normal" if day else "night"


func lights() -> Array:
	if day:
		return [{"pos": Vector2(640, 100), "radius": 900.0, "color": Color(0.95, 0.92, 0.85), "energy": 0.6}]
	return [
		{"pos": Vector2(620, 420), "radius": 380.0, "color": Color(1.0, 0.8, 0.45), "energy": 0.8, "flicker": 0.2},
		{"pos": Vector2(1120, 200), "radius": 420.0, "color": Color(0.7, 0.8, 1.0), "energy": 0.4},
	]


func draw_static(ci: CanvasItem) -> void:
	if day:
		Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.55, 0.58, 0.6), Color(0.72, 0.7, 0.64))
	else:
		Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.05), Color(0.07, 0.07, 0.09))
	# Factories and smokestacks behind.
	var far := Color(0.25, 0.26, 0.28) if day else Color(0.06, 0.07, 0.08)
	ci.draw_rect(Rect2(0, 300, 260, 260), far)
	ci.draw_rect(Rect2(60, 160, 34, 150), far)
	ci.draw_rect(Rect2(950, 280, 330, 280), far)
	ci.draw_rect(Rect2(1150, 120, 30, 170), far)
	# The house.
	var wall := Color(0.42, 0.38, 0.32) if day else Color(0.2, 0.18, 0.16)
	Paint.poly(ci, [Vector2(330, 560), Vector2(330, 180), Vector2(430, 110), Vector2(630, 60), Vector2(830, 110), Vector2(930, 180), Vector2(930, 560)], wall)
	Paint.poly(ci, [Vector2(310, 190), Vector2(630, 40), Vector2(950, 190), Vector2(930, 200), Vector2(630, 62), Vector2(330, 200)], wall.darkened(0.45))
	var y := 210.0
	while y < 540.0:
		ci.draw_line(Vector2(330, y), Vector2(930, y), wall.darkened(0.2), 2.0)
		y += 16.0
	Paint.grime(ci, Rect2(330, 180, 600, 380), Color(0.05, 0.04, 0.02, 0.6), 7, 14)
	for wx in [390.0, 570.0, 750.0]:
		for wy in [220.0, 360.0]:
			var lit: bool = (not day) and wx == 570.0 and wy == 360.0
			ci.draw_rect(Rect2(wx, wy, 110, 90), Color(1.0, 0.82, 0.45, 0.85) if lit else Color(0.06, 0.06, 0.07))
			ci.draw_rect(Rect2(wx, wy, 110, 90), wall.darkened(0.5), false, 6.0)
			if wx == 390.0 and wy == 220.0:
				for k in 3:
					ci.draw_line(Vector2(wx, wy + 20 + k * 25), Vector2(wx + 110, wy + 10 + k * 28), Color(0.35, 0.28, 0.2), 9.0)
	# Porch.
	ci.draw_rect(Rect2(300, 470, 660, 16), wall.darkened(0.4))
	for px in [320.0, 500.0, 760.0, 940.0]:
		ci.draw_rect(Rect2(px - 6, 486, 12, 80), wall.darkened(0.3))
	Paint.door(ci, Rect2(600, 330, 80, 140), Color(0.3, 0.22, 0.16))
	for k in 4:
		ci.draw_rect(Rect2(580 - k * 10, 566 + k * 20, 120 + k * 20, 20), wall.darkened(0.2 + k * 0.05))
	Paint.vgrad(ci, Rect2(0, 560, 1280, 160), Color(0.3, 0.28, 0.22) if day else Color(0.1, 0.1, 0.09), Color(0.2, 0.18, 0.14) if day else Color(0.05, 0.05, 0.05))
	Paint.floor_stains(ci, Rect2(0, 600, 1280, 100), Color(0.0, 0.0, 0.0, 0.3), 14, 3)


func draw_anim(ci: CanvasItem) -> void:
	if not day:
		Paint.rain(ci, Rect2(0, 0, 1280, 720), t, 170)
