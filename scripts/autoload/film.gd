extends Node
## The camera and the print: fades, flashes, shake, letterbox, colour
## grades, single-frame subliminal cuts and cigarette burns. Everything
## drawn below layer 90 passes through the film shader.

const GRADES := {
	"normal": {"desaturate": 0.22, "contrast": 1.1, "shadow_tint": Vector3(0.02, 0.055, 0.04), "highlight_tint": Vector3(1.0, 0.96, 0.86), "exposure": 1.0, "mono": 0.0, "scanlines": 0.0},
	"office": {"desaturate": 0.35, "contrast": 1.05, "shadow_tint": Vector3(0.03, 0.07, 0.05), "highlight_tint": Vector3(0.93, 1.0, 0.9), "exposure": 1.02, "mono": 0.0, "scanlines": 0.0},
	"warm": {"desaturate": 0.18, "contrast": 1.12, "shadow_tint": Vector3(0.05, 0.04, 0.0), "highlight_tint": Vector3(1.0, 0.92, 0.72), "exposure": 1.0, "mono": 0.0, "scanlines": 0.0},
	"night": {"desaturate": 0.3, "contrast": 1.15, "shadow_tint": Vector3(0.0, 0.04, 0.06), "highlight_tint": Vector3(0.95, 0.97, 1.0), "exposure": 0.92, "mono": 0.0, "scanlines": 0.0},
	"cold": {"desaturate": 0.4, "contrast": 1.08, "shadow_tint": Vector3(0.0, 0.05, 0.07), "highlight_tint": Vector3(0.9, 0.97, 1.0), "exposure": 0.98, "mono": 0.0, "scanlines": 0.0},
	"dream": {"desaturate": 0.0, "contrast": 1.0, "shadow_tint": Vector3(0.0, 0.03, 0.08), "highlight_tint": Vector3(0.92, 1.0, 1.0), "exposure": 1.05, "mono": 0.0, "scanlines": 0.0},
	"cam": {"desaturate": 0.9, "contrast": 1.25, "shadow_tint": Vector3(0.0, 0.02, 0.0), "highlight_tint": Vector3(1.0, 1.0, 1.0), "exposure": 1.05, "mono": 1.0, "scanlines": 1.0},
	"memory": {"desaturate": 0.55, "contrast": 1.2, "shadow_tint": Vector3(0.04, 0.03, 0.01), "highlight_tint": Vector3(1.0, 0.9, 0.75), "exposure": 0.95, "mono": 0.0, "scanlines": 0.0},
}

var _post: ColorRect
var _mat: ShaderMaterial
var _sub_layer: CanvasLayer
var _fade: ColorRect
var _flash: ColorRect
var _bars: Array[ColorRect] = []
var _seed_t := 0.0
var _seed := 0.0
var _shake_amount := 0.0
var _shake_time := 0.0
var _glitch := 0.0
var _glitch_time := 0.0
var _burn := 0.0
var _red := 0.0
var _base_glitch := 0.0
var grade_name := "normal"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sub_layer = _layer(80)
	var post_layer := _layer(90)
	_post = ColorRect.new()
	_post.set_anchors_preset(Control.PRESET_FULL_RECT)
	_post.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://shaders/film.gdshader")
	_post.material = _mat
	post_layer.add_child(_post)

	var bar_layer := _layer(91)
	for i in 2:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.size = Vector2(1280, 0)
		bar.position = Vector2(0, 0 if i == 0 else 720)
		bar_layer.add_child(bar)
		_bars.append(bar)

	var flash_layer := _layer(118)
	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 1, 1, 0)
	flash_layer.add_child(_flash)

	var fade_layer := _layer(120)
	_fade = ColorRect.new()
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.color = Color(0, 0, 0, 0)
	fade_layer.add_child(_fade)
	set_grade("normal")
	Settings.audio_changed.connect(_sync_grain)
	_sync_grain()


func _layer(n: int) -> CanvasLayer:
	var l := CanvasLayer.new()
	l.layer = n
	add_child(l)
	return l


func _sync_grain() -> void:
	_mat.set_shader_parameter("grain_amount", 0.07 if Settings.film_grain else 0.0)
	_mat.set_shader_parameter("scratches", 1.0 if Settings.film_grain else 0.0)
	_mat.set_shader_parameter("flicker", 0.035 if Settings.film_grain else 0.0)


func _process(delta: float) -> void:
	_seed_t += delta
	if _seed_t >= 1.0 / 24.0:
		_seed_t = 0.0
		_seed = fmod(_seed + 1.0, 1000.0)
		_mat.set_shader_parameter("seed", _seed)
	if _shake_time > 0.0:
		_shake_time -= delta
		var k: float = _shake_amount * clamp(_shake_time * 3.0, 0.0, 1.0)
		_mat.set_shader_parameter("shake", Vector2(randf_range(-k, k) / 1280.0, randf_range(-k, k) / 720.0))
		if _shake_time <= 0.0:
			_mat.set_shader_parameter("shake", Vector2.ZERO)
	if _glitch_time > 0.0:
		_glitch_time -= delta
		var g := _glitch if _glitch_time > 0.0 else 0.0
		_mat.set_shader_parameter("glitch", max(g, _base_glitch))
	if _burn > 0.0:
		_burn = max(0.0, _burn - delta * 1.6)
		_mat.set_shader_parameter("burn", 1.0 if _burn > 0.5 else _burn * 2.0)
	if _red > 0.0:
		_red = max(0.0, _red - delta * 4.0)
		_mat.set_shader_parameter("red_flash", _red)


func set_grade(preset: String, time := 0.0) -> void:
	if not GRADES.has(preset):
		preset = "normal"
	grade_name = preset
	var g: Dictionary = GRADES[preset]
	for key in g:
		var v = g[key]
		if v is Vector3:
			v = Vector3(v)
		if time <= 0.0:
			_mat.set_shader_parameter(key, v)
		else:
			var from = _mat.get_shader_parameter(key)
			if from == null:
				from = v
			var tw := create_tween()
			tw.tween_method(func(x): _mat.set_shader_parameter(key, x), from, v, time)


func fade_out(time := 0.8) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, time)
	await tw.finished


func fade_in(time := 0.8) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 0.0, time)
	await tw.finished


func black() -> void:
	_fade.color.a = 1.0


func clear() -> void:
	_fade.color.a = 0.0


func is_black() -> bool:
	return _fade.color.a > 0.99


## The fade overlay, so callers can own the tween that animates it.
func fade_rect() -> ColorRect:
	return _fade


func white_flash(time := 0.35, color := Color.WHITE) -> void:
	_flash.color = Color(color, 1.0)
	var tw := create_tween()
	tw.tween_property(_flash, "color:a", 0.0, time)


func red_flash(amount := 1.0) -> void:
	_red = max(_red, amount)
	_mat.set_shader_parameter("red_flash", _red)


func shake(amount := 8.0, time := 0.35) -> void:
	_shake_amount = max(amount, _shake_amount if _shake_time > 0.0 else 0.0)
	_shake_time = max(time, _shake_time)


func glitch(amount := 0.6, time := 0.4) -> void:
	_glitch = amount
	_glitch_time = time
	_mat.set_shader_parameter("glitch", amount)


## A low, constant glitch for scenes where reality is coming apart.
func set_base_glitch(amount: float) -> void:
	_base_glitch = amount
	_mat.set_shader_parameter("glitch", amount)


func cigarette_burn() -> void:
	_burn = 1.4
	_mat.set_shader_parameter("burn", 1.0)


func letterbox(on: bool, time := 0.6) -> void:
	var h := 92.0 if on else 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_bars[0], "size:y", h, time)
	tw.tween_property(_bars[1], "size:y", h, time)
	tw.tween_property(_bars[1], "position:y", 720.0 - h, time)


## Splices a single frame of someone into the picture, the way Tyler
## appears in the film before the narrator meets him.
func subliminal(look_id: String, pos: Vector2, size := 1.0, frames := 2, pose := "stand", facing := 1) -> void:
	var p := Puppet.new()
	p.set_look(look_id)
	p.position = pos
	p.scale = Vector2(size, size)
	p.facing = facing
	p.snap_pose(pose)
	p.expr = "smirk"
	_sub_layer.add_child(p)
	for i in frames:
		await get_tree().process_frame
	p.queue_free()


func reset() -> void:
	set_grade("normal")
	set_base_glitch(0.0)
	_glitch_time = 0.0
	_mat.set_shader_parameter("glitch", 0.0)
	_mat.set_shader_parameter("shake", Vector2.ZERO)
	_shake_time = 0.0
	for b in _bars:
		b.size.y = 0.0
	_bars[1].position.y = 720.0
