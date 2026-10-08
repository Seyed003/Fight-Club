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


## Striped wallpaper, stained and peeling where `damage` is high.
static func wallpaper(ci: CanvasItem, r: Rect2, base: Color, stripe: Color, damage := 0.0, seed_value := 17) -> void:
	ci.draw_rect(r, base)
	var x := r.position.x
	while x < r.end.x:
		ci.draw_rect(Rect2(x, r.position.y, 9, r.size.y), stripe)
		x += 34
	if damage > 0.0:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		for i in int(10 * damage):
			var p := Vector2(rng.randf_range(r.position.x, r.end.x), rng.randf_range(r.position.y, r.end.y))
			var w := rng.randf_range(30, 120)
			var h := rng.randf_range(20, 90)
			var pc := base.lightened(rng.randf_range(0.08, 0.2))
			pc.a = 0.55
			poly(ci, [p, p + Vector2(w, rng.randf_range(-10, 10)), p + Vector2(w * 0.8, h), p + Vector2(w * 0.1, h * 0.7)], pc)
		grime(ci, r, Color(0.2, 0.16, 0.08, 0.5 * damage), seed_value + 1, int(14 * damage))


static func wood_panels(ci: CanvasItem, r: Rect2, c: Color, step := 46.0) -> void:
	ci.draw_rect(r, c)
	var x := r.position.x
	while x < r.end.x:
		ci.draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), c.darkened(0.25), 2.0)
		x += step


static func sign_box(ci: CanvasItem, r: Rect2, text_value: String, bg: Color, fg: Color, size := 22, f: Font = null) -> void:
	ci.draw_rect(r, bg)
	ci.draw_rect(r, bg.darkened(0.4), false, 2.0)
	var fnt := f if f != null else font()
	var w := fnt.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	ci.draw_string(fnt, Vector2(r.get_center().x - w * 0.5, r.get_center().y + size * 0.35), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, fg)


## A cloth banner hung from two points, sagging a little.
static func banner(ci: CanvasItem, r: Rect2, text_value: String, bg: Color, fg: Color, size := 26) -> void:
	var sag := 8.0
	var top: Array = []
	var bottom: Array = []
	for i in 9:
		var t := i / 8.0
		var y := sin(t * PI) * sag
		top.append(Vector2(r.position.x + r.size.x * t, r.position.y + y))
		bottom.append(Vector2(r.position.x + r.size.x * t, r.end.y + y))
	bottom.reverse()
	poly(ci, top + bottom, bg)
	ci.draw_line(r.position + Vector2(0, -18), r.position, Color(0.1, 0.1, 0.1), 2.0)
	ci.draw_line(Vector2(r.end.x, r.position.y - 18), Vector2(r.end.x, r.position.y), Color(0.1, 0.1, 0.1), 2.0)
	var fnt := font()
	var w := fnt.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	ci.draw_string(fnt, Vector2(r.get_center().x - w * 0.5, r.get_center().y + size * 0.35 + sag * 0.6), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, fg)


static func neon(ci: CanvasItem, pos: Vector2, text_value: String, c: Color, size := 34, on := true) -> void:
	var fnt := font()
	if on:
		glow_ellipse(ci, pos + Vector2(fnt.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x * 0.5, -size * 0.3), size * text_value.length() * 0.45, size * 1.4, Color(c.r, c.g, c.b, 0.35))
	ci.draw_string_outline(fnt, pos, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(c.r, c.g, c.b, 0.5 if on else 0.15))
	ci.draw_string(fnt, pos, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, c.lightened(0.5) if on else c.darkened(0.6))


static func sofa(ci: CanvasItem, pos: Vector2, w: float, c: Color) -> void:
	ci.draw_rect(Rect2(pos.x, pos.y - 110, w, 60), c.darkened(0.1))
	ci.draw_rect(Rect2(pos.x - 14, pos.y - 70, w + 28, 46), c)
	ci.draw_rect(Rect2(pos.x - 22, pos.y - 90, 30, 70), c.darkened(0.15))
	ci.draw_rect(Rect2(pos.x + w - 8, pos.y - 90, 30, 70), c.darkened(0.15))
	ci.draw_rect(Rect2(pos.x - 10, pos.y - 24, 8, 24), c.darkened(0.5))
	ci.draw_rect(Rect2(pos.x + w + 2, pos.y - 24, 8, 24), c.darkened(0.5))


static func bed(ci: CanvasItem, pos: Vector2, w: float, c: Color) -> void:
	ci.draw_rect(Rect2(pos.x, pos.y - 150, 16, 150), c.darkened(0.4))
	ci.draw_rect(Rect2(pos.x, pos.y - 70, w, 40), c.darkened(0.2))
	ci.draw_rect(Rect2(pos.x + 6, pos.y - 92, w - 10, 26), Color(0.86, 0.86, 0.82))
	ci.draw_rect(Rect2(pos.x + 20, pos.y - 104, 80, 18), Color(0.92, 0.92, 0.9))
	ci.draw_rect(Rect2(pos.x + w - 12, pos.y - 30, 10, 30), c.darkened(0.5))


static func monitor(ci: CanvasItem, pos: Vector2, s := 1.0, on := true) -> void:
	ci.draw_rect(Rect2(pos + Vector2(-34, -62) * s, Vector2(68, 54) * s), Color(0.78, 0.76, 0.68))
	ci.draw_rect(Rect2(pos + Vector2(-27, -56) * s, Vector2(54, 40) * s), Color(0.12, 0.28, 0.24) if on else Color(0.08, 0.09, 0.09))
	if on:
		for i in 4:
			ci.draw_line(pos + Vector2(-22, -48 + i * 8) * s, pos + Vector2(-22 + 30 - i * 5, -48 + i * 8) * s, Color(0.5, 0.95, 0.7, 0.6), 1.5)
	ci.draw_rect(Rect2(pos + Vector2(-12, -8) * s, Vector2(24, 8) * s), Color(0.7, 0.68, 0.6))


## Office cubicle: fabric partition, desk, monitor.
static func cubicle(ci: CanvasItem, x: float, floor_y: float, w: float, c: Color, on := true) -> void:
	ci.draw_rect(Rect2(x, floor_y - 170, w, 170), c)
	ci.draw_rect(Rect2(x, floor_y - 176, w, 8), c.darkened(0.3))
	ci.draw_line(Vector2(x + w, floor_y - 176), Vector2(x + w, floor_y), c.darkened(0.4), 3.0)
	table(ci, Rect2(x + 14, floor_y - 92, w - 30, 92), Color(0.62, 0.6, 0.55), Color(0.3, 0.3, 0.3))
	monitor(ci, Vector2(x + w * 0.5, floor_y - 92), 1.0, on)


static func counter(ci: CanvasItem, r: Rect2, top: Color, front: Color) -> void:
	ci.draw_rect(Rect2(r.position.x - 6, r.position.y, r.size.x + 12, 12), top)
	ci.draw_rect(Rect2(r.position.x, r.position.y + 12, r.size.x, r.size.y - 12), front)
	ci.draw_line(Vector2(r.position.x, r.position.y + 12), Vector2(r.end.x, r.position.y + 12), front.darkened(0.4), 3.0)


static func bottles(ci: CanvasItem, r: Rect2, seed_value := 23) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var shelves := 3
	for s in shelves:
		var y := r.position.y + (s + 1) * r.size.y / shelves
		ci.draw_rect(Rect2(r.position.x, y - 4, r.size.x, 6), Color(0.25, 0.16, 0.1))
		var x := r.position.x + 6
		while x < r.end.x - 14:
			var h := rng.randf_range(28, 46)
			var c := Color(rng.randf_range(0.2, 0.6), rng.randf_range(0.3, 0.5), rng.randf_range(0.1, 0.3), 0.85)
			ci.draw_rect(Rect2(x, y - 4 - h, 11, h), c)
			ci.draw_rect(Rect2(x + 3, y - 4 - h - 10, 5, 10), c.darkened(0.2))
			x += rng.randf_range(15, 22)


static func stove(ci: CanvasItem, pos: Vector2) -> void:
	ci.draw_rect(Rect2(pos.x, pos.y - 100, 110, 100), Color(0.78, 0.76, 0.7))
	ci.draw_rect(Rect2(pos.x + 10, pos.y - 70, 90, 56), Color(0.18, 0.18, 0.18))
	ci.draw_rect(Rect2(pos.x - 2, pos.y - 104, 114, 6), Color(0.3, 0.3, 0.3))
	for i in 3:
		ci.draw_circle(Vector2(pos.x + 20 + i * 35, pos.y - 84), 5, Color(0.2, 0.2, 0.2))


static func fridge(ci: CanvasItem, pos: Vector2, c := Color(0.82, 0.8, 0.72)) -> void:
	ci.draw_rect(Rect2(pos.x, pos.y - 190, 90, 190), c)
	ci.draw_line(Vector2(pos.x, pos.y - 125), Vector2(pos.x + 90, pos.y - 125), c.darkened(0.3), 2.0)
	ci.draw_rect(Rect2(pos.x + 74, pos.y - 165, 6, 30), c.darkened(0.4))
	ci.draw_rect(Rect2(pos.x + 74, pos.y - 110, 6, 40), c.darkened(0.4))


static func pot(ci: CanvasItem, pos: Vector2, w: float, c: Color, t := 0.0, steam := false) -> void:
	poly(ci, [pos + Vector2(-w * 0.5, -w * 0.7), pos + Vector2(w * 0.5, -w * 0.7), pos + Vector2(w * 0.45, 0), pos + Vector2(-w * 0.45, 0)], c)
	ci.draw_rect(Rect2(pos + Vector2(-w * 0.55, -w * 0.74), Vector2(w * 1.1, 6)), c.lightened(0.15))
	if steam:
		for i in 3:
			var pts := PackedVector2Array()
			for j in 10:
				var k := j / 9.0
				pts.append(pos + Vector2(-w * 0.25 + i * w * 0.25 + sin(t * 2.0 + k * 5.0 + i) * 8.0, -w * 0.75 - k * 90.0))
			ci.draw_polyline(pts, Color(0.9, 0.9, 0.88, 0.16), 5.0, true)


static func plane_seat(ci: CanvasItem, pos: Vector2, s: float, c: Color, face := 1) -> void:
	var f := float(face)
	poly(ci, [pos + Vector2(-34 * f, -40) * s, pos + Vector2(-20 * f, -190) * s, pos + Vector2(6 * f, -196) * s, pos + Vector2(4 * f, -40) * s], c)
	ci.draw_rect(Rect2(pos + Vector2(min(-34 * f, 50 * f), -62) * s, Vector2(84, 24) * s), c.darkened(0.12))
	ci.draw_rect(Rect2(pos + Vector2(min(-22 * f, 8 * f), -196) * s, Vector2(30, 34) * s), Color(0.85, 0.85, 0.82))
	ci.draw_rect(Rect2(pos + Vector2(min(-6 * f, 4 * f), -40) * s, Vector2(10, 40) * s), Color(0.2, 0.2, 0.22))


static func streetlight(ci: CanvasItem, pos: Vector2, h: float, on := true) -> Vector2:
	ci.draw_line(pos, pos + Vector2(0, -h), Color(0.12, 0.13, 0.13), 7.0)
	ci.draw_line(pos + Vector2(0, -h), pos + Vector2(46, -h - 8), Color(0.12, 0.13, 0.13), 5.0)
	var lamp := pos + Vector2(50, -h - 2)
	ci.draw_rect(Rect2(lamp - Vector2(14, 4), Vector2(28, 8)), Color(0.2, 0.2, 0.2))
	if on:
		glow(ci, lamp + Vector2(0, 8), 90, Color(1.0, 0.8, 0.45, 0.4))
		light_cone(ci, lamp + Vector2(0, 6), pos.y, 120, Color(1.0, 0.82, 0.5, 0.12))
	return lamp


static func dumpster(ci: CanvasItem, pos: Vector2, c := Color(0.18, 0.3, 0.22)) -> void:
	poly(ci, [pos + Vector2(-90, -120), pos + Vector2(90, -120), pos + Vector2(80, 0), pos + Vector2(-80, 0)], c)
	poly(ci, [pos + Vector2(-96, -120), pos + Vector2(96, -120), pos + Vector2(90, -136), pos + Vector2(-90, -132)], c.darkened(0.3))
	ci.draw_line(pos + Vector2(-70, -60), pos + Vector2(70, -60), c.darkened(0.2), 3.0)


static func fence(ci: CanvasItem, y: float, x0: float, x1: float, h: float, c: Color) -> void:
	ci.draw_line(Vector2(x0, y - h), Vector2(x1, y - h), c, 3.0)
	var x := x0
	while x <= x1:
		ci.draw_line(Vector2(x, y), Vector2(x, y - h), c, 4.0)
		x += 80
	x = x0
	while x <= x1:
		ci.draw_line(Vector2(x, y), Vector2(x + 40, y - h), Color(c.r, c.g, c.b, c.a * 0.5), 1.0)
		ci.draw_line(Vector2(x + 40, y), Vector2(x, y - h), Color(c.r, c.g, c.b, c.a * 0.5), 1.0)
		x += 20


static func van(ci: CanvasItem, pos: Vector2, c: Color, face := 1, s := 1.6) -> void:
	var f := float(face)
	var pts := [Vector2(-160, -24), Vector2(-160, -170), Vector2(90, -170), Vector2(140, -110), Vector2(162, -100), Vector2(162, -24)]
	var arr: Array = []
	for p in pts:
		arr.append(pos + Vector2(p.x * f, p.y) * s)
	poly(ci, arr, c)
	poly(ci, [pos + Vector2(96 * f, -160) * s, pos + Vector2(132 * f, -112) * s, pos + Vector2(96 * f, -112) * s], Color(0.15, 0.2, 0.22))
	ci.draw_line(pos + Vector2(-60 * f, -165) * s, pos + Vector2(-60 * f, -30) * s, c.darkened(0.3), 2.0)
	for wx in [-110.0, 108.0]:
		ci.draw_circle(pos + Vector2(wx * f, -22) * s, 26 * s, Color(0.05, 0.05, 0.05))
		ci.draw_circle(pos + Vector2(wx * f, -22) * s, 11 * s, Color(0.4, 0.4, 0.4))


static func phone_booth(ci: CanvasItem, pos: Vector2) -> void:
	ci.draw_rect(Rect2(pos.x - 40, pos.y - 230, 80, 230), Color(0.25, 0.27, 0.28))
	ci.draw_rect(Rect2(pos.x - 32, pos.y - 210, 64, 170), Color(0.5, 0.6, 0.62, 0.35))
	ci.draw_rect(Rect2(pos.x - 40, pos.y - 246, 80, 18), Color(0.12, 0.3, 0.5))
	ci.draw_string(font(), Vector2(pos.x - 30, pos.y - 231), "PHONE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.9, 0.9, 0.9))
	ci.draw_rect(Rect2(pos.x - 16, pos.y - 150, 32, 46), Color(0.12, 0.12, 0.12))
