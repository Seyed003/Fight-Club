extends Location
## Behind Lou's Tavern: wet asphalt, one lamp over the back door.
## `crowd` > 0 draws onlookers for the early parking-lot fights.

var crowd := 0.0
var excite := 0.3


func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.36, 0.38, 0.44)
	grade = "night"
	animated = true
	front_animated = true
	amb = "night_city"
	amb_db = -14.0


func lights() -> Array:
	return [
		{"pos": Vector2(560, 250), "radius": 620.0, "color": Color(1.0, 0.8, 0.5), "energy": 1.1, "flicker": 0.05},
		{"pos": Vector2(1150, 380), "radius": 300.0, "color": Color(0.6, 0.75, 1.0), "energy": 0.3},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.05), Color(0.05, 0.06, 0.08))
	Paint.skyline(ci, Rect2(0, 60, 1280, 200), true, 21, 0.12)
	Paint.bricks(ci, Rect2(200, 120, 760, 400), Color(0.26, 0.17, 0.13), Color(0.1, 0.08, 0.07), 54, 22, 2)
	Paint.sign_box(ci, Rect2(380, 150, 360, 56), "LOU'S TAVERN", Color(0.12, 0.1, 0.08), Color(0.92, 0.82, 0.6), 34)
	Paint.door(ci, Rect2(520, 300, 110, 220), Color(0.25, 0.27, 0.25))
	ci.draw_rect(Rect2(546, 236, 60, 16), Color(0.2, 0.2, 0.2))
	Paint.glow(ci, Vector2(576, 256), 70, Color(1.0, 0.85, 0.5, 0.7))
	Paint.dumpster(ci, Vector2(840, 520))
	Paint.fence(ci, 520, 960, 1280, 170, Color(0.4, 0.42, 0.44, 0.8))
	Paint.vgrad(ci, Rect2(0, 520, 1280, 200), Color(0.13, 0.13, 0.14), Color(0.06, 0.06, 0.07))
	for i in 5:
		ci.draw_line(Vector2(100 + i * 260, 560), Vector2(60 + i * 260, 720), Color(0.7, 0.7, 0.6, 0.25), 5.0)
	Paint.floor_stains(ci, Rect2(0, 560, 1280, 150), Color(0.2, 0.25, 0.3, 0.35), 10, 14)
	Paint.car_side(ci, Vector2(170, 600), Color(0.2, 0.22, 0.24), 1.0, 1)


func draw_anim(ci: CanvasItem) -> void:
	if crowd > 0.0:
		Paint.crowd(ci, 560, 80, 1200, int(10 * crowd), Color(0.07, 0.07, 0.08), t, 33, 0.9, excite)


func draw_front(ci: CanvasItem) -> void:
	if crowd > 0.5:
		Paint.crowd(ci, 760, -40, 1320, 7, Color(0.03, 0.03, 0.03), t, 44, 1.7, excite)
