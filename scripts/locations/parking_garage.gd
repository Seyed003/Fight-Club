extends Location
## Level P2 under a credit card company's tower. A white van, fluorescent
## tubes, a security camera watching everything.

var van := true


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.4, 0.44, 0.42)
	grade = "cold"
	animated = true
	amb = "garage_hum"
	amb_db = -12.0


func lights() -> Array:
	return [
		{"pos": Vector2(360, 120), "radius": 520.0, "color": Color(0.85, 1.0, 0.9), "energy": 0.6, "flicker": 0.08},
		{"pos": Vector2(960, 120), "radius": 520.0, "color": Color(0.85, 1.0, 0.9), "energy": 0.5, "flicker": 0.2},
	]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 720), Color(0.3, 0.31, 0.3))
	ci.draw_rect(Rect2(0, 0, 1280, 90), Color(0.24, 0.25, 0.24))
	for x in [0.0, 420.0, 840.0, 1260.0]:
		ci.draw_rect(Rect2(x - 40, 90, 80, 30), Color(0.27, 0.28, 0.27))
	for x in [220.0, 640.0, 1060.0]:
		ci.draw_rect(Rect2(x - 36, 90, 72, 560), Color(0.42, 0.42, 0.4))
		ci.draw_rect(Rect2(x - 36, 380, 72, 26), Color(0.85, 0.75, 0.2))
		Paint.text(ci, Vector2(x - 20, 220), "P2", 34, Color(0.15, 0.15, 0.15))
	ci.draw_rect(Rect2(1010, 140, 40, 22), Color(0.12, 0.12, 0.12))
	ci.draw_line(Vector2(1050, 150), Vector2(1060, 120), Color(0.12, 0.12, 0.12), 4.0)
	Paint.vgrad(ci, Rect2(0, 520, 1280, 200), Color(0.26, 0.26, 0.25), Color(0.16, 0.16, 0.16))
	for x in [120.0, 520.0, 920.0]:
		ci.draw_line(Vector2(x, 560), Vector2(x - 40, 720), Color(0.9, 0.9, 0.8, 0.4), 6.0)
	Paint.floor_stains(ci, Rect2(0, 560, 1280, 150), Color(0.08, 0.08, 0.06, 0.45), 14, 17)


func draw_anim(ci: CanvasItem) -> void:
	for i in 3:
		var on := not (i == 2 and fmod(t * 2.3, 4.0) < 0.3)
		Paint.fluorescent(ci, Rect2(260 + i * 380, 96, 200, 9), on)
	ci.draw_circle(Vector2(1030, 151), 4, Color(1, 0.1, 0.1) if fmod(t, 1.0) < 0.5 else Color(0.3, 0, 0))
	if van:
		Paint.van(ci, Vector2(820, 640), Color(0.88, 0.88, 0.86), -1, 1.6)
