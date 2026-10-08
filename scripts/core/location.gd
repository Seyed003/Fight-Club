class_name Location
extends RefCounted
## Base for every place in the film. A location paints three layers
## (static background, animated background, foreground in front of the
## actors) and describes its lighting.

var id := ""
var floor_y := 640.0
## CanvasModulate colour. Lower values make the practical lights matter.
var ambient := Color(0.62, 0.64, 0.62)
var grade := "normal"
var animated := false
var front_animated := false
var amb := ""
var amb_db := -8.0
var t := 0.0


## Each light: {pos, radius, color, energy, flicker (0..1), swing (rad), swing_speed, length}
func lights() -> Array:
	return []


func draw_static(_ci: CanvasItem) -> void:
	pass


func draw_anim(_ci: CanvasItem) -> void:
	pass


func draw_front(_ci: CanvasItem) -> void:
	pass


func update(delta: float) -> void:
	t += delta


## Where the swinging bulb is right now, so the drawn bulb and its light agree.
func swing_offset(light: Dictionary) -> Vector2:
	var sw: float = light.get("swing", 0.0)
	if sw == 0.0:
		return Vector2.ZERO
	var length: float = light.get("length", 120.0)
	var a := sin(t * float(light.get("swing_speed", 1.3))) * sw
	return Vector2(sin(a) * length, (cos(a) - 1.0) * length)
