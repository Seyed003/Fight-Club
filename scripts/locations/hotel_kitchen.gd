extends Location
## The banquet kitchen of the Pressman Hotel. Stainless steel and steam.


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.62, 0.66, 0.64)
	grade = "office"
	animated = true
	amb = "kitchen"
	amb_db = -14.0


func lights() -> Array:
	return [{"pos": Vector2(640, 90), "radius": 760.0, "color": Color(0.9, 1.0, 0.95), "energy": 0.55}]


func draw_static(ci: CanvasItem) -> void:
	for row in 14:
		for col in 30:
			ci.draw_rect(Rect2(col * 44, row * 34, 42, 32), Color(0.84, 0.86, 0.84).darkened(fmod(col * 0.013 + row * 0.02, 0.08)))
	for x in [140.0, 640.0, 1040.0]:
		Paint.fluorescent(ci, Rect2(x, 30, 160, 8))
	ci.draw_rect(Rect2(0, 470, 1280, 250), Color(0.4, 0.42, 0.42))
	Paint.counter(ci, Rect2(100, 470, 1080, 180), Color(0.78, 0.8, 0.82), Color(0.6, 0.62, 0.64))
	for i in 5:
		ci.draw_rect(Rect2(140 + i * 210, 330, 90, 16), Color(0.7, 0.72, 0.74))
		ci.draw_line(Vector2(185 + i * 210, 346), Vector2(185 + i * 210, 380), Color(0.5, 0.5, 0.5), 2.0)
		Paint.ellipse(ci, Vector2(185 + i * 210, 392), 20, 12, Color(0.75, 0.75, 0.78))


func draw_anim(ci: CanvasItem) -> void:
	for i in 4:
		Paint.pot(ci, Vector2(220 + i * 260, 470), 80, Color(0.72, 0.74, 0.76), t + i, true)
