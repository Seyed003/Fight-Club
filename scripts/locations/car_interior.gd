extends Location
## Inside Tyler's car at night in the rain, cut away from the side.
## Oncoming headlights stream past. `speed` drives the road animation.

var speed := 1.0
var swerve := 0.0


func _init() -> void:
	floor_y = 600.0
	ambient = Color(0.55, 0.56, 0.66)
	grade = "night"
	animated = true
	front_animated = true
	amb = "car_rain"
	amb_db = -6.0


func lights() -> Array:
	return [
		{"pos": Vector2(640, 380), "radius": 520.0, "color": Color(0.5, 0.6, 0.9), "energy": 0.45},
		{"pos": Vector2(1100, 330), "radius": 380.0, "color": Color(1.0, 0.95, 0.8), "energy": 0.5, "flicker": 0.4},
	]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.02, 0.03))


func draw_anim(ci: CanvasItem) -> void:
	# The road outside, seen through the windows.
	Paint.vgrad(ci, Rect2(0, 120, 1280, 330), Color(0.02, 0.03, 0.06), Color(0.08, 0.08, 0.1))
	var off := fmod(t * 900.0 * speed, 400.0)
	for i in 5:
		var x := 1280.0 - fposmod(i * 400.0 + off, 2000.0)
		ci.draw_rect(Rect2(x, 380, 120, 6), Color(0.9, 0.85, 0.5, 0.5))
	var cyc := fmod(t * speed, 2.6)
	if cyc < 1.0:
		var hx := lerpf(1500.0, -300.0, cyc)
		Paint.glow(ci, Vector2(hx, 360), 160, Color(1.0, 0.97, 0.85, 0.65))
		Paint.glow(ci, Vector2(hx + 90, 362), 140, Color(1.0, 0.97, 0.85, 0.55))
	Paint.rain(ci, Rect2(0, 120, 1280, 330), t, 90, Color(0.75, 0.8, 0.9, 0.35))


func draw_front(ci: CanvasItem) -> void:
	var tilt := sin(t * 1.7) * swerve * 0.05
	ci.draw_set_transform(Vector2(640, 400), tilt, Vector2.ONE)
	var o := Vector2(-640, -400)
	# Car body cut-away: roof, pillars, door panel, dashboard.
	Paint.poly(ci, [o + Vector2(0, 0), o + Vector2(1280, 0), o + Vector2(1280, 120), o + Vector2(0, 120)], Color(0.22, 0.2, 0.2))
	ci.draw_rect(Rect2(o + Vector2(0, 108), Vector2(1280, 14)), Color(0.4, 0.36, 0.32))
	Paint.poly(ci, [o + Vector2(0, 450), o + Vector2(1280, 450), o + Vector2(1280, 720), o + Vector2(0, 720)], Color(0.3, 0.24, 0.22))
	ci.draw_rect(Rect2(o + Vector2(0, 450), Vector2(1280, 12)), Color(0.45, 0.38, 0.32))
	for px in [70.0, 640.0, 1180.0]:
		ci.draw_rect(Rect2(o + Vector2(px - 24, 110), Vector2(48, 350)), Color(0.24, 0.22, 0.22))
	Paint.poly(ci, [o + Vector2(1180, 120), o + Vector2(1280, 120), o + Vector2(1280, 470), o + Vector2(1140, 470)], Color(0.2, 0.18, 0.18))
	# Seats: front pair and the back bench.
	for sx in [430.0, 760.0, 1030.0]:
		Paint.poly(ci, [o + Vector2(sx - 70, 600), o + Vector2(sx - 60, 330), o + Vector2(sx - 20, 320), o + Vector2(sx - 22, 600)], Color(0.36, 0.3, 0.28))
	ci.draw_rect(Rect2(o + Vector2(1040, 430), Vector2(180, 30)), Color(0.1, 0.1, 0.11))
	Paint.glow(ci, o + Vector2(1080, 440), 30, Color(0.3, 0.9, 0.6, 0.5))
	ci.draw_rect(Rect2(o + Vector2(0, 560), Vector2(1280, 8)), Color(0.2, 0.18, 0.17))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
