extends Location
## A cheap motel room on the road. A neon sign blinks outside.

var neon_on := true


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.42, 0.4, 0.42)
	grade = "night"
	animated = true
	amb = "night_city"
	amb_db = -18.0


func lights() -> Array:
	return [
		{"pos": Vector2(300, 380), "radius": 380.0, "color": Color(1.0, 0.82, 0.55), "energy": 0.8},
		{"pos": Vector2(1000, 260), "radius": 420.0, "color": Color(1.0, 0.25, 0.35), "energy": 0.5, "flicker": 0.3},
	]


func draw_static(ci: CanvasItem) -> void:
	Paint.wallpaper(ci, Rect2(0, 0, 1280, 470), Color(0.44, 0.4, 0.34), Color(0.4, 0.36, 0.3), 0.0, 51)
	Paint.window(ci, Rect2(860, 110, 300, 230), Color(0.03, 0.03, 0.06), Color(0.06, 0.05, 0.08), Color(0.3, 0.26, 0.2), true, false, true)
	Paint.vgrad(ci, Rect2(0, 470, 1280, 250), Color(0.3, 0.24, 0.22), Color(0.16, 0.13, 0.12))
	Paint.bed(ci, Vector2(400, 650), 380, Color(0.42, 0.3, 0.26))
	ci.draw_rect(Rect2(250, 540, 90, 110), Color(0.3, 0.22, 0.16))
	ci.draw_line(Vector2(296, 540), Vector2(296, 470), Color(0.2, 0.2, 0.2), 3.0)
	Paint.poly(ci, [Vector2(270, 470), Vector2(322, 470), Vector2(336, 430), Vector2(256, 430)], Color(0.96, 0.9, 0.7))
	ci.draw_rect(Rect2(272, 524, 40, 16), Color(0.1, 0.1, 0.1))
	ci.draw_rect(Rect2(960, 520, 160, 130), Color(0.3, 0.22, 0.16))
	ci.draw_rect(Rect2(980, 440, 120, 80), Color(0.12, 0.12, 0.13))
	ci.draw_rect(Rect2(990, 450, 100, 60), Color(0.15, 0.2, 0.22))


func draw_anim(ci: CanvasItem) -> void:
	var on := neon_on and fmod(t, 1.6) < 1.2
	Paint.neon(ci, Vector2(890, 210), "MOTEL", Color(1.0, 0.25, 0.35), 50, on)
	Paint.glow(ci, Vector2(296, 450), 80, Color(1.0, 0.88, 0.6, 0.5))
