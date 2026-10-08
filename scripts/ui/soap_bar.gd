extends Node2D
## The pink bar of soap with "FIGHT CLUB" pressed into it.

var size := Vector2(420, 230)
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	rotation = -0.12 + sin(_t * 0.6) * 0.02
	queue_redraw()


func _rounded(r: Rect2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var corners := [r.position + Vector2(radius, radius), Vector2(r.end.x - radius, r.position.y + radius),
		r.end - Vector2(radius, radius), Vector2(r.position.x + radius, r.end.y - radius)]
	var starts := [PI, PI * 1.5, 0.0, PI * 0.5]
	for c in 4:
		for i in 7:
			var a: float = starts[c] + PI * 0.5 * i / 6.0
			pts.append(corners[c] + Vector2(cos(a), sin(a)) * radius)
	return pts


func _draw() -> void:
	var r := Rect2(-size * 0.5, size)
	Paint.glow_ellipse(self, Vector2(0, 30), size.x * 0.75, size.y * 0.7, Color(0.95, 0.5, 0.6, 0.12))
	draw_colored_polygon(_rounded(Rect2(r.position + Vector2(6, 14), r.size), 54), Color(0, 0, 0, 0.45))
	draw_colored_polygon(_rounded(r, 54), Color(0.80, 0.45, 0.53))
	draw_colored_polygon(_rounded(r.grow(-10), 46), Color(0.96, 0.67, 0.74))
	draw_colored_polygon(_rounded(Rect2(r.position + Vector2(24, 18), Vector2(r.size.x - 48, 40)), 18), Color(1, 1, 1, 0.16))
	var f: Font = Loc.font_fa_black
	var lines := ["FIGHT", "CLUB"]
	for i in 2:
		var y := -8.0 + i * 74.0
		var w := f.get_string_size(lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 74).x
		var pos := Vector2(-w * 0.5, y)
		draw_string(f, pos + Vector2(0, 2.5), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 74, Color(1, 0.86, 0.9, 0.85))
		draw_string(f, pos, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 74, Color(0.72, 0.33, 0.43))
