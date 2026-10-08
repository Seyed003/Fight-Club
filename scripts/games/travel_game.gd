extends GameModule
## Following Tyler's receipts across the country. Pick each city from the
## ticket stubs; in every one there's a bar with a basement, and people
## who seem to know you.

const OUTLINE := [Vector2(150, 130), Vector2(380, 132), Vector2(620, 138), Vector2(700, 190), Vector2(760, 168),
	Vector2(820, 200), Vector2(900, 170), Vector2(980, 140), Vector2(1040, 118), Vector2(1084, 168), Vector2(1030, 236),
	Vector2(1004, 320), Vector2(966, 396), Vector2(934, 466), Vector2(958, 556), Vector2(930, 604), Vector2(892, 528),
	Vector2(800, 500), Vector2(700, 518), Vector2(620, 540), Vector2(566, 604), Vector2(500, 546), Vector2(430, 500),
	Vector2(330, 482), Vector2(220, 452), Vector2(160, 380), Vector2(128, 280)]

const CITIES := [
	{"id": "chicago", "pos": Vector2(760, 236), "fa": "شیکاگو", "en": "Chicago",
		"line_fa": "یک بار. یک زیرزمین. یک فایت کلاب. مردی با لب پاره سرش را برایم تکان داد، انگار سال‌هاست مرا می‌شناسد.",
		"line_en": "A bar. A basement. A fight club. A man with a split lip nodded at me like he'd known me for years."},
	{"id": "detroit", "pos": Vector2(826, 214), "fa": "دیترویت", "en": "Detroit",
		"line_fa": "این‌جا هم بود. کسی حرفش را نمی‌زد، ولی همه کبود بودند.", "line_en": "Here too. Nobody talked about it, but everyone was bruised."},
	{"id": "philadelphia", "pos": Vector2(986, 254), "fa": "فیلادلفیا", "en": "Philadelphia",
		"line_fa": "مسئول بار نوشیدنی‌ام را حساب نکرد. گفت: «برای شما مجانی است.»", "line_en": "The bartender wouldn't take my money. \"It's on the house,\" he said."},
	{"id": "seattle", "pos": Vector2(176, 150), "fa": "سیاتل", "en": "Seattle",
		"line_fa": "روی دیوار دستشویی کسی نوشته بود: «پروژه‌ی میهم». خط آشنا بود.", "line_en": "Someone had written PROJECT MAYHEM on the bathroom wall. The handwriting looked familiar."},
	{"id": "dallas", "pos": Vector2(560, 474), "fa": "دالاس", "en": "Dallas",
		"line_fa": "سرهای تراشیده، لباس‌های مشکی. حتی این‌جا.", "line_en": "Shaved heads, black shirts. Even here."},
	{"id": "newyork", "pos": Vector2(1006, 222), "fa": "نیویورک", "en": "New York",
		"line_fa": "هر شهری که می‌رفتم، تایلر تازه رفته بود.", "line_en": "Every city I went to, Tyler had just left."},
]

var _visited: Array = []
var _at := Vector2(176, 150)
var _flying := false
var _fly_from := Vector2.ZERO
var _fly_to := Vector2.ZERO
var _fly_t := 0.0
var _w: Control
var _line: Label
var _buttons: Dictionary = {}
var _t := 0.0


func begin() -> void:
	_at = Vector2(kvf("x", 230.0), kvf("y", 300.0))
	_w = Control.new()
	UI.full(_w)
	_w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_w.draw.connect(_draw_map)
	ui.add_child(_w)
	hint_label(Loc.pick({"fa": "رسیدهای تایلر: یکی‌یکی به این شهرها برو.", "en": "Tyler's receipts: visit each of these cities."}), 20.0, 24)
	_line = hint_label("", 620.0, 22)
	_line.add_theme_color_override("font_color", Loc.PAPER)
	var list := UI.vbox(6)
	list.position = Vector2(1110, 250)
	ui.add_child(list)
	for c in CITIES:
		var city: Dictionary = c
		var b := UI.button(city, func(): _go(city), "HudButton")
		b.custom_minimum_size = Vector2(150, 34)
		list.add_child(b)
		_buttons[city["id"]] = b


func autoplay() -> void:
	for i in 10:
		await get_tree().process_frame
	finish("win")


func _go(city: Dictionary) -> void:
	if _flying or city["id"] in _visited:
		return
	_flying = true
	_fly_from = _at
	_fly_to = city["pos"]
	_fly_t = 0.0
	Sound.sfx("plane_pass", -6.0)
	_line.text = ""
	var tw := create_tween()
	tw.tween_property(self, "_fly_t", 1.0, 1.4).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): _land(city))


func _land(city: Dictionary) -> void:
	_flying = false
	_at = city["pos"]
	_visited.append(city["id"])
	(_buttons[city["id"]] as Button).disabled = true
	_line.text = Loc.pick({"fa": city["fa"] + ": " + city["line_fa"], "en": city["en"] + ": " + city["line_en"]})
	Sound.sfx("bar_door", -6.0)
	if _visited.size() >= CITIES.size():
		var tw := create_tween()
		tw.tween_interval(3.5)
		tw.tween_callback(func(): finish("win"))


func _process(delta: float) -> void:
	_t += delta
	_w.queue_redraw()


func _draw_map() -> void:
	var c := _w
	c.draw_rect(Rect2(0, 0, 1280, 720), Color(0.06, 0.07, 0.08, 0.92))
	var pts := PackedVector2Array()
	for p in OUTLINE:
		pts.append(p)
	c.draw_colored_polygon(pts, Color(0.32, 0.3, 0.24))
	pts.append(OUTLINE[0])
	c.draw_polyline(pts, Color(0.62, 0.58, 0.46), 3.0, true)
	for i in 30:
		var y := 120.0 + i * 17.0
		c.draw_line(Vector2(100, y), Vector2(1180, y), Color(1, 1, 1, 0.02), 1.0)
	for city in CITIES:
		var p: Vector2 = city["pos"]
		var seen: bool = city["id"] in _visited
		c.draw_circle(p, 9 if seen else 7, Color(0.85, 0.12, 0.1) if seen else Color(0.95, 0.9, 0.8))
		if seen:
			c.draw_arc(p, 14 + sin(_t * 4.0) * 2.0, 0, TAU, 20, Color(0.85, 0.12, 0.1, 0.6), 2.0)
		Paint.text(c, p + Vector2(12, -10), Loc.pick(city), 18, Color(0.95, 0.92, 0.85), Loc.body_font())
	if _flying:
		var head := _fly_from.lerp(_fly_to, _fly_t)
		var mid := (_fly_from + _fly_to) * 0.5 - Vector2(0, 80)
		var arc := PackedVector2Array()
		for k in 20:
			var tt := k / 19.0 * _fly_t
			arc.append(_fly_from.lerp(mid, tt).lerp(mid.lerp(_fly_to, tt), tt))
		if arc.size() > 1:
			c.draw_polyline(arc, Color(1, 1, 1, 0.7), 2.0, true)
		head = arc[arc.size() - 1]
		c.draw_circle(head, 6, Color.WHITE)
	else:
		c.draw_circle(_at, 5, Color.WHITE)
