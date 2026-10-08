extends Node
## Rolling credits, then back to the title screen.

const LINES := [
	["title", {"fa": "FIGHT CLUB", "en": "FIGHT CLUB"}],
	["small", {"fa": "یک بازی هواداری", "en": "A fan game"}],
	["gap", {}],
	["head", {"fa": "بر اساس", "en": "Based on"}],
	["body", {"fa": "فیلم «باشگاه مشت‌زنی» (۱۹۹۹) به کارگردانی دیوید فینچر", "en": "the film Fight Club (1999), directed by David Fincher"}],
	["body", {"fa": "و رمان چاک پالانیک", "en": "and the novel by Chuck Palahniuk"}],
	["gap", {}],
	["head", {"fa": "ساخته‌شده با", "en": "Made with"}],
	["body", {"fa": "موتور بازی‌سازی Godot", "en": "the Godot Engine"}],
	["body", {"fa": "همه‌ی تصویرها، صداها و موسیقی با کد ساخته شده‌اند", "en": "Every image, sound and note is generated in code"}],
	["gap", {}],
	["head", {"fa": "قلم‌ها", "en": "Fonts"}],
	["body", {"fa": "وزیرمتن، اثر صابر راستی‌کردار (OFL)", "en": "Vazirmatn by Saber Rastikerdar (OFL)"}],
	["body", {"fa": "Special Elite، اثر Astigmatic (Apache 2.0)", "en": "Special Elite by Astigmatic (Apache 2.0)"}],
	["gap", {}],
	["small", {"fa": "این بازی غیرتجاری است و ارتباطی با سازندگان فیلم یا کتاب ندارد.", "en": "Non-commercial. Not affiliated with the makers of the film or the novel."}],
	["gap", {}],
	["gap", {}],
	["head", {"fa": "قانون اول فایت کلاب...", "en": "The first rule of Fight Club..."}],
]

var _scroll: Control
var _speed := 46.0
var _done := false


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var root := UI.root()
	layer.add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.01, 0.01)
	UI.full(bg)
	root.add_child(bg)
	var v := UI.vbox(14)
	v.position = Vector2(190, 760)
	v.custom_minimum_size = Vector2(900, 0)
	root.add_child(v)
	_scroll = v
	for entry in LINES:
		var kind: String = entry[0]
		if kind == "gap":
			var gap := Control.new()
			gap.custom_minimum_size = Vector2(0, 46)
			v.add_child(gap)
			continue
		var l := Label.new()
		l.text = Loc.pick(entry[1])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(900, 0)
		l.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
		match kind:
			"title":
				l.theme_type_variation = "Title"
				l.add_theme_color_override("font_color", Loc.SOAP)
			"head":
				l.theme_type_variation = "Heading"
				l.add_theme_font_size_override("font_size", 26)
				l.add_theme_color_override("font_color", Loc.SOAP)
			"small":
				l.theme_type_variation = "Small"
			_:
				l.theme_type_variation = "Line"
		v.add_child(l)
	Film.clear()
	Film.set_grade("normal")
	Sound.play_music("ending", 2.0)


func _process(delta: float) -> void:
	if _done:
		return
	_scroll.position.y -= delta * _speed * (6.0 if Input.is_action_pressed("advance") else 1.0)
	if _scroll.position.y + _scroll.size.y < -40.0 or Game.autoplay:
		_done = true
		Game.goto_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _done:
		_done = true
		Game.goto_menu()
