extends Location
## Behind a liposuction clinic, after midnight. Red bags in the dumpster.

var sweep := true


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.3, 0.33, 0.4)
	grade = "night"
	animated = true
	amb = "night_city"
	amb_db = -16.0


func lights() -> Array:
	return [{"pos": Vector2(300, 260), "radius": 420.0, "color": Color(0.8, 0.95, 1.0), "energy": 0.7, "flicker": 0.1}]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.05), Color(0.06, 0.06, 0.08))
	ci.draw_rect(Rect2(0, 120, 900, 420), Color(0.62, 0.6, 0.56))
	ci.draw_rect(Rect2(0, 120, 900, 18), Color(0.4, 0.4, 0.38))
	Paint.sign_box(ci, Rect2(80, 170, 440, 60), "BEVERLY HILLS LIPO CLINIC", Color(0.9, 0.9, 0.9), Color(0.2, 0.3, 0.5), 24)
	Paint.door(ci, Rect2(620, 330, 100, 210), Color(0.5, 0.52, 0.55), true)
	ci.draw_rect(Rect2(270, 240, 60, 14), Color(0.3, 0.3, 0.3))
	Paint.fence(ci, 540, 900, 1280, 220, Color(0.5, 0.5, 0.52, 0.8))
	Paint.vgrad(ci, Rect2(0, 540, 1280, 180), Color(0.14, 0.14, 0.15), Color(0.07, 0.07, 0.08))
	Paint.dumpster(ci, Vector2(400, 560), Color(0.2, 0.32, 0.24))
	for i in 5:
		Paint.ellipse(ci, Vector2(330 + i * 34, 432 - (i % 2) * 8), 22, 18, Color(0.7, 0.08, 0.08))
	Paint.poly(ci, [Vector2(282, 300), Vector2(340, 254), Vector2(520, 252), Vector2(500, 300)], Color(0.92, 0.95, 1.0, 0.18))


func draw_anim(ci: CanvasItem) -> void:
	if sweep:
		var x := 1000.0 + sin(t * 0.7) * 220.0
		Paint.light_cone(ci, Vector2(1100, 80), 680.0, 160.0, Color(1, 1, 0.9, 0.0))
		Paint.glow_ellipse(ci, Vector2(x, 640), 140, 40, Color(1.0, 1.0, 0.9, 0.3))
