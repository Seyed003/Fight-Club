extends Location
## A wet street at night: a laundromat, a payphone, cars hissing past.

var traffic := true


func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.42, 0.45, 0.52)
	grade = "night"
	animated = true
	front_animated = true
	amb = "rain"
	amb_db = -10.0


func lights() -> Array:
	return [
		{"pos": Vector2(820, 300), "radius": 420.0, "color": Color(1.0, 0.82, 0.55), "energy": 0.85},
		{"pos": Vector2(330, 420), "radius": 360.0, "color": Color(0.6, 0.85, 1.0), "energy": 0.6, "flicker": 0.1},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.03, 0.04, 0.07), Color(0.08, 0.09, 0.12))
	Paint.skyline(ci, Rect2(0, 40, 1280, 220), true, 3, 0.15)
	# Storefronts.
	ci.draw_rect(Rect2(0, 220, 1280, 330), Color(0.16, 0.14, 0.14))
	Paint.bricks(ci, Rect2(0, 220, 1280, 330), Color(0.2, 0.15, 0.13), Color(0.1, 0.09, 0.09), 50, 20, 9)
	ci.draw_rect(Rect2(140, 330, 400, 200), Color(0.55, 0.7, 0.75, 0.55))
	for i in 5:
		Paint.ellipse(ci, Vector2(190 + i * 76, 470), 30, 30, Color(0.8, 0.82, 0.84))
		Paint.ellipse(ci, Vector2(190 + i * 76, 470), 20, 20, Color(0.3, 0.4, 0.45))
	ci.draw_rect(Rect2(140, 330, 400, 200), Color(0.1, 0.1, 0.1), false, 6.0)
	Paint.neon(ci, Vector2(200, 310), "WASH & DRY", Color(0.4, 0.85, 1.0), 34)
	ci.draw_rect(Rect2(680, 360, 240, 170), Color(0.08, 0.08, 0.09))
	Paint.neon(ci, Vector2(700, 340), "LIQUOR", Color(1.0, 0.3, 0.3), 30)
	Paint.door(ci, Rect2(990, 360, 100, 170), Color(0.22, 0.2, 0.2))
	# Sidewalk and road.
	Paint.vgrad(ci, Rect2(0, 530, 1280, 120), Color(0.2, 0.2, 0.22), Color(0.15, 0.15, 0.17))
	ci.draw_rect(Rect2(0, 646, 1280, 8), Color(0.3, 0.3, 0.3))
	Paint.vgrad(ci, Rect2(0, 654, 1280, 66), Color(0.06, 0.06, 0.07), Color(0.03, 0.03, 0.04))
	Paint.phone_booth(ci, Vector2(70, 640))
	Paint.streetlight(ci, Vector2(780, 646), 340, true)
	# Reflections on the wet pavement.
	Paint.glow_ellipse(ci, Vector2(340, 600), 220, 20, Color(0.4, 0.85, 1.0, 0.2))
	Paint.glow_ellipse(ci, Vector2(800, 610), 200, 22, Color(1.0, 0.3, 0.3, 0.15))


func draw_anim(ci: CanvasItem) -> void:
	Paint.rain(ci, Rect2(0, 0, 1280, 720), t, 150)


func draw_front(ci: CanvasItem) -> void:
	if not traffic:
		return
	var cycle := fmod(t, 7.0)
	if cycle < 1.4:
		var x := lerpf(-400.0, 1700.0, cycle / 1.4)
		Paint.car_side(ci, Vector2(x, 712), Color(0.12, 0.12, 0.14), 1.3, 1)
		Paint.glow(ci, Vector2(x + 170, 680), 120, Color(1.0, 0.95, 0.8, 0.5))
