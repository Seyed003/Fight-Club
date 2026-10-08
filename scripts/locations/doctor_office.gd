extends Location
## An examination room. Pale, clean, indifferent.

func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.66, 0.7, 0.68)
	grade = "office"
	amb = "fluorescent"
	amb_db = -20.0


func lights() -> Array:
	return [{"pos": Vector2(640, 90), "radius": 720.0, "color": Color(0.9, 1.0, 0.95), "energy": 0.5}]


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 480), Color(0.78, 0.82, 0.8))
	ci.draw_rect(Rect2(0, 300, 1280, 180), Color(0.66, 0.74, 0.72))
	ci.draw_line(Vector2(0, 300), Vector2(1280, 300), Color(0.5, 0.56, 0.54), 3.0)
	Paint.window(ci, Rect2(860, 100, 260, 180), Color(0.7, 0.76, 0.8), Color(0.86, 0.88, 0.86), Color(0.9, 0.9, 0.88), true, false)
	# Eye chart.
	ci.draw_rect(Rect2(140, 110, 110, 160), Color(0.96, 0.96, 0.94))
	var rows := ["E", "F P", "T O Z", "L P E D"]
	for i in rows.size():
		Paint.text(ci, Vector2(150 + i * 4, 150 + i * 32), rows[i], 30 - i * 6, Color(0.1, 0.1, 0.1))
	# Door to the corridor.
	Paint.door(ci, Rect2(380, 190, 120, 290), Color(0.62, 0.66, 0.64))
	Paint.vgrad(ci, Rect2(0, 480, 1280, 240), Color(0.62, 0.64, 0.6), Color(0.46, 0.48, 0.44))
	# Exam table and cabinet.
	ci.draw_rect(Rect2(620, 520, 280, 24), Color(0.3, 0.32, 0.34))
	ci.draw_rect(Rect2(626, 508, 268, 16), Color(0.86, 0.86, 0.8))
	ci.draw_rect(Rect2(650, 544, 14, 96), Color(0.5, 0.5, 0.52))
	ci.draw_rect(Rect2(860, 544, 14, 96), Color(0.5, 0.5, 0.52))
	ci.draw_rect(Rect2(1000, 400, 160, 240), Color(0.82, 0.84, 0.82))
	ci.draw_line(Vector2(1000, 520), Vector2(1160, 520), Color(0.6, 0.6, 0.6), 2.0)
