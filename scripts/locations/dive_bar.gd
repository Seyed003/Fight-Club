extends Location
## A bar in another city, the same as all the others. `city` changes the
## neon name; there is always a door to a basement.

var city := 0
const NAMES := ["THE SHAMROCK", "RED LANTERN", "BLUE MOON", "DOC'S", "THE ANCHOR"]


func _init() -> void:
	floor_y = 650.0
	ambient = Color(0.4, 0.36, 0.34)
	grade = "warm"
	animated = true
	amb = "bar_murmur"
	amb_db = -14.0


func lights() -> Array:
	return [
		{"pos": Vector2(600, 200), "radius": 520.0, "color": Color(1.0, 0.72, 0.42), "energy": 0.85},
		{"pos": Vector2(180, 260), "radius": 300.0, "color": Color(0.4, 0.7, 1.0), "energy": 0.45},
	]


func draw_static(ci: CanvasItem) -> void:
	var hue: Color = [Color(0.22, 0.26, 0.16), Color(0.3, 0.12, 0.1), Color(0.14, 0.16, 0.26), Color(0.26, 0.2, 0.12), Color(0.16, 0.2, 0.22)][city % 5]
	Paint.wood_panels(ci, Rect2(0, 0, 1280, 500), hue, 70)
	ci.draw_rect(Rect2(380, 130, 560, 200), Color(0.1, 0.08, 0.07))
	Paint.bottles(ci, Rect2(400, 140, 520, 190), 40 + city)
	Paint.neon(ci, Vector2(60, 200), NAMES[city % NAMES.size()], Color(0.4, 0.75, 1.0), 34)
	Paint.door(ci, Rect2(1060, 250, 120, 250), Color(0.25, 0.2, 0.16))
	Paint.sign_box(ci, Rect2(1070, 220, 100, 26), "STAFF ONLY", Color(0.8, 0.78, 0.7), Color(0.2, 0.1, 0.1), 14)
	Paint.vgrad(ci, Rect2(0, 500, 1280, 220), Color(0.16, 0.12, 0.1), Color(0.08, 0.06, 0.05))
	Paint.counter(ci, Rect2(300, 440, 700, 220), Color(0.34, 0.22, 0.12), Color(0.22, 0.14, 0.09))


func draw_anim(ci: CanvasItem) -> void:
	Paint.glow_ellipse(ci, Vector2(640, 120 + sin(t * 0.2) * 10), 520, 60, Color(0.85, 0.8, 0.7, 0.05))
