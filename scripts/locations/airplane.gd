extends Location
## Economy class, aisle side. Single-serving everything.

var shake := 0.3


var seats := [470.0, 800.0]


func _init() -> void:
	floor_y = 660.0
	ambient = Color(0.5, 0.52, 0.54)
	grade = "office"
	animated = true
	front_animated = true
	amb = "plane_hum"
	amb_db = -8.0


func lights() -> Array:
	return [
		{"pos": Vector2(300, 380), "radius": 420.0, "color": Color(0.9, 0.95, 1.0), "energy": 0.75},
		{"pos": Vector2(700, 140), "radius": 600.0, "color": Color(1.0, 0.95, 0.85), "energy": 0.35},
	]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 720), Color(0.72, 0.72, 0.68))
	# Curved cabin wall and overhead bins.
	Paint.poly(ci, [Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 150), Vector2(0, 150)], Color(0.8, 0.8, 0.76))
	ci.draw_rect(Rect2(0, 150, 1280, 12), Color(0.55, 0.55, 0.52))
	for i in 5:
		ci.draw_line(Vector2(i * 300 + 20, 0), Vector2(i * 300 + 20, 150), Color(0.6, 0.6, 0.56), 2.0)
	Paint.vgrad(ci, Rect2(0, 162, 1280, 400), Color(0.7, 0.69, 0.64), Color(0.56, 0.55, 0.52))
	for i in 9:
		ci.draw_line(Vector2(i * 160 - 40, 162), Vector2(i * 160 - 40, 560), Color(0.5, 0.5, 0.47, 0.5), 2.0)
	Paint.vgrad(ci, Rect2(0, 560, 1280, 160), Color(0.3, 0.26, 0.3), Color(0.18, 0.16, 0.2))
	ci.draw_rect(Rect2(0, 556, 1280, 6), Color(0.42, 0.42, 0.42))
	for i in 14:
		ci.draw_line(Vector2(i * 100, 600), Vector2(i * 100 - 50, 720), Color(0, 0, 0, 0.12), 2.0)
	for sx in seats:
		Paint.plane_seat(ci, Vector2(sx - 40 if sx < 640.0 else sx + 40, 660), 1.55, Color(0.22, 0.28, 0.4), 1 if sx < 640.0 else -1)


func draw_anim(ci: CanvasItem) -> void:
	for wx in [140.0, 640.0, 1140.0]:
		var c := Vector2(wx, 330)
		Paint.ellipse(ci, c, 70, 96, Color(0.55, 0.55, 0.52))
		Paint.ellipse(ci, c, 56, 82, Color(0.3, 0.45, 0.7))
		var off := fmod(t * 40.0, 200.0)
		for k in 3:
			Paint.ellipse(ci, c + Vector2(fposmod(k * 70.0 - off, 140.0) - 70, 30 + k * 12), 40, 12, Color(0.92, 0.94, 0.96, 0.8))
		Paint.ellipse(ci, c + Vector2(-14, -30), 18, 40, Color(1, 1, 1, 0.12))


func draw_front(ci: CanvasItem) -> void:
	# Seat backs in the row ahead.
	Paint.plane_seat(ci, Vector2(1140, 720), 1.6, Color(0.24, 0.3, 0.42))
	Paint.plane_seat(ci, Vector2(60, 720), 1.6, Color(0.24, 0.3, 0.42))
