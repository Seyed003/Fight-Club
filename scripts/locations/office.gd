extends Location
## Open-plan office under fluorescent tubes. Everything is a copy of a
## copy of a copy.

func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.62, 0.66, 0.62)
	grade = "office"
	animated = true
	amb = "fluorescent"
	amb_db = -14.0


func lights() -> Array:
	return [
		{"pos": Vector2(320, 80), "radius": 520.0, "color": Color(0.85, 1.0, 0.9), "energy": 0.5, "flicker": 0.15},
		{"pos": Vector2(960, 80), "radius": 520.0, "color": Color(0.85, 1.0, 0.9), "energy": 0.5},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 480), Color(0.58, 0.6, 0.55), Color(0.5, 0.52, 0.47))
	ci.draw_rect(Rect2(0, 0, 1280, 70), Color(0.72, 0.72, 0.68))
	var x := 0.0
	while x < 1280.0:
		ci.draw_line(Vector2(x, 0), Vector2(x, 70), Color(0.6, 0.6, 0.56), 2.0)
		x += 80.0
	Paint.window(ci, Rect2(860, 110, 300, 170), Color(0.62, 0.68, 0.72), Color(0.8, 0.82, 0.8), Color(0.4, 0.42, 0.4), true, true)
	# Far row of cubicles.
	for i in 6:
		Paint.cubicle(ci, -40 + i * 220, 480, 200, Color(0.46, 0.5, 0.52), i % 2 == 0)
	Paint.vgrad(ci, Rect2(0, 480, 1280, 240), Color(0.36, 0.38, 0.38), Color(0.26, 0.28, 0.28))
	Paint.floor_stains(ci, Rect2(0, 500, 1280, 200), Color(0, 0, 0, 0.08), 10, 4)
	# Copier and water cooler.
	ci.draw_rect(Rect2(1080, 470, 150, 140), Color(0.78, 0.78, 0.74))
	ci.draw_rect(Rect2(1070, 456, 170, 18), Color(0.7, 0.7, 0.66))
	ci.draw_rect(Rect2(1100, 500, 110, 10), Color(0.3, 0.3, 0.3))
	ci.draw_rect(Rect2(40, 470, 50, 150), Color(0.85, 0.86, 0.84))
	Paint.ellipse(ci, Vector2(65, 440), 26, 34, Color(0.6, 0.78, 0.9, 0.8))


func draw_anim(ci: CanvasItem) -> void:
	for i in 4:
		var on := not (i == 1 and fmod(t * 3.7, 5.0) < 0.12)
		Paint.fluorescent(ci, Rect2(90 + i * 300, 62, 170, 9), on)
	# Copier light sweeping.
	var sweep := fmod(t * 0.6, 3.0)
	if sweep < 1.0:
		ci.draw_rect(Rect2(1086 + sweep * 130, 458, 8, 14), Color(0.8, 1.0, 0.85, 0.9))


func draw_front(ci: CanvasItem) -> void:
	# The narrator's own desk in the foreground.
	Paint.counter(ci, Rect2(420, 540, 340, 180), Color(0.55, 0.53, 0.48), Color(0.4, 0.39, 0.36))
	Paint.monitor(ci, Vector2(640, 540), 1.2, true)
	ci.draw_rect(Rect2(470, 520, 70, 20), Color(0.9, 0.9, 0.86))
	ci.draw_rect(Rect2(700, 508, 16, 30), Color(0.92, 0.92, 0.88))
