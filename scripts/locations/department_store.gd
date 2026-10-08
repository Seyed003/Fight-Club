extends Location
## A department store cosmetics counter. Bright, glossy, pink soap at $20.


func _init() -> void:
	floor_y = 660.0
	ambient = Color(0.78, 0.76, 0.76)
	grade = "normal"
	amb = "mall"
	amb_db = -16.0


func lights() -> Array:
	return [{"pos": Vector2(640, 120), "radius": 800.0, "color": Color(1.0, 0.97, 0.92), "energy": 0.45}]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 470), Color(0.86, 0.84, 0.82), Color(0.76, 0.74, 0.72))
	for i in 4:
		ci.draw_rect(Rect2(80 + i * 300, 80, 220, 260), Color(0.95, 0.95, 0.94))
		ci.draw_rect(Rect2(80 + i * 300, 80, 220, 260), Color(0.7, 0.62, 0.5), false, 6.0)
		Paint.poly(ci, [Vector2(100 + i * 300, 90), Vector2(150 + i * 300, 90), Vector2(110 + i * 300, 330), Vector2(90 + i * 300, 330)], Color(1, 1, 1, 0.5))
	Paint.sign_box(ci, Rect2(440, 30, 400, 40), "BEAUTY", Color(0.15, 0.12, 0.12), Color(0.95, 0.8, 0.85), 24)
	Paint.vgrad(ci, Rect2(0, 470, 1280, 250), Color(0.9, 0.88, 0.86), Color(0.7, 0.68, 0.66))
	Paint.counter(ci, Rect2(200, 470, 880, 200), Color(0.95, 0.95, 0.95), Color(0.3, 0.26, 0.28))
	ci.draw_rect(Rect2(220, 490, 840, 80), Color(0.8, 0.9, 0.95, 0.35))
	for i in 12:
		var x := 250.0 + i * 66.0
		Paint.poly(ci, [Vector2(x, 548), Vector2(x + 44, 548), Vector2(x + 46, 566), Vector2(x - 2, 566)], Color(0.96, 0.66, 0.74))
	Paint.sign_box(ci, Rect2(560, 430, 160, 34), "$20", Color(0.98, 0.96, 0.94), Color(0.6, 0.2, 0.3), 24)
