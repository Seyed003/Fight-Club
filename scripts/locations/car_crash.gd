extends Location
## A ditch by the road, rain, the car on its roof, headlights still on.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.5, 0.52, 0.6)
	grade = "night"
	animated = true
	amb = "rain"
	amb_db = -8.0


func lights() -> Array:
	return [
		{"pos": Vector2(300, 520), "radius": 520.0, "color": Color(1.0, 0.95, 0.8), "energy": 0.7},
		{"pos": Vector2(1000, 200), "radius": 400.0, "color": Color(0.6, 0.7, 1.0), "energy": 0.3},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.05), Color(0.05, 0.06, 0.08))
	Paint.poly(ci, [Vector2(0, 380), Vector2(1280, 300), Vector2(1280, 340), Vector2(0, 420)], Color(0.12, 0.12, 0.13))
	ci.draw_line(Vector2(0, 400), Vector2(1280, 320), Color(0.8, 0.8, 0.7, 0.4), 3.0)
	Paint.poly(ci, [Vector2(0, 420), Vector2(1280, 340), Vector2(1280, 720), Vector2(0, 720)], Color(0.1, 0.11, 0.08))
	Paint.floor_stains(ci, Rect2(0, 560, 1280, 160), Color(0.05, 0.05, 0.03, 0.6), 18, 12)
	# The overturned car.
	var c := Vector2(640, 610)
	Paint.poly(ci, [c + Vector2(-210, -40), c + Vector2(-180, 10), c + Vector2(-80, 30), c + Vector2(90, 30), c + Vector2(170, 6), c + Vector2(220, -40), c + Vector2(210, -110), c + Vector2(-200, -110)], Color(0.36, 0.38, 0.44))
	ci.draw_line(c + Vector2(-200, -60), c + Vector2(210, -60), Color(0.6, 0.62, 0.66), 3.0)
	Paint.poly(ci, [c + Vector2(-100, 30), c + Vector2(80, 30), c + Vector2(60, 70), c + Vector2(-80, 70)], Color(0.12, 0.13, 0.15))
	for wx in [-130.0, 140.0]:
		ci.draw_circle(c + Vector2(wx, -120), 32, Color(0.05, 0.05, 0.05))
	for i in 20:
		var a := i * 0.9
		Paint.poly(ci, [c + Vector2(cos(a) * 220 - 60, 60 + sin(a) * 8), c + Vector2(cos(a) * 220 - 50, 64), c + Vector2(cos(a) * 220 - 56, 68)], Color(0.7, 0.85, 0.95, 0.5))


func draw_anim(ci: CanvasItem) -> void:
	Paint.light_cone(ci, Vector2(440, 590), 720.0, 160.0, Color(1.0, 0.96, 0.8, 0.0))
	Paint.poly(ci, [Vector2(430, 585), Vector2(430, 610), Vector2(0, 700), Vector2(0, 520)], Color(1.0, 0.96, 0.8, 0.08))
	Paint.glow(ci, Vector2(430, 598), 40, Color(1.0, 0.96, 0.8, 0.8))
	for k in 3:
		var y := fposmod(-t * 40.0 - k * 60.0, 180.0)
		Paint.glow_ellipse(ci, Vector2(760 + k * 20, 500 - y), 60, 30, Color(0.8, 0.8, 0.8, 0.12))
	Paint.rain(ci, Rect2(0, 0, 1280, 720), t, 170)
