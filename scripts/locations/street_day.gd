extends Location
## A city sidewalk by day: storefronts, a hydrant, people passing.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.8, 0.8, 0.76)
	grade = "normal"
	front_animated = true
	amb = "city_day"
	amb_db = -12.0


func lights() -> Array:
	return []


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 300), Color(0.62, 0.68, 0.72), Color(0.8, 0.8, 0.78))
	Paint.skyline(ci, Rect2(0, 20, 1280, 260), false, 61, 0.0)
	ci.draw_rect(Rect2(0, 240, 1280, 320), Color(0.55, 0.5, 0.44))
	for i in 4:
		var x := 40 + i * 320
		ci.draw_rect(Rect2(x, 330, 240, 200), Color(0.5, 0.62, 0.68, 0.7))
		ci.draw_rect(Rect2(x, 330, 240, 200), Color(0.3, 0.26, 0.22), false, 6.0)
		ci.draw_rect(Rect2(x, 290, 240, 34), [Color(0.5, 0.15, 0.12), Color(0.15, 0.3, 0.2), Color(0.2, 0.22, 0.4), Color(0.45, 0.35, 0.12)][i])
	Paint.vgrad(ci, Rect2(0, 530, 1280, 120), Color(0.62, 0.6, 0.56), Color(0.52, 0.5, 0.47))
	var x2 := 0.0
	while x2 < 1280.0:
		ci.draw_line(Vector2(x2, 530), Vector2(x2 - 30, 650), Color(0, 0, 0, 0.1), 2.0)
		x2 += 110.0
	ci.draw_rect(Rect2(0, 650, 1280, 70), Color(0.3, 0.3, 0.3))
	ci.draw_rect(Rect2(1010, 590, 30, 50), Color(0.75, 0.15, 0.1))
	Paint.ellipse(ci, Vector2(1025, 588), 18, 8, Color(0.8, 0.2, 0.15))


func draw_front(ci: CanvasItem) -> void:
	var cyc := fmod(t, 5.0)
	var x := lerpf(1500.0, -300.0, cyc / 5.0)
	Paint.car_side(ci, Vector2(x, 712), Color(0.6, 0.55, 0.2), 1.2, -1)
