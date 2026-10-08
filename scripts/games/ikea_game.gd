extends GameModule
## The catalogue. Buy furniture for the condo; every piece appears in the
## room with its name and price floating beside it, the way the film's
## camera pans across the apartment.
##   @game ikea min=4

const ITEMS := [
	{"id": "table", "name": "KLIPSK", "price": 129, "at": Vector2(640, 520),
		"fa": "میز قهوه‌ی کوتاه به شکل یین و یانگ", "en": "Low coffee table in the shape of a yin-yang"},
	{"id": "armchair", "name": "JOHANNESHOV", "price": 279, "at": Vector2(1060, 470),
		"fa": "مبل راحتی با پارچه‌ی راه‌راه سبز", "en": "Armchair in a green stripe pattern"},
	{"id": "lamp", "name": "RISLAMPA", "price": 39, "at": Vector2(300, 300),
		"fa": "چراغ‌های سیمی با کاغذ دوست‌دار محیط زیست", "en": "Wire lamps of environmentally friendly paper"},
	{"id": "clock", "name": "VILD", "price": 49, "at": Vector2(1000, 110),
		"fa": "ساعت دیواری از فولاد گالوانیزه", "en": "Wall clock of galvanized steel"},
	{"id": "sofa", "name": "HAPARANDA", "price": 649, "at": Vector2(280, 470),
		"fa": "کاناپه‌ی سه‌نفره با روکش قابل‌شستشو", "en": "Three-seat sofa with washable slipcovers"},
	{"id": "rug", "name": "SKARPÖ", "price": 99, "at": Vector2(520, 640),
		"fa": "فرش بیضی، به رنگ سبز کم‌رنگ", "en": "Oval rug in a muted green"},
	{"id": "shelf", "name": "ALVBO", "price": 159, "at": Vector2(200, 170),
		"fa": "قفسه‌ی دیواری سفید", "en": "White wall shelves"},
	{"id": "plates", "name": "HANTVERK", "price": 89, "at": Vector2(1180, 300),
		"fa": "ظرف‌های شیشه‌ای دست‌ساز، با حباب‌ها و ناهمواری‌هایی که ثابت می‌کنند دست‌ساز‌ند", "en": "Hand-blown glass dishes, bubbles and flaws proving they're handmade"},
]

var _owned: Array = []
var _total := 0
var _min := 4
var _cards: Dictionary = {}
var _total_label: Label
var _done_btn: Button


func begin() -> void:
	_min = kvi("min", 4)
	_owned = []
	Settings.set_flag("ikea_items", [])
	stage.refresh_location()
	var panel := PanelContainer.new()
	panel.position = Vector2(700 if not Loc.is_rtl() else 40, 40)
	panel.size = Vector2(540, 620)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.95, 0.93, 0.86, 0.96)
	sb.border_color = Color(0.1, 0.25, 0.55)
	sb.set_border_width_all(4)
	sb.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", sb)
	ui.add_child(panel)
	var v := UI.vbox(8)
	panel.add_child(v)
	var head := Label.new()
	head.text = Loc.pick({"fa": "کاتالوگ خانه", "en": "HOME CATALOGUE"})
	head.add_theme_font_override("font", Loc.font_fa_black)
	head.add_theme_font_size_override("font_size", 30)
	head.add_theme_color_override("font_color", Color(0.1, 0.25, 0.55))
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(head)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	for item in ITEMS:
		grid.add_child(_card(item))
	var foot := UI.hbox(10)
	v.add_child(foot)
	_total_label = Label.new()
	_total_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.1))
	_total_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_total_label)
	_done_btn = UI.button("done", func(): _finish())
	_done_btn.disabled = true
	foot.add_child(_done_btn)
	_update_total()


func autoplay() -> void:
	for item in ITEMS:
		_buy(item)
	await get_tree().process_frame
	_finish()


func _card(item: Dictionary) -> Control:
	var box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.85)
	sb.border_color = Color(0.8, 0.78, 0.7)
	sb.set_border_width_all(1)
	sb.set_content_margin_all(8)
	box.add_theme_stylebox_override("panel", sb)
	box.custom_minimum_size = Vector2(250, 118)
	var v := UI.vbox(2)
	box.add_child(v)
	var name_l := Label.new()
	name_l.text = item["name"]
	name_l.add_theme_font_override("font", Loc.font_fa_black)
	name_l.add_theme_font_size_override("font_size", 20)
	name_l.add_theme_color_override("font_color", Color(0.1, 0.1, 0.12))
	v.add_child(name_l)
	var desc := Label.new()
	desc.text = Loc.pick(item)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(230, 0)
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color(0.25, 0.22, 0.2))
	desc.text_direction = Control.TEXT_DIRECTION_RTL if Loc.is_rtl() else Control.TEXT_DIRECTION_LTR
	v.add_child(desc)
	var row := UI.hbox(6)
	v.add_child(row)
	var price := Label.new()
	price.text = "$%d" % item["price"]
	price.add_theme_font_override("font", Loc.font_fa_black)
	price.add_theme_font_size_override("font_size", 22)
	price.add_theme_color_override("font_color", Color(0.75, 0.1, 0.1))
	price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(price)
	var b := UI.button("buy", func(): _buy(item), "HudButton")
	row.add_child(b)
	_cards[item["id"]] = b
	return box


func _buy(item: Dictionary) -> void:
	var id: String = item["id"]
	if id in _owned:
		return
	_owned.append(id)
	_total += int(item["price"])
	Settings.set_flag("ikea_items", _owned.duplicate())
	stage.refresh_location()
	Sound.sfx("cash_register", -6.0)
	if _cards.has(id):
		var b: Button = _cards[id]
		b.disabled = true
		b.text = "✓"
	_float_tag(item)
	_update_total()


func _float_tag(item: Dictionary) -> void:
	var l := Label.new()
	l.text = "%s\n$%d" % [item["name"], item["price"]]
	l.add_theme_font_override("font", Loc.font_fa_black)
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color(1, 1, 1))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 6)
	l.position = item["at"] - Vector2(60, 40)
	l.modulate.a = 0.0
	ui.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.5)
	tw.parallel().tween_property(l, "position:y", l.position.y - 16.0, 1.2)


func _update_total() -> void:
	_total_label.text = "%s: $%d" % [Loc.t("total"), _total]
	_done_btn.disabled = _owned.size() < _min


func _finish() -> void:
	Settings.set_flag("ikea_total", _total)
	finish("win")
