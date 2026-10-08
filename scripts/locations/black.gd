extends Location
## Empty black frame, for title cards and voice-over in the dark.


func _init() -> void:
	ambient = Color(1, 1, 1)


func draw_static(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, 1280, 720), Color(0.01, 0.01, 0.01))
