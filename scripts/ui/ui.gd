class_name UI
extends RefCounted
## Small builders so screens can be assembled in code without .tscn files.


static func label(source: Variant, variation := "", align := -1) -> Label:
	var l := Label.new()
	if variation != "":
		l.theme_type_variation = variation
	if source != null:
		Loc.bind(l, source)
	if align >= 0:
		l.horizontal_alignment = align
	return l


static func button(source: Variant, on_press: Callable, variation := "") -> Button:
	var b := Button.new()
	if variation != "":
		b.theme_type_variation = variation
	Loc.bind(b, source)
	b.pressed.connect(func():
		Sound.sfx("ui_click", -6.0)
		on_press.call())
	b.mouse_entered.connect(func(): Sound.sfx("ui_hover", -16.0, 1.0, 0.02))
	return b


static func vbox(gap := 12) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", gap)
	return v


static func hbox(gap := 12) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", gap)
	return h


static func full(c: Control) -> Control:
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	return c


static func dim(alpha := 0.6) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0, 0, 0, alpha)
	full(r)
	return r


## Root control for a CanvasLayer: carries the shared theme.
static func root() -> Control:
	var c := Control.new()
	full(c)
	c.theme = Loc.theme
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func center(child: Control) -> CenterContainer:
	var cc := CenterContainer.new()
	full(cc)
	cc.add_child(child)
	return cc


static func slider(value: float, on_change: Callable, min_v := 0.0, max_v := 1.0, step := 0.05) -> HSlider:
	var s := HSlider.new()
	s.min_value = min_v
	s.max_value = max_v
	s.step = step
	s.value = value
	s.custom_minimum_size = Vector2(260, 28)
	s.value_changed.connect(on_change)
	return s


static func check(source: Variant, value: bool, on_toggle: Callable) -> CheckBox:
	var c := CheckBox.new()
	Loc.bind(c, source)
	c.button_pressed = value
	c.toggled.connect(on_toggle)
	return c


static func apply_dir(l: Control) -> void:
	l.set("text_direction", Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR)
	if l is Label:
		(l as Label).horizontal_alignment = Loc.align()
