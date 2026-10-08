class_name Paint
extends RefCounted
## Drawing helpers shared by every location. All functions take the
## CanvasItem to draw on, so they can be called from a `draw` signal.

static var _radial: GradientTexture2D
static var _linear: GradientTexture2D
static var _font: Font


static func radial_tex() -> Texture2D:
	if _radial == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.45, Color(1, 1, 1, 0.38))
		_radial = GradientTexture2D.new()
		_radial.gradient = g
		_radial.fill = GradientTexture2D.FILL_RADIAL
		_radial.fill_from = Vector2(0.5, 0.5)
		_radial.fill_to = Vector2(1.0, 0.5)
		_radial.width = 256
		_radial.height = 256
	return _radial


static func linear_tex() -> Texture2D:
	if _linear == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		_linear = GradientTexture2D.new()
		_linear.gradient = g
		_linear.fill_from = Vector2(0.5, 0.0)
		_linear.fill_to = Vector2(0.5, 1.0)
		_linear.width = 8
		_linear.height = 128
	return _linear


static func font() -> Font:
	if _font == null:
		_font = load("res://assets/fonts/Vazirmatn-Bold.ttf")
	return _font


static func rect(ci: CanvasItem, r: Rect2, c: Color) -> void:
	ci.draw_rect(r, c)


static func vgrad(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void:
	ci.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([top, top, bottom, bottom]))


static func hgrad(ci: CanvasItem, r: Rect2, left: Color, right: Color) -> void:
	ci.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([left, right, right, left]))


## Soft round glow, e.g. light pooling on a wall.
static func glow(ci: CanvasItem, center: Vector2, radius: float, c: Color) -> void:
	ci.draw_texture_rect(radial_tex(), Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, c)


static func glow_ellipse(ci: CanvasItem, center: Vector2, rx: float, ry: float, c: Color) -> void:
	ci.draw_texture_rect(radial_tex(), Rect2(center - Vector2(rx, ry), Vector2(rx, ry) * 2.0), false, c)


## A cone of light from a lamp down to the floor.
static func light_cone(ci: CanvasItem, apex: Vector2, bottom_y: float, half_width: float, c: Color) -> void:
	var clear := Color(c.r, c.g, c.b, 0.0)
	ci.draw_polygon(PackedVector2Array([apex + Vector2(-4, 0), apex + Vector2(4, 0), Vector2(apex.x + half_width, bottom_y), Vector2(apex.x - half_width, bottom_y)]),
		PackedColorArray([c, c, clear, clear]))


static func shade_band(ci: CanvasItem, r: Rect2, c: Color, from_top := true) -> void:
	var clear := Color(c.r, c.g, c.b, 0.0)
	if from_top:
		vgrad(ci, r, c, clear)
	else:
		vgrad(ci, r, clear, c)


static func poly(ci: CanvasItem, pts: Array, c: Color) -> void:
	var arr := PackedVector2Array()
	for p in pts:
		arr.append(p)
	ci.draw_colored_polygon(arr, c)


static func outline(ci: CanvasItem, pts: Array, c: Color, w := 2.0) -> void:
	var arr := PackedVector2Array()
	for p in pts:
		arr.append(p)
	arr.append(pts[0])
	ci.draw_polyline(arr, c, w, true)


static func circle(ci: CanvasItem, center: Vector2, r: float, c: Color) -> void:
	ci.draw_circle(center, r, c)


static func ellipse(ci: CanvasItem, center: Vector2, rx: float, ry: float, c: Color, segs := 24) -> void:
	var pts := PackedVector2Array()
	for i in segs:
		var t := TAU * i / segs
		pts.append(center + Vector2(cos(t) * rx, sin(t) * ry))
	ci.draw_colored_polygon(pts, c)


static func text(ci: CanvasItem, pos: Vector2, s: String, size: int, c: Color, f: Font = null, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	ci.draw_string(f if f != null else font(), pos, s, align, width, size, c)


## Brick wall with per-brick colour variation and mortar.
static func bricks(ci: CanvasItem, r: Rect2, base: Color, mortar: Color, bw := 56.0, bh := 22.0, seed_value := 1) -> void:
	ci.draw_rect(r, mortar)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var rows := int(ceil(r.size.y / bh))
	for row in rows:
		var y := r.position.y + row * bh
		var off := (bw * 0.5) if row % 2 == 1 else 0.0
		var x := r.position.x - off
		while x < r.end.x:
			var v := rng.randf_range(-0.07, 0.07)
			var c := Color(base.r + v, base.g + v * 0.8, base.b + v * 0.6)
			if rng.randf() < 0.06:
				c = c.darkened(0.25)
			var br := Rect2(Vector2(max(x + 2, r.position.x), y + 2), Vector2(bw - 4, bh - 4))
			br.size.x = min(br.size.x, r.end.x - br.position.x)
			br.size.y = min(br.size.y, r.end.y - br.position.y)
			if br.size.x > 0 and br.size.y > 0:
				ci.draw_rect(br, c)
			x += bw


## Concrete or linoleum floor with stains.
static func floor_stains(ci: CanvasItem, r: Rect2, c: Color, count := 12, seed_value := 3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var p := Vector2(rng.randf_range(r.position.x, r.end.x), rng.randf_range(r.position.y, r.end.y))
		var rx := rng.randf_range(20, 90)
		ellipse(ci, p, rx, rx * rng.randf_range(0.12, 0.3), Color(c.r, c.g, c.b, c.a * rng.randf_range(0.4, 1.0)), 14)


static func specks(ci: CanvasItem, r: Rect2, count: int, c: Color, seed_value := 5, size := 1.5) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var p := Vector2(rng.randf_range(r.position.x, r.end.x), rng.randf_range(r.position.y, r.end.y))
		ci.draw_rect(Rect2(p, Vector2(size, size)), c)


## Window with sky, optional city, frame and blinds.
static func window(ci: CanvasItem, r: Rect2, sky_top: Color, sky_bottom: Color, frame: Color, blinds := false, city := true, night := false) -> void:
	vgrad(ci, r, sky_top, sky_bottom)
	if city:
		skyline(ci, Rect2(r.position.x, r.position.y + r.size.y * 0.45, r.size.x, r.size.y * 0.55), night, 7)
	if blinds:
		var y := r.position.y
		while y < r.end.y:
			ci.draw_rect(Rect2(r.position.x, y, r.size.x, 5), Color(0.86, 0.84, 0.78, 0.85))
			y += 11
	ci.draw_rect(r, frame, false, 6.0)
	ci.draw_line(Vector2(r.get_center().x, r.position.y), Vector2(r.get_center().x, r.end.y), frame, 4.0)


static func skyline(ci: CanvasItem, r: Rect2, night := true, seed_value := 11, lit := 0.35) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var x := r.position.x
	var base_c := Color(0.08, 0.09, 0.11) if night else Color(0.42, 0.46, 0.48)
	while x < r.end.x:
		var w := rng.randf_range(r.size.x * 0.05, r.size.x * 0.14)
		var h := rng.randf_range(r.size.y * 0.3, r.size.y)
		var br := Rect2(x, r.end.y - h, min(w, r.end.x - x), h)
		ci.draw_rect(br, base_c.lightened(rng.randf_range(-0.05, 0.08)))
		var wy := br.position.y + 6
		while wy < br.end.y - 6:
			var wx := br.position.x + 4
			while wx < br.end.x - 6:
				if rng.randf() < lit:
					var wc := Color(1.0, 0.86, 0.55, 0.85) if night else Color(0.75, 0.82, 0.86, 0.5)
					ci.draw_rect(Rect2(wx, wy, 3, 4), wc)
				wx += 7
			wy += 9
		x += w + rng.randf_range(0, 6)


## A plain folding chair seen from the side.
static func chair(ci: CanvasItem, pos: Vector2, c: Color, s := 1.0, face := 1) -> void:
	var f := float(face)
	ci.draw_line(pos + Vector2(-16 * f, 0) * s, pos + Vector2(-14 * f, -46) * s, c, 4 * s)
	ci.draw_line(pos + Vector2(16 * f, 0) * s, pos + Vector2(14 * f, -46) * s, c, 4 * s)
	ci.draw_rect(Rect2(pos + Vector2(-20, -52) * s, Vector2(40, 7) * s), c.lightened(0.1))
	ci.draw_line(pos + Vector2(-17 * f, -50) * s, pos + Vector2(-22 * f, -110) * s, c, 4 * s)
	ci.draw_line(pos + Vector2(-22 * f, -110) * s, pos + Vector2(-20 * f, -86) * s, c, 10 * s)


static func table(ci: CanvasItem, r: Rect2, top: Color, leg: Color) -> void:
	ci.draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 10), top)
	ci.draw_rect(Rect2(r.position.x + 8, r.position.y + 10, 8, r.size.y - 10), leg)
	ci.draw_rect(Rect2(r.end.x - 16, r.position.y + 10, 8, r.size.y - 10), leg)


## Bodies at the edge of the light: heads and shoulders that bob.
static func crowd(ci: CanvasItem, y: float, x0: float, x1: float, count: int, c: Color, t: float, seed_value := 9, s := 1.0, excite := 0.0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var x := lerpf(x0, x1, (i + rng.randf_range(-0.3, 0.3)) / max(1.0, count - 1.0))
		var h := rng.randf_range(0.88, 1.12) * s
		var bob := sin(t * rng.randf_range(2.0, 4.0) + i) * (2.0 + excite * 6.0) * s
		var base := Vector2(x, y + bob)
		var col := c.lightened(rng.randf_range(-0.04, 0.06))
		var shoulder_w := rng.randf_range(26, 38) * h
		poly(ci, [base + Vector2(-shoulder_w, 0), base + Vector2(-shoulder_w * 0.85, -70 * h), base + Vector2(-12 * h, -86 * h),
			base + Vector2(12 * h, -86 * h), base + Vector2(shoulder_w * 0.85, -70 * h), base + Vector2(shoulder_w, 0)], col)
		ellipse(ci, base + Vector2(0, -104 * h), 13 * h, 16 * h, col, 14)
		if excite > 0.3 and rng.randf() < 0.4:
			var arm_up := sin(t * 5.0 + i * 1.7) > 0.0
			if arm_up:
				var side := -1.0 if rng.randf() < 0.5 else 1.0
				ci.draw_line(base + Vector2(side * shoulder_w * 0.7, -70 * h), base + Vector2(side * (shoulder_w + 8), -150 * h), col, 9 * h)


static func rain(ci: CanvasItem, r: Rect2, t: float, density := 120, c := Color(0.7, 0.75, 0.8, 0.25)) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in density:
		var x := rng.randf_range(r.position.x, r.end.x)
		var speed := rng.randf_range(600, 900)
		var y := fposmod(rng.randf_range(0, r.size.y) + t * speed, r.size.y) + r.position.y
		ci.draw_line(Vector2(x, y), Vector2(x - 3, y + 16), c, 1.2)


## Dangling bulb on a cord. Returns the bulb position.
static func bulb(ci: CanvasItem, anchor: Vector2, length: float, swing: float, on := true) -> Vector2:
	var tip := anchor + Vector2(sin(swing), cos(swing)) * length
	ci.draw_line(anchor, tip, Color(0.05, 0.05, 0.05), 2.0)
	ci.draw_rect(Rect2(tip - Vector2(5, 2), Vector2(10, 8)), Color(0.25, 0.22, 0.18))
	if on:
		glow(ci, tip + Vector2(0, 14), 60, Color(1.0, 0.85, 0.55, 0.55))
		ellipse(ci, tip + Vector2(0, 14), 9, 11, Color(1.0, 0.95, 0.8))
	else:
		ellipse(ci, tip + Vector2(0, 14), 9, 11, Color(0.5, 0.48, 0.42))
	return tip + Vector2(0, 14)


static func fluorescent(ci: CanvasItem, r: Rect2, on := true) -> void:
	ci.draw_rect(r.grow(3), Color(0.2, 0.21, 0.2))
	ci.draw_rect(r, Color(0.9, 0.98, 0.92) if on else Color(0.45, 0.48, 0.46))
	if on:
		glow_ellipse(ci, r.get_center() + Vector2(0, 20), r.size.x * 0.9, 70, Color(0.8, 1.0, 0.85, 0.22))


static func door(ci: CanvasItem, r: Rect2, c: Color, knob := true) -> void:
	ci.draw_rect(r.grow(5), c.darkened(0.35))
	ci.draw_rect(r, c)
	ci.draw_rect(Rect2(r.position + Vector2(12, 14), Vector2(r.size.x - 24, r.size.y * 0.38)), c.darkened(0.1), false, 2.0)
	ci.draw_rect(Rect2(r.position + Vector2(12, r.size.y * 0.5), Vector2(r.size.x - 24, r.size.y * 0.42)), c.darkened(0.1), false, 2.0)
	if knob:
		ci.draw_circle(Vector2(r.end.x - 14, r.get_center().y + 6), 4, Color(0.7, 0.62, 0.4))


## Wall plaster with water damage and peeling.
static func grime(ci: CanvasItem, r: Rect2, c: Color, seed_value := 13, count := 10) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var x := rng.randf_range(r.position.x, r.end.x)
		var top := r.position.y + rng.randf_range(0, r.size.y * 0.3)
		var w := rng.randf_range(20, 80)
		var h := rng.randf_range(r.size.y * 0.2, r.size.y * 0.8)
		vgrad(ci, Rect2(x, top, w, h), Color(c.r, c.g, c.b, c.a * rng.randf_range(0.5, 1.0)), Color(c.r, c.g, c.b, 0))


static func car_side(ci: CanvasItem, pos: Vector2, body: Color, s := 1.0, face := 1) -> void:
	var f := float(face)
	var pts := [Vector2(-130, -18), Vector2(-128, -50), Vector2(-70, -54), Vector2(-40, -92), Vector2(50, -92),
		Vector2(85, -56), Vector2(130, -50), Vector2(132, -18)]
	var arr: Array = []
	for p in pts:
		arr.append(pos + Vector2(p.x * f, p.y) * s)
	poly(ci, arr, body)
	poly(ci, [pos + Vector2(-32 * f, -86) * s, pos + Vector2(5 * f, -86) * s, pos + Vector2(5 * f, -58) * s, pos + Vector2(-58 * f, -58) * s], Color(0.2, 0.25, 0.28, 0.9))
	poly(ci, [pos + Vector2(12 * f, -86) * s, pos + Vector2(46 * f, -86) * s, pos + Vector2(74 * f, -58) * s, pos + Vector2(12 * f, -58) * s], Color(0.2, 0.25, 0.28, 0.9))
	for wx in [-82.0, 82.0]:
		ci.draw_circle(pos + Vector2(wx * f, -16) * s, 22 * s, Color(0.05, 0.05, 0.05))
		ci.draw_circle(pos + Vector2(wx * f, -16) * s, 10 * s, Color(0.45, 0.45, 0.45))
