extends Location
## A projection booth: two projectors, the beam through the port window,
## the reels turning. Tyler's night job.

var running := true


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.5, 0.48, 0.46)
	grade = "warm"
	animated = true
	amb = "projector"
	amb_db = -8.0


func lights() -> Array:
	return [
		{"pos": Vector2(900, 330), "radius": 420.0, "color": Color(1.0, 0.95, 0.8), "energy": 0.9, "flicker": 0.25},
		{"pos": Vector2(300, 200), "radius": 300.0, "color": Color(1.0, 0.6, 0.3), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 720), Color(0.12, 0.11, 0.1))
	Paint.bricks(ci, Rect2(0, 0, 1280, 470), Color(0.2, 0.17, 0.15), Color(0.08, 0.07, 0.07), 60, 24, 6)
	ci.draw_rect(Rect2(1060, 280, 90, 60), Color(0.02, 0.02, 0.02))
	ci.draw_rect(Rect2(1060, 280, 90, 60), Color(0.3, 0.3, 0.3), false, 4.0)
	Paint.vgrad(ci, Rect2(0, 470, 1280, 250), Color(0.16, 0.15, 0.14), Color(0.08, 0.08, 0.08))
	# Film cans on a shelf.
	for i in 6:
		Paint.ellipse(ci, Vector2(120 + i * 50, 300), 22, 22, Color(0.45, 0.45, 0.46))
	ci.draw_rect(Rect2(80, 324, 320, 8), Color(0.3, 0.25, 0.2))


func _projector(ci: CanvasItem, base: Vector2, on: bool) -> void:
	ci.draw_rect(Rect2(base.x - 20, base.y - 200, 40, 200), Color(0.2, 0.22, 0.22))
	ci.draw_rect(Rect2(base.x - 90, base.y - 300, 210, 110), Color(0.28, 0.3, 0.3))
	ci.draw_rect(Rect2(base.x + 120, base.y - 270, 40, 40), Color(0.15, 0.15, 0.15))
	for k in 2:
		var c := base + Vector2(-40 + k * 110, -360 + k * 10)
		var a := t * (3.0 if on else 0.0) * (1 if k == 0 else -1)
		ci.draw_circle(c, 62, Color(0.18, 0.18, 0.2))
		ci.draw_circle(c, 56, Color(0.3, 0.3, 0.32))
		for s in 3:
			var d := Vector2.from_angle(a + s * TAU / 3.0)
			ci.draw_line(c, c + d * 50.0, Color(0.12, 0.12, 0.12), 6.0)
		ci.draw_circle(c, 10, Color(0.1, 0.1, 0.1))


func draw_anim(ci: CanvasItem) -> void:
	_projector(ci, Vector2(420, 650), false)
	_projector(ci, Vector2(880, 650), running)
	if running:
		var flick := 0.8 + 0.2 * sin(t * 48.0)
		Paint.light_cone(ci, Vector2(1040, 380), 1300.0, 70.0, Color(1.0, 0.97, 0.85, 0.0))
		Paint.poly(ci, [Vector2(1000, 380), Vector2(1060, 296), Vector2(1150, 290), Vector2(1150, 330)], Color(1.0, 0.97, 0.85, 0.14 * flick))
		Paint.glow(ci, Vector2(1010, 380), 50, Color(1.0, 0.97, 0.85, 0.6 * flick))
