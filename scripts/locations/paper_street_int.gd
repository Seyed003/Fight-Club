extends Location
## Inside the Paper Street house: peeling wallpaper, rain coming through,
## buckets catching it, stacks of old magazines, one bare bulb.


func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.4, 0.38, 0.33)
	grade = "warm"
	animated = true
	amb = "drip"
	amb_db = -12.0


func lights() -> Array:
	return [
		{"pos": Vector2(640, 220), "radius": 560.0, "color": Color(1.0, 0.78, 0.45), "energy": 1.0, "flicker": 0.18, "swing": 0.06, "swing_speed": 0.7, "length": 130.0},
		{"pos": Vector2(1060, 240), "radius": 260.0, "color": Color(0.6, 0.7, 0.9), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.wallpaper(ci, Rect2(0, 0, 1280, 480), Color(0.46, 0.4, 0.3), Color(0.42, 0.34, 0.26), 1.0, 19)
	ci.draw_rect(Rect2(0, 440, 1280, 40), Color(0.25, 0.18, 0.12))
	Paint.window(ci, Rect2(980, 120, 160, 220), Color(0.05, 0.06, 0.1), Color(0.1, 0.1, 0.14), Color(0.25, 0.18, 0.12), false, false)
	Paint.poly(ci, [Vector2(990, 130), Vector2(1080, 130), Vector2(1000, 250)], Color(0.2, 0.2, 0.22, 0.6))
	Paint.door(ci, Rect2(80, 200, 120, 280), Color(0.3, 0.22, 0.15))
	Paint.vgrad(ci, Rect2(0, 480, 1280, 240), Color(0.28, 0.2, 0.14), Color(0.14, 0.1, 0.08))
	var x := -100.0
	while x < 1400.0:
		ci.draw_line(Vector2(x, 480), Vector2(x - 60, 720), Color(0, 0, 0, 0.2), 3.0)
		x += 70.0
	Paint.floor_stains(ci, Rect2(0, 500, 1280, 200), Color(0.05, 0.06, 0.05, 0.5), 14, 21)
	# Couch, magazines, buckets.
	Paint.sofa(ci, Vector2(300, 640), 260, Color(0.3, 0.26, 0.2))
	for i in 3:
		for k in 6:
			ci.draw_rect(Rect2(880 + i * 60, 620 - k * 9, 50, 8), Color(0.75, 0.7, 0.58).darkened(fmod(k * 0.13 + i * 0.07, 0.3)))
	for bx in [700.0, 1180.0]:
		Paint.poly(ci, [Vector2(bx - 22, 600), Vector2(bx + 22, 600), Vector2(bx + 18, 640), Vector2(bx - 18, 640)], Color(0.5, 0.5, 0.48))


func draw_anim(ci: CanvasItem) -> void:
	var light: Dictionary = lights()[0]
	var swing := sin(t * float(light["swing_speed"])) * float(light["swing"])
	Paint.bulb(ci, Vector2(640, 0), 205.0, swing, fmod(t * 5.3, 9.0) > 0.15)
	for bx in [700.0, 1180.0]:
		var phase := fmod(t * 1.3 + bx * 0.01, 1.0)
		ci.draw_circle(Vector2(bx, lerpf(0.0, 600.0, phase)), 2.5, Color(0.7, 0.8, 0.9, 0.7))
