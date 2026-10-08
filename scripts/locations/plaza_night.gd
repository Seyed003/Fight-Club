extends Location
## A corporate plaza at night: a giant steel sphere on a plinth, a glass
## tower, and a franchise coffee bar. `roll` > 0 sends the sphere rolling.

var roll := 0.0
var _x := 420.0
var _rot := 0.0


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.36, 0.4, 0.46)
	grade = "night"
	animated = true
	amb = "night_city"
	amb_db = -14.0


func lights() -> Array:
	return [
		{"pos": Vector2(420, 250), "radius": 420.0, "color": Color(0.85, 0.9, 1.0), "energy": 0.6},
		{"pos": Vector2(1030, 420), "radius": 360.0, "color": Color(1.0, 0.8, 0.5), "energy": 0.7},
	]


func update(delta: float) -> void:
	t += delta
	if roll > 0.0 and _x < 1060.0:
		var v := 120.0 + (_x - 420.0) * 1.4
		_x += v * delta
		_rot += v * delta / 150.0


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.06), Color(0.07, 0.08, 0.1))
	ci.draw_rect(Rect2(100, 0, 600, 520), Color(0.1, 0.13, 0.17))
	var y := 10.0
	while y < 520.0:
		ci.draw_line(Vector2(100, y), Vector2(700, y), Color(0.2, 0.28, 0.36), 2.0)
		y += 26.0
	var x := 100.0
	while x < 700.0:
		ci.draw_line(Vector2(x, 0), Vector2(x, 520), Color(0.16, 0.22, 0.28), 2.0)
		x += 60.0
	ci.draw_rect(Rect2(880, 380, 320, 160), Color(0.75, 0.55, 0.32, 0.6))
	ci.draw_rect(Rect2(880, 380, 320, 160), Color(0.2, 0.12, 0.08), false, 6.0)
	Paint.sign_box(ci, Rect2(880, 330, 320, 46), "COFFEE · GLOBAL BRAND", Color(0.12, 0.3, 0.22), Color(0.95, 0.92, 0.85), 20)
	for i in 3:
		Paint.table(ci, Rect2(910 + i * 100, 470, 70, 70), Color(0.3, 0.2, 0.12), Color(0.2, 0.14, 0.1))
	Paint.vgrad(ci, Rect2(0, 540, 1280, 180), Color(0.22, 0.22, 0.24), Color(0.12, 0.12, 0.13))
	ci.draw_rect(Rect2(320, 480, 200, 60), Color(0.3, 0.3, 0.32))


func draw_anim(ci: CanvasItem) -> void:
	var y := 480.0 - 150.0 if _x < 540.0 else 540.0 - 150.0
	var c := Vector2(_x, y)
	ci.draw_circle(c, 150, Color(0.34, 0.36, 0.4))
	ci.draw_circle(c + Vector2(-40, -40), 90, Color(0.48, 0.5, 0.55))
	ci.draw_circle(c + Vector2(-60, -60), 30, Color(0.7, 0.72, 0.76))
	for i in 4:
		var a := _rot + i * PI * 0.5
		ci.draw_line(c + Vector2.from_angle(a) * 60.0, c + Vector2.from_angle(a) * 148.0, Color(0.24, 0.26, 0.3), 3.0)
