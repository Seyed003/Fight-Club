extends Location
## The narrator's condo, furnished out of a catalogue. Items bought in the
## catalogue game are stored as a flag and drawn here. `burned` chars it.

var burned := false
var night := true

const ITEMS := ["sofa", "table", "lamp", "clock", "rug", "armchair", "shelf", "plates"]


func _init() -> void:
	floor_y = 640.0
	ambient = Color(0.6, 0.6, 0.6)
	grade = "normal"
	animated = true


func lights() -> Array:
	if burned:
		return [{"pos": Vector2(640, 300), "radius": 700.0, "color": Color(1.0, 0.5, 0.25), "energy": 0.5, "flicker": 0.35}]
	return [
		{"pos": Vector2(300, 330), "radius": 380.0, "color": Color(1.0, 0.88, 0.7), "energy": 0.6},
		{"pos": Vector2(960, 330), "radius": 380.0, "color": Color(1.0, 0.88, 0.7), "energy": 0.6},
	]


func owned() -> Array:
	var v: Variant = Settings.get_flag("ikea_items", [])
	return v if v is Array else []


func draw_static(ci: CanvasItem) -> void:
	var wall := Color(0.82, 0.8, 0.74) if not burned else Color(0.16, 0.14, 0.12)
	ci.draw_rect(Rect2(0, 0, 1280, 470), wall)
	Paint.window(ci, Rect2(470, 70, 340, 300), Color(0.05, 0.07, 0.14) if night else Color(0.6, 0.7, 0.8),
		Color(0.2, 0.18, 0.24) if night else Color(0.86, 0.88, 0.86), Color(0.85, 0.85, 0.82) if not burned else Color(0.1, 0.1, 0.1), false, true, night)
	var floor_c := Color(0.62, 0.48, 0.32) if not burned else Color(0.12, 0.1, 0.09)
	Paint.vgrad(ci, Rect2(0, 470, 1280, 250), floor_c, floor_c.darkened(0.35))
	var x := 0.0
	while x < 1280.0:
		ci.draw_line(Vector2(x, 470), Vector2(x - 120, 720), Color(0, 0, 0, 0.1), 2.0)
		x += 90.0
	if burned:
		Paint.grime(ci, Rect2(0, 0, 1280, 470), Color(0, 0, 0, 0.7), 5, 24)
		Paint.floor_stains(ci, Rect2(0, 480, 1280, 220), Color(0, 0, 0, 0.6), 20, 6)
		return
	var items := owned()
	if "shelf" in items:
		ci.draw_rect(Rect2(90, 190, 220, 14), Color(0.9, 0.9, 0.88))
		ci.draw_rect(Rect2(90, 270, 220, 14), Color(0.9, 0.9, 0.88))
		for i in 6:
			ci.draw_rect(Rect2(100 + i * 32, 226, 22, 44), Color(0.3 + i * 0.08, 0.35, 0.4))
	if "clock" in items:
		ci.draw_circle(Vector2(1000, 160), 38, Color(0.75, 0.76, 0.78))
		ci.draw_circle(Vector2(1000, 160), 32, Color(0.95, 0.95, 0.93))
		ci.draw_line(Vector2(1000, 160), Vector2(1000, 136), Color(0.1, 0.1, 0.1), 3.0)
		ci.draw_line(Vector2(1000, 160), Vector2(1018, 168), Color(0.1, 0.1, 0.1), 3.0)
	if "rug" in items:
		Paint.ellipse(ci, Vector2(640, 600), 330, 60, Color(0.62, 0.66, 0.6))
		Paint.ellipse(ci, Vector2(640, 600), 300, 50, Color(0.7, 0.74, 0.68))
	if "sofa" in items:
		Paint.sofa(ci, Vector2(130, 600), 300, Color(0.62, 0.6, 0.55))
	if "armchair" in items:
		Paint.sofa(ci, Vector2(1000, 600), 110, Color(0.42, 0.56, 0.42))
		for i in 4:
			ci.draw_line(Vector2(1010 + i * 26, 494), Vector2(1010 + i * 26, 534), Color(0.86, 0.86, 0.8, 0.6), 4.0)
	if "table" in items:
		Paint.ellipse(ci, Vector2(640, 560), 120, 22, Color(0.9, 0.9, 0.88))
		ci.draw_rect(Rect2(600, 560, 10, 46), Color(0.6, 0.6, 0.6))
		ci.draw_rect(Rect2(670, 560, 10, 46), Color(0.6, 0.6, 0.6))
		ci.draw_arc(Vector2(640, 556), 14, 0, TAU, 20, Color(0.1, 0.1, 0.1), 3.0)
	if "plates" in items:
		for i in 3:
			Paint.ellipse(ci, Vector2(1180, 330 + i * 8), 30, 6, Color(0.95, 0.95, 0.92).darkened(i * 0.06))
		ci.draw_rect(Rect2(1130, 344, 100, 126), Color(0.5, 0.4, 0.3))
	if "lamp" in items:
		for lx in [300.0, 960.0]:
			ci.draw_line(Vector2(lx, 470), Vector2(lx, 360), Color(0.3, 0.3, 0.3), 3.0)
			Paint.ellipse(ci, Vector2(lx, 340), 36, 30, Color(0.98, 0.94, 0.82))
			Paint.glow(ci, Vector2(lx, 340), 110, Color(1.0, 0.9, 0.7, 0.35))


func draw_anim(ci: CanvasItem) -> void:
	if burned:
		for i in 5:
			Paint.glow(ci, Vector2(200 + i * 220, 470 + sin(t * 3.0 + i) * 6), 70 + sin(t * 7.0 + i) * 10, Color(1.0, 0.45, 0.15, 0.35))
		var smoke_y := fmod(t * 30.0, 200.0)
		Paint.glow_ellipse(ci, Vector2(640, 250 - smoke_y * 0.3), 500, 160, Color(0.2, 0.18, 0.16, 0.35))
