extends Location
## The guided-meditation cave: blue ice, white light, a power animal.
## `who_waits` is "penguin" or "marla".

var who_waits := "penguin"
var waiter_x := 1040.0


func _init() -> void:
	floor_y = 620.0
	ambient = Color(0.75, 0.85, 0.95)
	grade = "dream"
	animated = true
	amb = "wind"
	amb_db = -16.0


func lights() -> Array:
	return [{"pos": Vector2(1080, 300), "radius": 700.0, "color": Color(0.7, 0.9, 1.0), "energy": 0.7}]


func draw_static(ci: CanvasItem) -> void:
	Paint.vgrad(ci, Rect2(0, 0, 1280, 720), Color(0.05, 0.12, 0.22), Color(0.18, 0.36, 0.5))
	Paint.glow(ci, Vector2(1100, 330), 420, Color(0.85, 0.97, 1.0, 0.75))
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	# Ceiling ice and icicles.
	Paint.poly(ci, [Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 90), Vector2(900, 130), Vector2(500, 100), Vector2(160, 150), Vector2(0, 120)], Color(0.1, 0.22, 0.36))
	for i in 26:
		var x := rng.randf_range(0, 1280)
		var top := 100.0 + sin(x * 0.01) * 30.0
		var h := rng.randf_range(30, 110)
		Paint.poly(ci, [Vector2(x - 9, top), Vector2(x + 9, top), Vector2(x, top + h)], Color(0.55, 0.78, 0.92, 0.75))
	# Walls of ice.
	Paint.poly(ci, [Vector2(0, 120), Vector2(180, 160), Vector2(240, 400), Vector2(140, 640), Vector2(0, 660)], Color(0.12, 0.28, 0.42))
	Paint.poly(ci, [Vector2(1280, 90), Vector2(1240, 300), Vector2(1280, 640)], Color(0.2, 0.4, 0.55))
	Paint.vgrad(ci, Rect2(0, 560, 1280, 160), Color(0.62, 0.8, 0.9), Color(0.85, 0.94, 1.0))
	for i in 12:
		var x := rng.randf_range(0, 1280)
		Paint.ellipse(ci, Vector2(x, rng.randf_range(600, 700)), rng.randf_range(40, 140), 10, Color(1, 1, 1, 0.3))


func draw_anim(ci: CanvasItem) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 50:
		var x := fposmod(rng.randf_range(0, 1280) + t * rng.randf_range(10, 30), 1280.0)
		var y := fposmod(rng.randf_range(0, 720) + t * rng.randf_range(20, 50), 720.0)
		ci.draw_circle(Vector2(x, y), rng.randf_range(1.0, 2.5), Color(1, 1, 1, 0.6))
	if who_waits == "penguin":
		var p := Vector2(waiter_x, floor_y)
		var bob := sin(t * 2.0) * 2.0
		Paint.ellipse(ci, p + Vector2(0, -52 + bob), 30, 52, Color(0.06, 0.07, 0.1))
		Paint.ellipse(ci, p + Vector2(8, -46 + bob), 20, 40, Color(0.95, 0.96, 0.98))
		Paint.ellipse(ci, p + Vector2(0, -112 + bob), 20, 18, Color(0.06, 0.07, 0.1))
		ci.draw_circle(p + Vector2(8, -116 + bob), 3, Color(1, 1, 1))
		Paint.poly(ci, [p + Vector2(16, -112 + bob), p + Vector2(34, -106 + bob), p + Vector2(16, -102 + bob)], Color(0.95, 0.65, 0.15))
		Paint.poly(ci, [p + Vector2(-26, -70 + bob), p + Vector2(-40, -30 + bob), p + Vector2(-22, -40 + bob)], Color(0.06, 0.07, 0.1))
		Paint.ellipse(ci, p + Vector2(-8, -2), 12, 5, Color(0.95, 0.65, 0.15))
		Paint.ellipse(ci, p + Vector2(10, -2), 12, 5, Color(0.95, 0.65, 0.15))
