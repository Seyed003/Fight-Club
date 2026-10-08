extends Control
## Subtitle band at the bottom of the frame. Spoken lines show the
## speaker's name; the narrator's voice-over has no name and a warmer tone.

const CPS := 42.0
const NARR_COLOR := Color(0.93, 0.90, 0.78)

var typing := false
var _name: Label
var _text: Label
var _arrow: Label
var _band: TextureRect
var _chars := 0.0
var _total := 0
var _pair: Dictionary = {}
var _who := ""
var _t := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_band = TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0))
	g.set_color(1, Color(0, 0, 0, 0.88))
	g.add_point(0.35, Color(0, 0, 0, 0.55))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 4
	tex.height = 64
	_band.texture = tex
	_band.stretch_mode = TextureRect.STRETCH_SCALE
	_band.position = Vector2(0, 470)
	_band.size = Vector2(1280, 250)
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_band)
	_name = Label.new()
	_name.theme_type_variation = "Name"
	_name.position = Vector2(150, 560)
	_name.size = Vector2(980, 30)
	add_child(_name)
	_text = Label.new()
	_text.theme_type_variation = "Line"
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.position = Vector2(150, 594)
	_text.size = Vector2(980, 110)
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	add_child(_text)
	_arrow = Label.new()
	_arrow.text = "▼"
	_arrow.theme_type_variation = "Small"
	_arrow.size = Vector2(30, 30)
	add_child(_arrow)
	Settings.language_changed.connect(func(_l): _refresh())
	hide_box()


func show_line(who: String, pair: Dictionary) -> void:
	_who = who
	_pair = pair
	visible = true
	_refresh()
	_chars = 0.0
	typing = true
	_text.visible_characters = 0


func _refresh() -> void:
	if _pair.is_empty():
		return
	var narr := _who == "narr"
	_name.text = "" if narr else Cast.display_name(_who)
	_name.add_theme_color_override("font_color", Cast.name_color(_who))
	_text.text = Loc.pick(_pair)
	_text.add_theme_color_override("font_color", NARR_COLOR if narr else Loc.PAPER)
	_total = _text.get_total_character_count()
	UI.apply_dir(_name)
	UI.apply_dir(_text)
	_arrow.position = Vector2(140 if Loc.is_rtl() else 1120, 676)
	if not typing:
		_text.visible_characters = -1


func complete() -> void:
	typing = false
	_text.visible_characters = -1


func text_length() -> int:
	return _total


func hide_box() -> void:
	visible = false
	typing = false
	_pair = {}


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	if typing:
		_chars += delta * CPS * Settings.text_speed
		_text.visible_characters = int(_chars)
		if int(_chars) >= _total:
			complete()
	_arrow.visible = not typing and fmod(_t, 1.0) < 0.6
