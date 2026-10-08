extends Location
## The Paper Street kitchen, where the soap gets made.

var steam := true


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.42, 0.42, 0.36)
	grade = "warm"
	animated = true


func lights() -> Array:
	return [
		{"pos": Vector2(560, 200), "radius": 600.0, "color": Color(1.0, 0.82, 0.5), "energy": 1.0, "flicker": 0.1},
		{"pos": Vector2(1000, 300), "radius": 300.0, "color": Color(0.7, 0.9, 0.75), "energy": 0.3},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.wallpaper(ci, Rect2(0, 0, 1280, 460), Color(0.5, 0.48, 0.36), Color(0.46, 0.44, 0.32), 0.8, 27)
	# Tiles behind the stove.
	for row in 6:
		for col in 10:
			ci.draw_rect(Rect2(300 + col * 46, 250 + row * 34, 44, 32), Color(0.78, 0.8, 0.74).darkened(fmod(row * 0.07 + col * 0.03, 0.2)))
	Paint.window(ci, Rect2(860, 150, 200, 170), Color(0.05, 0.06, 0.1), Color(0.12, 0.12, 0.16), Color(0.4, 0.38, 0.3), false, false)
	ci.draw_rect(Rect2(0, 460, 1280, 260), Color(0.3, 0.28, 0.24))
	for row in 6:
		for col in 18:
			if (row + col) % 2 == 0:
				ci.draw_rect(Rect2(col * 74 - row * 10, 470 + row * 42, 74, 42), Color(0.38, 0.36, 0.32))
	Paint.counter(ci, Rect2(260, 460, 520, 190), Color(0.6, 0.58, 0.5), Color(0.42, 0.36, 0.28))
	Paint.stove(ci, Vector2(800, 650))
	Paint.fridge(ci, Vector2(1130, 650))
	Paint.table(ci, Rect2(60, 540, 170, 110), Color(0.4, 0.3, 0.2), Color(0.25, 0.18, 0.12))


func draw_anim(ci: CanvasItem) -> void:
	Paint.pot(ci, Vector2(835, 546), 60, Color(0.5, 0.5, 0.52), t, steam)
	Paint.pot(ci, Vector2(890, 546), 46, Color(0.42, 0.4, 0.4), t + 2.0, steam)
	Paint.bulb(ci, Vector2(560, 0), 150.0, sin(t * 0.8) * 0.04, true)
