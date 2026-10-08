extends Node
## Title screen: the flight through the brain, the soap bar, the menu.

const NeuralField := preload("res://scripts/ui/neural_field.gd")
const SoapBar := preload("res://scripts/ui/soap_bar.gd")
const SettingsPanel := preload("res://scripts/ui/settings_panel.gd")

var _ui: Control
var _menu: VBoxContainer
var _panel_open := false


func _ready() -> void:
	add_child(NeuralField.new())
	var soap := SoapBar.new()
	soap.position = Vector2(380, 300)
	add_child(soap)
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_ui = UI.root()
	layer.add_child(_ui)
	var sub := UI.label("subtitle", "Heading", HORIZONTAL_ALIGNMENT_CENTER)
	sub.position = Vector2(110, 470)
	sub.size = Vector2(540, 50)
	sub.add_theme_font_size_override("font_size", 26)
	sub.add_theme_color_override("font_color", Color(Loc.PAPER, 0.8))
	_ui.add_child(sub)
	var disc := UI.label("disclaimer", "Small", HORIZONTAL_ALIGNMENT_CENTER)
	disc.position = Vector2(80, 672)
	disc.size = Vector2(1120, 30)
	disc.add_theme_font_size_override("font_size", 15)
	_ui.add_child(disc)
	_build_menu()
	Film.clear()
	Film.set_grade("dream")
	Sound.play_music("menu", 2.0)
	Settings.language_changed.connect(func(_l): _build_menu())


func _build_menu() -> void:
	if _menu != null:
		_menu.queue_free()
	_menu = UI.vbox(10)
	_menu.position = Vector2(800, 150)
	_menu.custom_minimum_size = Vector2(380, 0)
	_ui.add_child(_menu)
	var first: Button = null
	if Settings.current_chapter >= 0:
		first = _add("continue", func(): Game.play_chapter(Settings.current_chapter))
	var start := _add("new_game", func(): Game.play_chapter(0))
	if first == null:
		first = start
	_add("chapters", _open_chapters)
	_add("rules", _open_rules)
	_add("settings", _open_settings)
	_add("credits", func(): Game.show_credits())
	_add("lang_switch", func(): Settings.toggle_lang())
	if not OS.has_feature("web"):
		_add("quit", func(): Game.quit())
	first.grab_focus.call_deferred()


func _add(key: String, cb: Callable) -> Button:
	var b := UI.button(key, cb, "BigButton")
	b.alignment = HORIZONTAL_ALIGNMENT_RIGHT if Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT
	_menu.add_child(b)
	return b


func _panel() -> Dictionary:
	_panel_open = true
	var holder := Control.new()
	UI.full(holder)
	_ui.add_child(holder)
	var shade := UI.dim(0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	holder.add_child(shade)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820, 0)
	holder.add_child(UI.center(panel))
	var v := UI.vbox(12)
	panel.add_child(v)
	return {"holder": holder, "box": v}


func _close_button(holder: Control) -> Button:
	var b := UI.button("back", func():
		_panel_open = false
		holder.queue_free()
		_build_menu(), "BigButton")
	return b


func _open_chapters() -> void:
	var p := _panel()
	var v: VBoxContainer = p["box"]
	v.add_child(UI.label("chapters", "Heading", HORIZONTAL_ALIGNMENT_CENTER))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	v.add_child(grid)
	for i in Game.CHAPTERS.size():
		var idx := i
		var locked := i > Settings.unlocked
		var text := Game.chapter_label(i) + " · " + (Loc.t("locked") if locked else Game.chapter_title(i))
		var b := Button.new()
		b.text = text
		b.disabled = locked
		b.custom_minimum_size = Vector2(390, 54)
		b.alignment = HORIZONTAL_ALIGNMENT_RIGHT if Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT
		b.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
		b.clip_text = true
		b.pressed.connect(func(): Game.play_chapter(idx))
		grid.add_child(b)
	var back := _close_button(p["holder"])
	v.add_child(back)
	back.grab_focus.call_deferred()


func _open_rules() -> void:
	var p := _panel()
	var v: VBoxContainer = p["box"]
	v.add_child(UI.label("rules_title", "Heading", HORIZONTAL_ALIGNMENT_CENTER))
	for i in Loc.RULES.size():
		var l := Label.new()
		l.theme_type_variation = "Line"
		l.add_theme_font_size_override("font_size", 22)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(780, 0)
		l.text = Loc.pick(Loc.RULES[i])
		if i < 2:
			l.add_theme_color_override("font_color", Loc.SOAP)
		UI.apply_dir(l)
		v.add_child(l)
	var back := _close_button(p["holder"])
	v.add_child(back)
	back.grab_focus.call_deferred()


func _open_settings() -> void:
	var s := SettingsPanel.new()
	s.allow_reset = true
	s.closed.connect(_build_menu)
	_ui.add_child(s)
