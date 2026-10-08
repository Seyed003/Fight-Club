extends Location
## A church basement used by support groups: wood panels, folding chairs,
## a coffee urn, and a banner that changes with the group.

var banner_text := "REMAINING MEN TOGETHER"
var banner_color := Color(0.62, 0.52, 0.32)
var chairs := [250.0, 400.0, 560.0, 720.0, 880.0, 1030.0]


func _init() -> void:
	floor_y = 630.0
	ambient = Color(0.58, 0.58, 0.54)
	grade = "office"
	amb = "fluorescent"
	amb_db = -18.0


func lights() -> Array:
	return [
		{"pos": Vector2(400, 90), "radius": 520.0, "color": Color(0.85, 1.0, 0.88), "energy": 0.55, "flicker": 0.04},
		{"pos": Vector2(900, 90), "radius": 520.0, "color": Color(0.85, 1.0, 0.88), "energy": 0.55},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.wood_panels(ci, Rect2(0, 0, 1280, 470), Color(0.36, 0.28, 0.2), 52)
	ci.draw_rect(Rect2(0, 0, 1280, 60), Color(0.62, 0.6, 0.55))
	for x in [180.0, 580.0, 980.0]:
		Paint.fluorescent(ci, Rect2(x, 52, 140, 8))
	ci.draw_rect(Rect2(0, 300, 1280, 12), Color(0.28, 0.2, 0.14))
	Paint.banner(ci, Rect2(300, 120, 680, 70), banner_text, banner_color, Color(0.18, 0.12, 0.08), 30)
	# Bulletin board and a cross.
	ci.draw_rect(Rect2(90, 160, 150, 110), Color(0.55, 0.42, 0.28))
	for i in 5:
		ci.draw_rect(Rect2(100 + (i % 3) * 46, 172 + (i / 3) * 48, 38, 40), Color(0.9, 0.88, 0.8, 0.9).darkened(i * 0.05))
	ci.draw_rect(Rect2(1110, 150, 10, 90), Color(0.25, 0.18, 0.12))
	ci.draw_rect(Rect2(1090, 176, 50, 10), Color(0.25, 0.18, 0.12))
	# Linoleum.
	Paint.vgrad(ci, Rect2(0, 470, 1280, 250), Color(0.42, 0.42, 0.36), Color(0.26, 0.26, 0.22))
	var y := 470.0
	while y < 720.0:
		ci.draw_line(Vector2(0, y), Vector2(1280, y), Color(0, 0, 0, 0.12), 1.0)
		y += 26.0 + (y - 470.0) * 0.12
	# Coffee table.
	Paint.table(ci, Rect2(60, 400, 150, 70), Color(0.5, 0.44, 0.36), Color(0.2, 0.18, 0.16))
	ci.draw_rect(Rect2(80, 352, 34, 48), Color(0.66, 0.66, 0.62))
	for i in 4:
		ci.draw_rect(Rect2(130 + i * 16, 386, 11, 14), Color(0.92, 0.9, 0.86))
	for i in chairs.size():
		var face := 1 if chairs[i] < 640.0 else -1
		Paint.chair(ci, Vector2(chairs[i], floor_y), Color(0.42, 0.42, 0.44), 1.5, face)
