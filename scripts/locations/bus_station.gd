extends Location
## A bus terminal at night. The bus idles at the curb.

var bus := true


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.44, 0.46, 0.5)
	grade = "night"
	animated = true
	amb = "night_city"
	amb_db = -12.0


func lights() -> Array:
	return [{"pos": Vector2(640, 120), "radius": 760.0, "color": Color(0.9, 1.0, 0.92), "energy": 0.5, "flicker": 0.06}]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.04, 0.05, 0.07), Color(0.1, 0.1, 0.12))
	ci.draw_rect(Rect2(0, 0, 1280, 60), Color(0.3, 0.32, 0.32))
	for x in [200.0, 600.0, 1000.0]:
		Paint.fluorescent(ci, Rect2(x, 56, 150, 8))
	for x in [60.0, 640.0, 1220.0]:
		ci.draw_rect(Rect2(x - 12, 60, 24, 590), Color(0.34, 0.36, 0.36))
	Paint.sign_box(ci, Rect2(860, 100, 300, 60), "DEPARTURES", Color(0.06, 0.06, 0.07), Color(1.0, 0.75, 0.3), 26)
	Paint.vgrad(ci, Rect2(0, 560, 1280, 160), Color(0.3, 0.3, 0.3), Color(0.15, 0.15, 0.16))
	ci.draw_rect(Rect2(80, 590, 260, 12), Color(0.35, 0.25, 0.2))
	ci.draw_rect(Rect2(90, 602, 10, 40), Color(0.2, 0.2, 0.2))
	ci.draw_rect(Rect2(320, 602, 10, 40), Color(0.2, 0.2, 0.2))


func draw_anim(ci: CanvasItem) -> void:
	if not bus:
		return
	var b := Rect2(440, 300, 800, 300)
	ci.draw_rect(b, Color(0.72, 0.74, 0.76))
	ci.draw_rect(Rect2(b.position.x, b.position.y + 150, b.size.x, 30), Color(0.2, 0.3, 0.6))
	for i in 7:
		ci.draw_rect(Rect2(b.position.x + 40 + i * 106, b.position.y + 30, 90, 90), Color(0.15, 0.2, 0.24))
	ci.draw_rect(Rect2(b.position.x + 20, b.position.y + 30, 60, 230), Color(0.2, 0.25, 0.28))
	for wx in [560.0, 1120.0]:
		ci.draw_circle(Vector2(wx, 600), 40, Color(0.05, 0.05, 0.05))
	Paint.glow_ellipse(ci, Vector2(1240, 560), 60, 30, Color(0.6, 0.6, 0.6, 0.2 + 0.1 * sin(t * 3.0)))
