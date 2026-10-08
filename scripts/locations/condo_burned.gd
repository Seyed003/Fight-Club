extends Location
## The narrator's building the night of the explosion: his floor gutted,
## firefighters' lights washing the street.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.36, 0.38, 0.44)
	grade = "night"
	animated = true
	amb = "siren"
	amb_db = -16.0


func lights() -> Array:
	return [
		{"pos": Vector2(640, 220), "radius": 520.0, "color": Color(1.0, 0.5, 0.2), "energy": 0.8, "flicker": 0.3},
		{"pos": Vector2(1000, 560), "radius": 420.0, "color": Color(1.0, 0.2, 0.2), "energy": 0.5},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.06), Color(0.1, 0.08, 0.1))
	var b := Rect2(360, 0, 560, 560)
	ci.draw_rect(b, Color(0.3, 0.3, 0.32))
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	for row in 9:
		for col in 7:
			var r := Rect2(b.position.x + 24 + col * 76, 20 + row * 60, 50, 38)
			var lit := rng.randf() < 0.3
			ci.draw_rect(r, Color(1.0, 0.86, 0.6, 0.8) if lit else Color(0.1, 0.12, 0.16))
	# The gutted floor.
	ci.draw_rect(Rect2(b.position.x, 200, b.size.x, 70), Color(0.05, 0.03, 0.02))
	Paint.grime(ci, Rect2(b.position.x, 120, b.size.x, 160), Color(0, 0, 0, 0.8), 3, 18)
	ci.draw_rect(Rect2(0, 560, 1280, 160), Color(0.14, 0.14, 0.15))
	ci.draw_rect(Rect2(0, 556, 1280, 6), Color(0.3, 0.3, 0.3))
	ci.draw_rect(Rect2(540, 430, 200, 130), Color(0.7, 0.62, 0.4, 0.4))
	ci.draw_rect(Rect2(540, 430, 200, 130), Color(0.15, 0.15, 0.15), false, 5.0)
	Paint.floor_stains(ci, Rect2(100, 580, 1080, 120), Color(0.04, 0.04, 0.04, 0.6), 14, 9)
	for i in 30:
		ci.draw_rect(Rect2(rng.randf_range(300, 1000), rng.randf_range(600, 700), rng.randf_range(4, 18), rng.randf_range(3, 8)), Color(0.2, 0.18, 0.16))
	# Police tape.
	ci.draw_line(Vector2(0, 600), Vector2(1280, 590), Color(0.95, 0.85, 0.2), 7.0)


func draw_anim(ci: CanvasItem) -> void:
	for i in 6:
		Paint.glow(ci, Vector2(400 + i * 95, 236 + sin(t * 5.0 + i) * 8), 60 + sin(t * 9.0 + i * 2.0) * 14, Color(1.0, 0.45, 0.1, 0.55))
	var rise := fmod(t * 25.0, 240.0)
	for k in 3:
		Paint.glow_ellipse(ci, Vector2(640 + sin(t * 0.5 + k) * 40, 180 - rise - k * 60), 260, 90, Color(0.15, 0.14, 0.14, 0.5))
	var blink := fmod(t, 0.8) < 0.4
	Paint.glow(ci, Vector2(1100, 520), 160, Color(1.0, 0.1, 0.1, 0.45) if blink else Color(0.2, 0.3, 1.0, 0.45))
	ci.draw_rect(Rect2(1000, 470, 280, 110), Color(0.55, 0.06, 0.06))
	ci.draw_rect(Rect2(1010, 480, 80, 40), Color(0.3, 0.35, 0.4))
	ci.draw_circle(Vector2(1050, 585), 24, Color(0.05, 0.05, 0.05))
	ci.draw_circle(Vector2(1220, 585), 24, Color(0.05, 0.05, 0.05))
