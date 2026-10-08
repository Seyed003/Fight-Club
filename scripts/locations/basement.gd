extends Location
## The basement under Lou's Tavern: one bulb, wet brick, a ring of men.

var excite := 0.3


func _init() -> void:
	floor_y = 610.0
	ambient = Color(0.30, 0.32, 0.31)
	grade = "warm"
	animated = true
	front_animated = true
	amb = "crowd_murmur"
	amb_db = -10.0


func lights() -> Array:
	return [
		{"pos": Vector2(640, 175), "radius": 540.0, "color": Color(1.0, 0.82, 0.55), "energy": 1.5, "flicker": 0.08, "swing": 0.16, "swing_speed": 1.1, "length": 115.0},
		{"pos": Vector2(640, 430), "radius": 380.0, "color": Color(1.0, 0.84, 0.6), "energy": 0.55, "swing": 0.16, "swing_speed": 1.1, "length": 115.0},
		{"pos": Vector2(120, 260), "radius": 260.0, "color": Color(0.55, 0.75, 0.6), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.10, 0.09, 0.08), Color(0.05, 0.05, 0.05))
	Paint.bricks(ci, Rect2(0, 40, 1280, 440), Color(0.24, 0.15, 0.12), Color(0.09, 0.08, 0.07), 58, 23, 4)
	Paint.grime(ci, Rect2(0, 40, 1280, 440), Color(0.05, 0.06, 0.04, 0.55), 21, 16)
	# Pipes and ducts along the ceiling.
	ci.draw_rect(Rect2(0, 0, 1280, 48), Color(0.07, 0.07, 0.07))
	for y in [58.0, 78.0]:
		ci.draw_line(Vector2(0, y), Vector2(1280, y + 6), Color(0.18, 0.2, 0.19), 9.0)
		ci.draw_line(Vector2(0, y - 3), Vector2(1280, y + 3), Color(0.30, 0.32, 0.30), 2.0)
	for x in [180.0, 520.0, 980.0]:
		ci.draw_rect(Rect2(x, 48, 14, 40), Color(0.14, 0.15, 0.14))
	# Concrete floor.
	Paint.vgrad(ci, Rect2(0, 470, 1280, 250), Color(0.20, 0.19, 0.17), Color(0.10, 0.10, 0.09))
	Paint.floor_stains(ci, Rect2(80, 520, 1120, 180), Color(0.06, 0.05, 0.04, 0.5), 18, 8)
	Paint.floor_stains(ci, Rect2(380, 560, 520, 90), Color(0.25, 0.03, 0.03, 0.35), 6, 31)
	ci.draw_line(Vector2(0, 470), Vector2(1280, 470), Color(0.06, 0.06, 0.05), 3.0)
	# Back row of the crowd, half in darkness.
	Paint.crowd(ci, 470, 30, 1250, 22, Color(0.09, 0.08, 0.08), 0.0, 5, 0.95)


func draw_anim(ci: CanvasItem) -> void:
	var light: Dictionary = lights()[0]
	var anchor := Vector2(640, 48)
	var swing := sin(t * float(light["swing_speed"])) * float(light["swing"])
	var bulb := Paint.bulb(ci, anchor, 115.0, swing, true)
	Paint.light_cone(ci, bulb, 640.0, 360.0, Color(1.0, 0.86, 0.6, 0.07))
	Paint.glow_ellipse(ci, Vector2(bulb.x, 600), 380, 70, Color(1.0, 0.85, 0.6, 0.18))
	Paint.crowd(ci, 500, 60, 1220, 16, Color(0.12, 0.11, 0.10), t, 7, 1.05, excite * 0.6)


func draw_front(ci: CanvasItem) -> void:
	# Front row: backs of heads and shoulders, out of focus.
	Paint.crowd(ci, 770, -40, 1320, 9, Color(0.03, 0.03, 0.03), t, 13, 1.9, excite)
