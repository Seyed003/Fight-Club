extends Node
## Bilingual text, fonts and the shared UI theme.
## Story lines carry their own {fa, en} pairs; this file holds UI strings.

const PERSIAN_DIGITS := "۰۱۲۳۴۵۶۷۸۹"

## UI palette. Grimy greens and a soap-pink accent.
const INK := Color(0.055, 0.065, 0.06)
const INK_SOFT := Color(0.10, 0.12, 0.11)
const PAPER := Color(0.92, 0.89, 0.81)
const PAPER_DIM := Color(0.66, 0.65, 0.59)
const SOAP := Color(0.95, 0.63, 0.71)
const SOAP_DEEP := Color(0.72, 0.33, 0.43)
const BLOOD := Color(0.66, 0.09, 0.09)
const BILE := Color(0.62, 0.70, 0.48)

const S := {
	"new_game": {"fa": "شروع داستان", "en": "New Story"},
	"continue": {"fa": "ادامه", "en": "Continue"},
	"chapters": {"fa": "فصل‌ها", "en": "Chapters"},
	"settings": {"fa": "تنظیمات", "en": "Settings"},
	"rules": {"fa": "قوانین فایت کلاب", "en": "The Rules"},
	"credits": {"fa": "سازندگان", "en": "Credits"},
	"quit": {"fa": "خروج", "en": "Quit"},
	"lang_switch": {"fa": "English", "en": "فارسی"},
	"back": {"fa": "بازگشت", "en": "Back"},
	"music": {"fa": "موسیقی", "en": "Music"},
	"sfx": {"fa": "صداها", "en": "Sound effects"},
	"voice": {"fa": "صداپیشگی", "en": "Voice"},
	"text_speed": {"fa": "سرعت متن", "en": "Text speed"},
	"film_grain": {"fa": "دانه‌ی فیلم و خش", "en": "Film grain"},
	"story_mode": {"fa": "حالت داستانی (مبارزه‌ی آسان)", "en": "Story mode (easier fights)"},
	"fullscreen": {"fa": "تمام‌صفحه", "en": "Fullscreen"},
	"language": {"fa": "زبان", "en": "Language"},
	"reset": {"fa": "پاک کردن پیشرفت", "en": "Erase progress"},
	"reset_confirm": {"fa": "مطمئنید؟ دوباره بزنید", "en": "Sure? Press again"},
	"reset_done": {"fa": "پیشرفت پاک شد", "en": "Progress erased"},
	"log": {"fa": "گذشته", "en": "Log"},
	"auto": {"fa": "خودکار", "en": "Auto"},
	"skip": {"fa": "رد کردن", "en": "Skip"},
	"menu": {"fa": "منو", "en": "Menu"},
	"paused": {"fa": "مکث", "en": "Paused"},
	"resume": {"fa": "ادامه", "en": "Resume"},
	"main_menu": {"fa": "منوی اصلی", "en": "Main menu"},
	"skip_challenge": {"fa": "رد کردن این چالش", "en": "Skip this challenge"},
	"chapter_n": {"fa": "فصل %s", "en": "Chapter %s"},
	"prologue": {"fa": "پیش‌درآمد", "en": "Prologue"},
	"locked": {"fa": "قفل", "en": "Locked"},
	"tap_hint": {"fa": "برای ادامه بزنید", "en": "Tap or press Space"},
	"no_log": {"fa": "هنوز چیزی گفته نشده.", "en": "Nothing has been said yet."},
	"retry": {"fa": "دوباره", "en": "Try again"},
	"continue_story": {"fa": "ادامه‌ی داستان", "en": "Continue the story"},
	"you_lost": {"fa": "از پا افتادی", "en": "You went down"},
	"you_won": {"fa": "بردی", "en": "You won"},
	"ko": {"fa": "ناک‌اوت", "en": "K.O."},
	"tapped_out": {"fa": "تسلیم شد", "en": "Tapped out"},
	"time": {"fa": "زمان", "en": "Time"},
	"fight_help": {
		"fa": "حرکت: A / D   مشت سریع: J   مشت سنگین: K   لگد: I   دفاع: Shift   جاخالی: O   ضربه‌ی خشم: U",
		"en": "Move: A / D   Jab: J   Cross: K   Kick: I   Block: Shift   Dodge: O   Rage: U"},
	"rage": {"fa": "خشم", "en": "Rage"},
	"press_space": {"fa": "Space را بزنید", "en": "Press Space"},
	"hold_space": {"fa": "Space را نگه دارید", "en": "Hold Space"},
	"tap_fast": {"fa": "پشت سر هم بزنید!", "en": "Mash it!"},
	"dont_touch": {"fa": "به هیچ دکمه‌ای دست نزنید", "en": "Don't touch anything"},
	"failed": {"fa": "نشد. دوباره", "en": "Not quite. Again"},
	"success": {"fa": "انجام شد", "en": "Done"},
	"chapter_done": {"fa": "پایان فصل", "en": "End of chapter"},
	"disclaimer": {
		"fa": "این بازی یک کار هواداری و غیرتجاری است و هیچ ارتباطی با سازندگان فیلم یا کتاب ندارد.",
		"en": "A non-commercial fan game. Not affiliated with the makers of the film or the novel."},
	"subtitle": {"fa": "بازی داستانی بر اساس فیلم", "en": "A story game based on the film"},
	"rules_title": {"fa": "قوانین فایت کلاب", "en": "The Rules of Fight Club"},
	"total": {"fa": "جمع", "en": "Total"},
	"done": {"fa": "تمام", "en": "Done"},
	"buy": {"fa": "بخر", "en": "Buy"},
	"cut": {"fa": "قطع کن", "en": "Cut"},
	"go": {"fa": "برو", "en": "Go"},
	"heat": {"fa": "حرارت", "en": "Heat"},
	"stir": {"fa": "هم بزن", "en": "Stir"},
	"pour": {"fa": "بریز", "en": "Pour"},
}

## The eight rules, as Tyler lays them out in the basement.
const RULES := [
	{"fa": "قانون اول فایت کلاب: درباره‌ی فایت کلاب حرف نمی‌زنی.", "en": "The first rule of Fight Club is: you do not talk about Fight Club."},
	{"fa": "قانون دوم فایت کلاب: درباره‌ی فایت کلاب حرف نمی‌زنی!", "en": "The second rule of Fight Club is: you DO NOT talk about Fight Club!"},
	{"fa": "قانون سوم: اگر کسی گفت «بس»، از حال رفت یا دستش را زمین کوبید، مبارزه تمام است.", "en": "Third rule: if someone yells stop, goes limp, or taps out, the fight is over."},
	{"fa": "قانون چهارم: هر مبارزه فقط دو نفر.", "en": "Fourth rule: only two guys to a fight."},
	{"fa": "قانون پنجم: هر بار فقط یک مبارزه.", "en": "Fifth rule: one fight at a time."},
	{"fa": "قانون ششم: نه پیراهن، نه کفش.", "en": "Sixth rule: no shirts, no shoes."},
	{"fa": "قانون هفتم: مبارزه تا هر وقت که لازم باشد ادامه پیدا می‌کند.", "en": "Seventh rule: fights will go on as long as they have to."},
	{"fa": "قانون هشتم: اگر امشب اولین شب تو در فایت کلاب است، باید مبارزه کنی.", "en": "And the eighth rule: if this is your first night at Fight Club, you have to fight."},
]

var font_fa: FontFile
var font_fa_bold: FontFile
var font_fa_black: FontFile
var font_en: FontFile
var theme: Theme

var _bound: Array = []


func _ready() -> void:
	font_fa = load("res://assets/fonts/Vazirmatn-Regular.ttf")
	font_fa_bold = load("res://assets/fonts/Vazirmatn-Bold.ttf")
	font_fa_black = load("res://assets/fonts/Vazirmatn-Black.ttf")
	font_en = load("res://assets/fonts/SpecialElite-Regular.ttf")
	font_en.fallbacks = [font_fa]
	theme = _build_theme()
	Settings.language_changed.connect(_on_language_changed)
	_apply_fonts()


func lang() -> String:
	return Settings.lang


func is_rtl() -> bool:
	return Settings.lang == "fa"


## UI string by key.
func t(key: String) -> String:
	if not S.has(key):
		push_warning("Loc: missing key %s" % key)
		return key
	return S[key][Settings.lang]


## Pick the current language from a {fa, en} pair. Falls back to the other.
func pick(pair: Variant) -> String:
	if pair is String:
		return pair
	if pair is Dictionary:
		var s: String = pair.get(Settings.lang, "")
		if s == "":
			s = pair.get("en" if Settings.lang == "fa" else "fa", "")
		return s
	return str(pair)


func num(n: Variant) -> String:
	var s := str(n)
	if Settings.lang != "fa":
		return s
	var out := ""
	for ch in s:
		var code := ch.unicode_at(0)
		if code >= 48 and code <= 57:
			out += PERSIAN_DIGITS[code - 48]
		else:
			out += ch
	return out


func body_font() -> Font:
	return font_fa if Settings.lang == "fa" else font_en


func bold_font() -> Font:
	return font_fa_bold if Settings.lang == "fa" else font_en


func title_font() -> Font:
	return font_fa_black


func align() -> HorizontalAlignment:
	return HORIZONTAL_ALIGNMENT_RIGHT if is_rtl() else HORIZONTAL_ALIGNMENT_LEFT


## Keep a control's text in sync with the language. `source` is a UI key,
## a {fa, en} pair, or a Callable that returns the text.
func bind(control: Control, source: Variant) -> void:
	_bound.append([weakref(control), source])
	_refresh_one(control, source)


func _refresh_one(control: Control, source: Variant) -> void:
	var text := ""
	if source is Callable:
		text = source.call()
	elif source is String:
		text = t(source)
	else:
		text = pick(source)
	if control is Label or control is Button or control is RichTextLabel:
		control.set("text", text)


func _on_language_changed(_l: String) -> void:
	_apply_fonts()
	var keep: Array = []
	for entry in _bound:
		var c = entry[0].get_ref()
		if c != null and is_instance_valid(c):
			_refresh_one(c, entry[1])
			keep.append(entry)
	_bound = keep


func _apply_fonts() -> void:
	theme.default_font = body_font()
	theme.set_font("font", "Button", bold_font())
	for v in ["Heading", "Name", "HudButton", "BigButton"]:
		theme.set_font("font", v, bold_font())
	for v in ["Line", "Small", "Caption"]:
		theme.set_font("font", v, body_font())
	theme.set_font("font", "Title", title_font())


func _box(bg: Color, border: Color, bw := 2, radius := 3, pad := 14.0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = pad
	sb.content_margin_right = pad
	sb.content_margin_top = pad * 0.5
	sb.content_margin_bottom = pad * 0.5
	return sb


func _build_theme() -> Theme:
	var th := Theme.new()
	th.default_font_size = 24
	var normal := _box(Color(INK, 0.82), Color(PAPER, 0.35))
	var hover := _box(Color(INK_SOFT, 0.92), SOAP)
	var pressed := _box(Color(SOAP_DEEP, 0.9), SOAP)
	var disabled := _box(Color(INK, 0.5), Color(PAPER, 0.12))
	var focus := _box(Color(0, 0, 0, 0), SOAP, 2)
	th.set_stylebox("normal", "Button", normal)
	th.set_stylebox("hover", "Button", hover)
	th.set_stylebox("pressed", "Button", pressed)
	th.set_stylebox("hover_pressed", "Button", pressed)
	th.set_stylebox("disabled", "Button", disabled)
	th.set_stylebox("focus", "Button", focus)
	th.set_color("font_color", "Button", PAPER)
	th.set_color("font_hover_color", "Button", Color.WHITE)
	th.set_color("font_pressed_color", "Button", Color.WHITE)
	th.set_color("font_focus_color", "Button", Color.WHITE)
	th.set_color("font_disabled_color", "Button", Color(PAPER, 0.35))
	th.set_font_size("font_size", "Button", 24)
	th.set_color("font_color", "Label", PAPER)
	th.set_color("default_color", "RichTextLabel", PAPER)
	th.set_stylebox("panel", "Panel", _box(Color(INK, 0.93), Color(PAPER, 0.18), 1, 2))
	th.set_stylebox("panel", "PanelContainer", _box(Color(INK, 0.93), Color(PAPER, 0.18), 1, 2, 22.0))
	# Sliders: a thin rail with a soap-pink grabber.
	var rail := StyleBoxFlat.new()
	rail.bg_color = Color(PAPER, 0.2)
	rail.content_margin_top = 3
	rail.content_margin_bottom = 3
	var fill := StyleBoxFlat.new()
	fill.bg_color = SOAP
	fill.content_margin_top = 3
	fill.content_margin_bottom = 3
	th.set_stylebox("slider", "HSlider", rail)
	th.set_stylebox("grabber_area", "HSlider", fill)
	th.set_stylebox("grabber_area_highlight", "HSlider", fill)
	th.set_icon("grabber", "HSlider", _dot_texture(18, SOAP))
	th.set_icon("grabber_highlight", "HSlider", _dot_texture(20, Color.WHITE))
	th.set_color("font_color", "CheckBox", PAPER)
	th.set_color("font_hover_color", "CheckBox", Color.WHITE)
	th.set_color("font_pressed_color", "CheckBox", PAPER)
	th.set_color("font_hover_pressed_color", "CheckBox", Color.WHITE)
	th.set_stylebox("normal", "CheckBox", _box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0))
	th.set_stylebox("hover", "CheckBox", _box(Color(1, 1, 1, 0.04), Color(0, 0, 0, 0), 0))
	th.set_stylebox("pressed", "CheckBox", _box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0))
	th.set_stylebox("hover_pressed", "CheckBox", _box(Color(1, 1, 1, 0.04), Color(0, 0, 0, 0), 0))
	th.set_stylebox("focus", "CheckBox", _box(Color(0, 0, 0, 0), Color(SOAP, 0.6), 1))
	th.set_icon("checked", "CheckBox", _check_texture(true))
	th.set_icon("unchecked", "CheckBox", _check_texture(false))
	# Type variations used across the UI.
	for v in [["Title", "Label", 72], ["Heading", "Label", 34], ["Name", "Label", 22], ["Line", "Label", 27],
			["Small", "Label", 18], ["Caption", "Label", 20], ["HudButton", "Button", 17], ["BigButton", "Button", 28]]:
		th.set_type_variation(v[0], v[1])
		th.set_font_size("font_size", v[0], v[2])
	var hud_btn := _box(Color(INK, 0.55), Color(PAPER, 0.18), 1, 2, 10.0)
	var hud_hover := _box(Color(INK_SOFT, 0.8), SOAP, 1, 2, 10.0)
	th.set_stylebox("normal", "HudButton", hud_btn)
	th.set_stylebox("hover", "HudButton", hud_hover)
	th.set_stylebox("pressed", "HudButton", _box(Color(SOAP_DEEP, 0.8), SOAP, 1, 2, 10.0))
	th.set_stylebox("focus", "HudButton", _box(Color(0, 0, 0, 0), Color(SOAP, 0.5), 1, 2, 10.0))
	th.set_color("font_color", "Name", SOAP)
	th.set_color("font_color", "Small", PAPER_DIM)
	th.set_color("font_color", "Caption", PAPER)
	th.set_color("font_outline_color", "Line", Color(0, 0, 0, 0.9))
	th.set_constant("outline_size", "Line", 6)
	th.set_color("font_outline_color", "Name", Color(0, 0, 0, 0.9))
	th.set_constant("outline_size", "Name", 5)
	th.set_constant("line_spacing", "Line", 6)
	var vscroll := StyleBoxFlat.new()
	vscroll.bg_color = Color(PAPER, 0.08)
	var vgrab := StyleBoxFlat.new()
	vgrab.bg_color = Color(PAPER, 0.4)
	vgrab.set_corner_radius_all(3)
	th.set_stylebox("scroll", "VScrollBar", vscroll)
	th.set_stylebox("grabber", "VScrollBar", vgrab)
	th.set_stylebox("grabber_highlight", "VScrollBar", vgrab)
	th.set_stylebox("grabber_pressed", "VScrollBar", vgrab)
	return th


func _dot_texture(size: int, color: Color) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var r := size * 0.5
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var a: float = clamp(r - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(color, a))
	return ImageTexture.create_from_image(img)


func _check_texture(on: bool) -> Texture2D:
	var size := 26
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			var edge := x < 2 or y < 2 or x >= size - 2 or y >= size - 2
			var inner := x >= 6 and y >= 6 and x < size - 6 and y < size - 6
			if edge:
				img.set_pixel(x, y, Color(PAPER, 0.7))
			elif on and inner:
				img.set_pixel(x, y, SOAP)
	return ImageTexture.create_from_image(img)
