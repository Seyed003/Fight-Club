class_name Puppet
extends Node2D
## A character drawn entirely in code: a side-view skeleton (legs solved
## with two-bone IK so feet stay planted), clothing, hair, face, bruises,
## blood and a held prop. Origin is between the feet; +x is forward and
## `facing` mirrors it.

const THIGH := 76.0
const SHIN := 74.0
const TORSO := 104.0
const NECK := 9.0
const UPPER_ARM := 60.0
const FOREARM := 56.0
const OUTLINE := Color(0.025, 0.025, 0.03, 0.92)
const HEAD_SCALE := 1.18

var look: Dictionary = {}
var who := ""
var facing := 1:
	set(v):
		facing = 1 if v >= 0 else -1
		queue_redraw()
var pose: Dictionary = Poses.get_pose("stand")
var target: Dictionary = Poses.get_pose("stand")
var target_name := "stand"
var blend := 9.0
## Procedural motion layered on the pose: "", walk, run, cry, laugh,
## shiver, sob, bounce, sway, talk_hands.
var anim := ""
## Face: "", smirk, angry, sad, shock, pain, laugh, blank, closed.
var expr := ""
var talking := false
var bruise := 0.0
var blood := 0.0
var prop := ""
var alpha := 1.0:
	set(v):
		alpha = clamp(v, 0.0, 1.0)
		queue_redraw()
## When its alpha is above zero the puppet is drawn as a flat silhouette.
var silhouette := Color(0, 0, 0, 0)
var walk_speed := 1.0
var breathing := true
var show_shadow := true

var _t := 0.0
var _blink := 3.0
var _phase := 0.0
var _h := 1.0
var _w := 1.0
var _chest := 0.0
var _belly := 0.0
var _muscle := 0.0
var _female := 0.0
var _joints: Dictionary = {}
var _xf := Transform2D.IDENTITY
var _splatter: PackedVector2Array = PackedVector2Array()


func _init() -> void:
	_t = randf() * 10.0
	_blink = randf_range(1.0, 4.0)


func set_look(id: String) -> void:
	look = Cast.look(id)
	who = look.get("who", id)
	var b: Dictionary = look.get("build", {})
	_h = b.get("h", 1.0)
	_w = b.get("w", 1.0)
	_chest = b.get("chest", 0.0)
	_belly = b.get("belly", 0.0)
	_muscle = b.get("muscle", 0.0)
	_female = b.get("female", 0.0)
	if look.has("prop") and prop == "":
		prop = look["prop"]
	bruise = max(bruise, look.get("bruise", 0.0))
	blood = max(blood, look.get("blood", 0.0))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	_splatter.clear()
	for i in 14:
		_splatter.append(Vector2(rng.randf_range(-10, 16), rng.randf_range(0.45, 0.95)))
	queue_redraw()


func set_pose(pose_name: String, speed := 9.0) -> void:
	target = Poses.get_pose(pose_name)
	target_name = pose_name
	blend = speed


func snap_pose(pose_name: String) -> void:
	target = Poses.get_pose(pose_name)
	target_name = pose_name
	pose = target.duplicate()
	queue_redraw()


## Body girth multiplier from the look's build.
func girth() -> float:
	return _w


## Height of the head top above the feet, in local pixels.
func height() -> float:
	return (THIGH + SHIN + TORSO + NECK + 40.0) * _h


func _process(delta: float) -> void:
	_t += delta
	var k := 1.0 - exp(-blend * delta)
	for key in target:
		pose[key] = lerp(float(pose.get(key, 0.0)), float(target[key]), k)
	if anim == "walk":
		_phase += delta * 7.5 * walk_speed
	elif anim == "run":
		_phase += delta * 12.0 * walk_speed
	_blink -= delta
	if _blink < -0.13:
		_blink = randf_range(2.0, 5.5)
	queue_redraw()


func _effective() -> Dictionary:
	var p := pose.duplicate()
	if breathing:
		var b := sin(_t * 1.7)
		p["t"] += b * 0.01
		p["uaf"] += b * 0.015
		p["uab"] -= b * 0.012
	match anim:
		"walk", "run":
			var run := anim == "run"
			var stride := 34.0 if run else 22.0
			var s := sin(_phase)
			var c := cos(_phase)
			p["ff"] = stride * s + 4.0
			p["fb"] = -stride * s - 4.0
			p["ffy"] = max(0.0, c) * (22.0 if run else 13.0)
			p["fby"] = max(0.0, -c) * (22.0 if run else 13.0)
			p["hy"] = 4.0 + abs(s) * 4.0
			if prop not in ["gun", "briefcase"] or target_name in ["walk", "run"]:
				p["uaf"] = -0.38 * s * (1.4 if run else 1.0)
				p["uab"] = 0.38 * s * (1.4 if run else 1.0)
				p["faf"] = 1.3 if run else 0.25
				p["fab"] = 1.3 if run else 0.25
			p["t"] += 0.22 if run else 0.04
		"cry", "sob":
			p["t"] += sin(_t * 13.0) * 0.025
			p["h"] += sin(_t * 13.0) * 0.04
		"laugh":
			p["h"] += -0.28 + sin(_t * 13.0) * 0.07
			p["t"] += -0.06 + sin(_t * 13.0) * 0.02
		"shiver":
			p["t"] += randf_range(-0.015, 0.015)
			p["hx"] += randf_range(-1.0, 1.0)
		"bounce":
			p["hy"] += 4.0 + sin(_t * 7.0) * 3.5
		"sway":
			p["rot"] += sin(_t * 1.3) * 0.05
		"talk_hands":
			p["uaf"] += sin(_t * 3.1) * 0.25
			p["faf"] += sin(_t * 2.3) * 0.3
	return p


func _talk_open() -> bool:
	return talking and fmod(_t * 8.5, 1.0) < 0.55


func _col(c: Color) -> Color:
	if silhouette.a > 0.0:
		return Color(silhouette.r, silhouette.g, silhouette.b, silhouette.a * alpha)
	return Color(c.r, c.g, c.b, c.a * alpha)


func _ik(root: Vector2, tgt: Vector2, l1: float, l2: float) -> Vector2:
	var d := tgt - root
	var dist := d.length()
	var max_d := (l1 + l2) * 0.999
	if dist > max_d:
		d = d.normalized() * max_d
		dist = max_d
	dist = max(dist, 0.001)
	var cos_a: float = clamp((l1 * l1 + dist * dist - l2 * l2) / (2.0 * l1 * dist), -1.0, 1.0)
	var a := acos(cos_a)
	var base := d.angle()
	return root + Vector2.from_angle(base - a) * l1


static func _dir(a: float) -> Vector2:
	return Vector2(sin(a), cos(a))


static func _capsule(a: Vector2, b: Vector2, ra: float, rb: float) -> PackedVector2Array:
	var d := b - a
	if d.length() < 0.01:
		d = Vector2(0, 0.01)
	var ang := d.angle()
	var pts := PackedVector2Array()
	for i in 7:
		var t := ang - PI * 0.5 + PI * i / 6.0
		pts.append(b + Vector2(cos(t), sin(t)) * rb)
	for i in 7:
		var t := ang + PI * 0.5 + PI * i / 6.0
		pts.append(a + Vector2(cos(t), sin(t)) * ra)
	return pts


func _limb(a: Vector2, b: Vector2, ra: float, rb: float, c: Color, back := false) -> void:
	var base := c.darkened(0.24) if back else c
	if silhouette.a <= 0.0:
		draw_colored_polygon(_capsule(a, b, ra + 1.7, rb + 1.7), _col(OUTLINE))
	draw_colored_polygon(_capsule(a, b, ra, rb), _col(base.darkened(0.3)))
	var off := Vector2(ra * 0.2, -ra * 0.16)
	draw_colored_polygon(_capsule(a + off, b + off, ra * 0.7, rb * 0.7), _col(base))


func _poly(pts: PackedVector2Array, c: Color, outline := true) -> void:
	if pts.size() < 3:
		return
	draw_colored_polygon(pts, _col(c))
	if outline and silhouette.a <= 0.0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, _col(OUTLINE), 2.2, true)


func _ellipse(center: Vector2, rx: float, ry: float, c: Color, ang := 0.0, segs := 16) -> void:
	var pts := PackedVector2Array()
	for i in segs:
		var t := TAU * i / segs
		pts.append(center + Vector2(cos(t) * rx, sin(t) * ry).rotated(ang))
	draw_colored_polygon(pts, _col(c))


func _draw() -> void:
	if look.is_empty() or alpha <= 0.0:
		return
	var p := _effective()
	var rot := float(p["rot"])
	var lift := -sin(absf(rot)) * 16.0
	if show_shadow:
		var sw := 34.0 * _w * _h + absf(sin(rot)) * 120.0 * _h
		var sx := float(p["hx"]) * facing + sin(rot) * 140.0 * _h * facing
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_ellipse(Vector2(sx * 0.5, 2), sw, 6.0, Color(0, 0, 0, 0.32))
	_xf = Transform2D(0.0, Vector2(facing, 1), 0.0, Vector2(0, lift)) * Transform2D(rot, Vector2.ZERO)
	draw_set_transform_matrix(_xf)

	var thigh := THIGH * _h
	var shin := SHIN * _h
	var torso := TORSO * _h
	var ua := UPPER_ARM * _h
	var fa := FOREARM * _h
	var w := _w
	var hip := Vector2(float(p["hx"]), -(thigh + shin) + float(p["hy"]))
	var foot_f := Vector2(float(p["ff"]), -float(p["ffy"]))
	var foot_b := Vector2(float(p["fb"]), -float(p["fby"]))
	var hip_b := hip + Vector2(-4 * w, 0)
	var knee_f := _ik(hip, foot_f, thigh, shin)
	var knee_b := _ik(hip_b, foot_b, thigh, shin)
	if knee_f.distance_to(foot_f) > shin * 1.01:
		foot_f = knee_f + (foot_f - knee_f).normalized() * shin
	if knee_b.distance_to(foot_b) > shin * 1.01:
		foot_b = knee_b + (foot_b - knee_b).normalized() * shin
	var tl := float(p["t"])
	var up := Vector2(sin(tl), -cos(tl))
	var fw := Vector2(cos(tl), sin(tl))
	var chest_top := hip + up * torso
	var ha := tl + float(p["h"])
	var hf := Vector2(cos(ha), sin(ha))
	var hd := Vector2(-sin(ha), cos(ha))
	var head_c := chest_top + up * (NECK * _h) - hd * (18.0 * _h * HEAD_SCALE)
	var sh_f := chest_top - up * 9.0 + fw * 2.0 * w
	var sh_b := chest_top - up * 9.0 - fw * 8.0 * w
	var a_f := float(p["uaf"]) + tl
	var a_b := float(p["uab"]) + tl
	var elbow_f := sh_f + _dir(a_f) * ua
	var hand_f := elbow_f + _dir(a_f + float(p["faf"])) * fa
	var elbow_b := sh_b + _dir(a_b) * ua
	var hand_b := elbow_b + _dir(a_b + float(p["fab"])) * fa
	_joints = {"hip": hip, "chest": chest_top - up * 30.0, "head": head_c, "hand_f": hand_f, "hand_b": hand_b,
		"foot_f": foot_f, "foot_b": foot_b, "elbow_f": elbow_f, "knee_f": knee_f}

	var skin: Color = look.get("skin", Color(0.85, 0.7, 0.6))
	var top: String = look.get("top", "shirt")
	var top_c: Color = look.get("top_color", Color(0.8, 0.8, 0.8))
	var top_c2: Color = look.get("top_color2", top_c)
	var sleeves: String = look.get("sleeves", "long")
	var pants: Color = look.get("pants_color", Color(0.25, 0.25, 0.27))
	var shoes: Color = look.get("shoes_color", Color(0.06, 0.06, 0.06))
	var barefoot: bool = look.get("barefoot", false)
	var legwear: String = look.get("legwear", "pants")
	var long_top := top in ["overcoat", "robe", "labcoat", "fur"]
	var arm_c := top_c
	if top in ["vest", "apron"]:
		arm_c = top_c2
	var mus := _muscle

	# Back arm and leg sit behind the torso.
	var aw := lerpf(1.0, w, 0.55)
	var lw := lerpf(1.0, w, 0.75)
	_draw_arm(sh_b, elbow_b, hand_b, a_b + float(p["fab"]), arm_c, skin, sleeves, aw, mus, true)
	_draw_leg(hip_b, knee_b, foot_b, pants, shoes, skin, barefoot, legwear, lw, true)
	if long_top:
		_draw_coat_tail(hip, up, fw, knee_f, knee_b, top, top_c, w)
	_draw_torso(hip, up, fw, torso, top, top_c, top_c2, skin, w)
	_draw_leg(hip, knee_f, foot_f, pants, shoes, skin, barefoot, legwear, lw, false)
	if legwear == "dress":
		_draw_skirt(hip, up, fw, knee_f, knee_b, top, top_c, pants, w)
	if long_top:
		_draw_coat_front(hip, up, fw, knee_f, top, top_c, w)
	# Neck and head.
	var neck_top := head_c + hd * 13.0 * _h * HEAD_SCALE - hf * 2.0
	_limb(chest_top - up * 6.0, neck_top, 8.6 * w, 7.4 * w, skin)
	_draw_collar(chest_top, up, fw, top, top_c, top_c2, w)
	_draw_head(head_c, hf, hd, skin)
	_draw_arm(sh_f, elbow_f, hand_f, a_f + float(p["faf"]), arm_c, skin, sleeves, aw, mus, false)
	_draw_prop(hand_f, a_f + float(p["faf"]), head_c)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_arm(sh: Vector2, el: Vector2, hand: Vector2, fore_ang: float, sleeve_c: Color, skin: Color,
		sleeves: String, w: float, mus: float, back: bool) -> void:
	var r_up := (9.2 + mus * 2.6) * w
	var r_el := (7.2 + mus * 1.5) * w
	var r_wr := 5.4 * w
	var upper_c := skin if sleeves == "none" else sleeve_c
	var fore_c := sleeve_c if sleeves == "long" else skin
	if sleeves == "short":
		var mid := sh.lerp(el, 0.55)
		_limb(mid, el, r_el + 0.6, r_el, skin, back)
		_limb(sh, mid, r_up + 1.4, r_el + 1.6, sleeve_c, back)
	else:
		_limb(sh, el, r_up, r_el, upper_c, back)
	var cuff := el.lerp(hand, 0.86)
	_limb(el, cuff if sleeves == "long" else hand, r_el, r_wr, fore_c, back)
	var hc := hand + _dir(fore_ang) * 3.0
	var hand_col := skin.darkened(0.24) if back else skin
	if silhouette.a <= 0.0:
		_ellipse(hc, 8.6 * w, 8.6 * w, OUTLINE)
	_ellipse(hc, 7.0 * w, 7.0 * w, hand_col)


func _draw_leg(hip: Vector2, knee: Vector2, foot: Vector2, pants: Color, shoes: Color, skin: Color,
		barefoot: bool, legwear: String, w: float, back: bool) -> void:
	var leg_c := pants
	_limb(hip, knee, 15.5 * w, 11.0 * w, leg_c, back)
	_limb(knee, foot - Vector2(0, 4), 10.5 * w, 7.0 * w, leg_c, back)
	var heel := foot + Vector2(-5, -2)
	var toe := foot + Vector2(17 * _h, 0)
	if barefoot:
		_limb(heel, toe, 5.2, 4.2, skin, back)
	else:
		_limb(heel + Vector2(-1, -1), toe + Vector2(2, 0), 6.0, 5.0, shoes, back)


func _torso_pt(hip: Vector2, up: Vector2, fw: Vector2, torso: float, x: float, s: float) -> Vector2:
	return hip + fw * x + up * (s * torso)


func _torso_shape(hip: Vector2, up: Vector2, fw: Vector2, torso: float, w: float) -> PackedVector2Array:
	var c := _chest
	var b := _belly
	var f := _female
	var back := [[1.03, -12.0], [0.98, -18.0], [0.88, -20.5], [0.74, -20.0], [0.58, -18.0], [0.42, -16.5],
		[0.22, -18.0], [0.04, -20.0], [-0.07, -14.0]]
	var front := [[-0.07, 8.0], [0.04, 18.0 + b * 7.0], [0.2, 16.5 + b * 14.0], [0.4, 16.0 + b * 20.0],
		[0.56, 17.0 + b * 12.0 + c * 7.0], [0.72, 20.0 + c * 14.0 + f * 9.0], [0.86, 18.5 + c * 6.0 + f * 4.0],
		[0.97, 12.0], [1.04, 4.0]]
	var pts := PackedVector2Array()
	for e in back:
		pts.append(_torso_pt(hip, up, fw, torso, e[1] * w, e[0]))
	for e in front:
		pts.append(_torso_pt(hip, up, fw, torso, e[1] * w, e[0]))
	return pts


func _draw_torso(hip: Vector2, up: Vector2, fw: Vector2, torso: float, top: String, c1: Color, c2: Color,
		skin: Color, w: float) -> void:
	var shape := _torso_shape(hip, up, fw, torso, w)
	var bare := top == "none"
	var fill := skin if bare else c1
	if top == "tank":
		_poly(shape, skin)
		var tank := PackedVector2Array()
		for i in shape.size():
			var pt := shape[i]
			var s := (pt - hip).dot(up) / torso
			if s <= 0.84:
				tank.append(pt)
		tank.append(_torso_pt(hip, up, fw, torso, 10.0 * w, 0.86))
		tank.append(_torso_pt(hip, up, fw, torso, -11.0 * w, 0.9))
		_poly(_sorted_loop(tank, hip, up, fw), c1, false)
	else:
		_poly(shape, fill)
	if silhouette.a > 0.0:
		return
	# Shade along the back for volume.
	var shade := PackedVector2Array()
	for e in [[0.0, -15.0], [0.4, -13.5], [0.72, -15.5], [0.96, -13.0], [0.96, -6.0], [0.72, -8.0], [0.4, -7.0], [0.0, -8.0]]:
		shade.append(_torso_pt(hip, up, fw, torso, e[1] * w, e[0]))
	draw_colored_polygon(shade, _col(Color(0, 0, 0, 0.2)))
	match top:
		"none":
			var pec_y := 0.7
			var a := _torso_pt(hip, up, fw, torso, 3.0 * w, pec_y)
			var b := _torso_pt(hip, up, fw, torso, (14.0 + _chest * 10.0) * w, pec_y - 0.03)
			draw_line(a, b, _col(skin.darkened(0.3)), 1.6, true)
			if _muscle > 0.4:
				for s in [0.5, 0.38, 0.26]:
					draw_line(_torso_pt(hip, up, fw, torso, 8.0 * w, s), _torso_pt(hip, up, fw, torso, (12.0 + _belly * 10.0) * w, s), _col(skin.darkened(0.22)), 1.2, true)
			_ellipse(_torso_pt(hip, up, fw, torso, (11.5 + _belly * 14.0) * w, 0.2), 1.4, 2.0, skin.darkened(0.45))
			_draw_waistband(hip, up, fw, torso, w)
		"shirt", "blouse", "uniform":
			var pl := PackedVector2Array([_torso_pt(hip, up, fw, torso, 10.0 * w, 0.96), _torso_pt(hip, up, fw, torso, (11.0 + _belly * 12.0) * w, 0.35), _torso_pt(hip, up, fw, torso, 12.0 * w, 0.06)])
			draw_polyline(pl, _col(c1.darkened(0.18)), 1.4, true)
			for s in [0.8, 0.6, 0.4, 0.2]:
				_ellipse(_torso_pt(hip, up, fw, torso, (11.5 + _belly * 10.0 * (1.0 - s)) * w, s), 1.3, 1.3, c1.darkened(0.3))
			if top == "uniform":
				_ellipse(_torso_pt(hip, up, fw, torso, 6.0 * w, 0.74), 3.2, 3.8, Color(0.82, 0.68, 0.28))
				_draw_belt(hip, up, fw, torso, w, Color(0.06, 0.06, 0.06))
			else:
				_draw_belt(hip, up, fw, torso, w, Color(0.1, 0.08, 0.07))
		"tshirt", "tank":
			_draw_belt(hip, up, fw, torso, w, Color(0.1, 0.08, 0.07))
		"sweater", "cardigan":
			var hem := PackedVector2Array([_torso_pt(hip, up, fw, torso, -15.5 * w, 0.0), _torso_pt(hip, up, fw, torso, -15.0 * w, 0.1),
				_torso_pt(hip, up, fw, torso, (13.5 + _belly * 9.0) * w, 0.12), _torso_pt(hip, up, fw, torso, (14.0 + _belly * 6.0) * w, 0.0)])
			draw_colored_polygon(hem, _col(c1.darkened(0.2)))
			for s in [0.3, 0.5, 0.7]:
				draw_line(_torso_pt(hip, up, fw, torso, -10.0 * w, s), _torso_pt(hip, up, fw, torso, 8.0 * w, s + 0.02), _col(c1.darkened(0.12)), 1.0, true)
		"jacket", "suit", "waiter", "vest":
			var inner := PackedVector2Array([_torso_pt(hip, up, fw, torso, 6.0 * w, 0.97), _torso_pt(hip, up, fw, torso, 12.0 * w, 0.95),
				_torso_pt(hip, up, fw, torso, (14.0 + _chest * 10.0) * w, 0.72), _torso_pt(hip, up, fw, torso, (12.0 + _belly * 14.0) * w, 0.4),
				_torso_pt(hip, up, fw, torso, (11.0 + _belly * 8.0) * w, 0.36), _torso_pt(hip, up, fw, torso, 7.0 * w, 0.72)])
			draw_colored_polygon(inner, _col(c2))
			if top == "jacket":
				draw_line(_torso_pt(hip, up, fw, torso, -6.0 * w, 0.9), _torso_pt(hip, up, fw, torso, -4.0 * w, 0.2), _col(c1.lightened(0.25)), 2.5, true)
			if top == "suit":
				_ellipse(_torso_pt(hip, up, fw, torso, 12.0 * w, 0.3), 1.5, 1.5, c1.darkened(0.4))
				_ellipse(_torso_pt(hip, up, fw, torso, (12.0 + _belly * 10.0) * w, 0.18), 1.5, 1.5, c1.darkened(0.4))
			if top == "vest":
				_draw_belt(hip, up, fw, torso, w, Color(0.08, 0.07, 0.07))
		"apron":
			var ap := PackedVector2Array([_torso_pt(hip, up, fw, torso, 2.0 * w, 0.82), _torso_pt(hip, up, fw, torso, (15.0 + _chest * 8.0) * w, 0.74),
				_torso_pt(hip, up, fw, torso, (14.0 + _belly * 12.0) * w, 0.3), _torso_pt(hip, up, fw, torso, 15.0 * w, -0.1), _torso_pt(hip, up, fw, torso, 0.0, -0.1)])
			draw_colored_polygon(ap, _col(c1))
			draw_line(_torso_pt(hip, up, fw, torso, 2.0 * w, 0.82), _torso_pt(hip, up, fw, torso, -12.0 * w, 0.96), _col(c1.darkened(0.2)), 2.0, true)
		"dress":
			pass
	if blood > 0.45:
		for i in int(_splatter.size() * (blood - 0.35)):
			var sp := _splatter[i]
			_ellipse(_torso_pt(hip, up, fw, torso, sp.x * w, sp.y), 1.6 + fmod(i * 1.7, 2.0), 1.4 + fmod(i * 1.3, 2.4), Color(0.45, 0.03, 0.03, 0.85))


func _sorted_loop(pts: PackedVector2Array, hip: Vector2, up: Vector2, fw: Vector2) -> PackedVector2Array:
	var center := Vector2.ZERO
	for pt in pts:
		center += pt
	center /= max(1, pts.size())
	var arr: Array = Array(pts)
	arr.sort_custom(func(a, b): return (a - center).angle() < (b - center).angle())
	return PackedVector2Array(arr)


func _draw_belt(hip: Vector2, up: Vector2, fw: Vector2, torso: float, w: float, c: Color) -> void:
	var belt := PackedVector2Array([_torso_pt(hip, up, fw, torso, -15.6 * w, 0.02), _torso_pt(hip, up, fw, torso, -15.4 * w, 0.09),
		_torso_pt(hip, up, fw, torso, (13.4 + _belly * 8.0) * w, 0.09), _torso_pt(hip, up, fw, torso, (14.2 + _belly * 6.0) * w, 0.02)])
	draw_colored_polygon(belt, _col(c))


func _draw_waistband(hip: Vector2, up: Vector2, fw: Vector2, torso: float, w: float) -> void:
	var pants: Color = look.get("pants_color", Color(0.25, 0.25, 0.27))
	var band := PackedVector2Array([_torso_pt(hip, up, fw, torso, -15.8 * w, -0.06), _torso_pt(hip, up, fw, torso, -15.6 * w, 0.06),
		_torso_pt(hip, up, fw, torso, (13.6 + _belly * 8.0) * w, 0.06), _torso_pt(hip, up, fw, torso, (14.4 + _belly * 6.0) * w, -0.06)])
	draw_colored_polygon(band, _col(pants))


func _draw_collar(chest_top: Vector2, up: Vector2, fw: Vector2, top: String, c1: Color, c2: Color, w: float) -> void:
	if silhouette.a > 0.0:
		return
	var tie: Variant = look.get("tie", null)
	match top:
		"shirt", "blouse", "uniform", "suit", "waiter", "labcoat", "vest":
			var cc := c1 if top in ["shirt", "blouse", "uniform"] else c2
			var col_pts := PackedVector2Array([chest_top + fw * 2.0 * w - up * 2.0, chest_top + fw * 10.0 * w + up * 2.0,
				chest_top + fw * 11.0 * w - up * 10.0, chest_top + fw * 4.0 * w - up * 6.0])
			draw_colored_polygon(col_pts, _col(cc.lightened(0.05)))
			draw_polyline(PackedVector2Array([col_pts[0], col_pts[1], col_pts[2]]), _col(OUTLINE), 1.4, true)
			if tie != null:
				var tc: Color = tie
				if top == "waiter":
					_ellipse(chest_top + fw * 11.0 * w - up * 4.0, 2.4, 4.2, tc, 0.0, 8)
				else:
					var knot := chest_top + fw * 11.5 * w - up * 5.0
					var tip := knot - up * (TORSO * _h * 0.5) + fw * (2.5 + _belly * 9.0) * w
					draw_colored_polygon(PackedVector2Array([knot, knot + fw * 4.0, tip + fw * 3.0, tip]), _col(tc))
		"jacket":
			var lapel := PackedVector2Array([chest_top + fw * 0.0 * w, chest_top + fw * 9.0 * w - up * 0.0,
				chest_top + fw * 15.0 * w - up * 22.0, chest_top + fw * 6.0 * w - up * 12.0])
			draw_colored_polygon(lapel, _col(c1.lightened(0.12)))
			draw_polyline(lapel, _col(OUTLINE), 1.2, true)
		"robe":
			var v := PackedVector2Array([chest_top + fw * 4.0 * w, chest_top + fw * 12.0 * w - up * 30.0,
				chest_top + fw * 14.0 * w - up * 4.0])
			draw_colored_polygon(v, _col(look.get("skin", Color(0.8, 0.7, 0.6))))
			draw_line(chest_top + fw * 3.0 * w, chest_top + fw * 12.0 * w - up * 32.0, _col(c1.lightened(0.2)), 4.0, true)
		"fur":
			for i in 7:
				var a := TAU * i / 7.0
				_ellipse(chest_top - up * 2.0 + Vector2(cos(a), sin(a)) * 8.0 * w, 7.0 * w, 6.0 * w, c1.lightened(0.08 + 0.04 * (i % 2)))


func _coat_hem_y(hip: Vector2, top: String) -> float:
	var leg := (THIGH + SHIN) * _h
	match top:
		"fur":
			return hip.y + leg * 0.42
		"robe":
			return hip.y + leg * 0.62
		_:
			return hip.y + leg * 0.68


func _draw_coat_tail(hip: Vector2, up: Vector2, fw: Vector2, knee_f: Vector2, knee_b: Vector2, top: String,
		c: Color, w: float) -> void:
	var hem_y := _coat_hem_y(hip, top)
	var back_x: float = min(hip.x - 17.0 * w, knee_b.x - 14.0 * w)
	var pts := PackedVector2Array([hip + Vector2(-16.0 * w, -6.0), hip + Vector2(8.0 * w, -6.0),
		Vector2(max(knee_f.x, knee_b.x) - 4.0 * w, hem_y), Vector2(back_x - 4.0, hem_y + 2.0)])
	_poly(pts, c.darkened(0.25))


func _draw_coat_front(hip: Vector2, up: Vector2, fw: Vector2, knee_f: Vector2, top: String, c: Color, w: float) -> void:
	var hem_y := _coat_hem_y(hip, top)
	var front_x: float = max(knee_f.x + 13.0 * w, hip.x + 15.0 * w)
	var pts := PackedVector2Array([hip + Vector2(-15.0 * w, -10.0), hip + Vector2((15.0 + _belly * 8.0) * w, -10.0),
		Vector2(front_x + 3.0, hem_y), Vector2(hip.x - 2.0 * w, hem_y + 2.0)])
	if top == "fur":
		var fuzzy := PackedVector2Array()
		for i in pts.size():
			var a := pts[i]
			var b := pts[(i + 1) % pts.size()]
			for j in 5:
				var q := a.lerp(b, j / 5.0)
				fuzzy.append(q + Vector2(sin(i * 3.1 + j * 1.7), cos(j * 2.3 + i)) * 2.5)
		_poly(fuzzy, c)
	else:
		_poly(pts, c)
	if top == "robe" or top == "labcoat" or top == "overcoat":
		var belt_y := hip.y - 18.0
		if top == "robe":
			draw_line(Vector2(hip.x - 15.0 * w, belt_y), Vector2(hip.x + (16.0 + _belly * 10.0) * w, belt_y), _col(c.darkened(0.2)), 5.0, true)


func _draw_skirt(hip: Vector2, up: Vector2, fw: Vector2, knee_f: Vector2, knee_b: Vector2, top: String,
		c: Color, legs: Color, w: float) -> void:
	if top == "fur":
		return
	var col := c if top == "dress" else legs.lightened(0.12)
	var hem_y := hip.y + (THIGH + SHIN) * _h * 0.5
	var pts := PackedVector2Array([hip + Vector2(-15.0 * w, -8.0), hip + Vector2(15.0 * w, -8.0),
		Vector2(max(knee_f.x, knee_b.x) + 10.0 * w, hem_y), Vector2(min(knee_f.x, knee_b.x) - 16.0 * w, hem_y)])
	_poly(pts, col)


func _hp(hc: Vector2, hf: Vector2, hd: Vector2, x: float, y: float) -> Vector2:
	return hc + (hf * x + hd * y) * _h * HEAD_SCALE


func _hpoly(hc: Vector2, hf: Vector2, hd: Vector2, coords: Array) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for c in coords:
		pts.append(_hp(hc, hf, hd, c[0], c[1]))
	return pts


const HEAD_PROFILE := [[-16.0, 2.0], [-16.5, -6.0], [-13.0, -15.0], [-6.0, -21.0], [3.0, -22.0], [10.0, -18.5],
	[14.5, -11.0], [15.8, -4.5], [15.2, -1.0], [16.0, 2.0], [19.0, 6.5], [15.8, 8.0], [16.2, 10.5], [15.6, 12.5],
	[15.8, 14.5], [13.5, 18.0], [8.0, 20.5], [0.0, 19.0], [-6.0, 15.0], [-12.0, 10.0]]


func _draw_head(hc: Vector2, hf: Vector2, hd: Vector2, skin: Color) -> void:
	var profile := _hpoly(hc, hf, hd, HEAD_PROFILE)
	var hair_style: String = look.get("hair_style", "neat")
	var hair: Color = look.get("hair", Color(0.2, 0.15, 0.1))
	if hair_style in ["messy_long", "long", "wig", "bob"]:
		_draw_hair_back(hc, hf, hd, hair_style, hair)
	_poly(profile, skin)
	if silhouette.a > 0.0:
		_draw_hair(hc, hf, hd, hair_style, hair)
		return
	# Cheek shade and ear.
	draw_colored_polygon(_hpoly(hc, hf, hd, [[-16.0, 2.0], [-12.0, 10.0], [-6.0, 15.0], [0.0, 19.0], [-2.0, 8.0], [-8.0, -2.0]]), _col(Color(0, 0, 0, 0.12)))
	_ellipse(_hp(hc, hf, hd, -3.0, 1.0), 3.6 * _h, 5.4 * _h, skin.darkened(0.12), hf.angle())
	_ellipse(_hp(hc, hf, hd, -2.6, 1.2), 1.6 * _h, 3.0 * _h, skin.darkened(0.35), hf.angle())
	# Eye, brow, mouth.
	var e := expr
	var eye := _hp(hc, hf, hd, 10.5, -1.5)
	if _blink < 0.0 or e == "closed":
		draw_line(eye - hf * 2.4, eye + hf * 2.0, _col(OUTLINE), 1.6, true)
	else:
		_ellipse(eye, 2.6 * _h, 1.7 * _h, Color(0.94, 0.92, 0.88), hf.angle(), 10)
		_ellipse(eye + hf * 1.0, 1.4 * _h, 1.5 * _h, Color(0.12, 0.10, 0.09), hf.angle(), 8)
		if e == "shock":
			draw_arc(eye, 3.4 * _h, 0, TAU, 12, _col(OUTLINE), 1.0)
	var brow_in := Vector2(13.5, -6.0)
	var brow_out := Vector2(7.0, -6.5)
	match e:
		"angry", "pain":
			brow_in = Vector2(13.5, -4.2)
			brow_out = Vector2(7.0, -7.4)
		"sad", "cry":
			brow_in = Vector2(13.5, -7.6)
			brow_out = Vector2(7.0, -5.0)
		"shock":
			brow_in = Vector2(13.5, -8.6)
			brow_out = Vector2(7.0, -8.6)
		"smirk":
			brow_in = Vector2(13.5, -6.4)
			brow_out = Vector2(7.0, -7.8)
	draw_line(_hp(hc, hf, hd, brow_out.x, brow_out.y), _hp(hc, hf, hd, brow_in.x, brow_in.y), _col(hair.darkened(0.35)), 2.2 * _h, true)
	var lips: Color = look.get("lips", skin.darkened(0.32))
	var m_a := _hp(hc, hf, hd, 12.5, 12.0)
	var m_b := _hp(hc, hf, hd, 15.8, 11.8)
	if _talk_open() or e in ["shock", "laugh", "pain"]:
		var open := 2.6 if e != "laugh" else 3.2
		draw_colored_polygon(PackedVector2Array([m_a, m_b, _hp(hc, hf, hd, 15.6, 11.8 + open), _hp(hc, hf, hd, 12.8, 12.0 + open * 0.8)]), _col(Color(0.18, 0.05, 0.05)))
	elif e == "smirk":
		draw_polyline(PackedVector2Array([_hp(hc, hf, hd, 12.0, 11.0), m_a + hd * 0.6, m_b]), _col(lips), 1.8, true)
	elif e == "sad" or e == "cry":
		draw_polyline(PackedVector2Array([_hp(hc, hf, hd, 12.0, 13.2), m_a, m_b]), _col(lips), 1.8, true)
	else:
		draw_line(m_a, m_b, _col(lips), 1.8, true)
	if look.get("mustache", false):
		draw_colored_polygon(_hpoly(hc, hf, hd, [[12.5, 9.2], [16.6, 9.0], [17.0, 10.6], [12.0, 11.2]]), _col(hair.darkened(0.15)))
	if e == "cry" or e == "sad" and anim == "cry":
		draw_line(eye + hd * 2.0, eye + hd * 9.0, _col(Color(0.7, 0.85, 0.95, 0.7)), 1.4, true)
	# Bruises and blood, heaviest around the eye and nose.
	if bruise > 0.05:
		_ellipse(eye + hd * 0.6 - hf * 0.5, 4.6 * _h, 3.8 * _h, Color(0.36, 0.14, 0.30, min(0.7, bruise * 0.9)), hf.angle(), 12)
		if bruise > 0.35:
			_ellipse(_hp(hc, hf, hd, 7.0, 7.0), 4.0 * _h, 3.0 * _h, Color(0.42, 0.18, 0.26, min(0.55, bruise * 0.6)), hf.angle(), 10)
		if bruise > 0.6:
			draw_line(_hp(hc, hf, hd, 8.0, -9.0), _hp(hc, hf, hd, 12.0, -8.0), _col(Color(0.5, 0.05, 0.05)), 1.8, true)
	if blood > 0.08:
		var drip := 6.0 + blood * 14.0
		draw_line(_hp(hc, hf, hd, 16.2, 8.6), _hp(hc, hf, hd, 15.6, 8.6 + drip), _col(Color(0.55, 0.03, 0.03, 0.95)), 2.0 + blood * 1.6, true)
		if blood > 0.4:
			draw_line(_hp(hc, hf, hd, 10.0, -8.0), _hp(hc, hf, hd, 9.0, 4.0 + blood * 8.0), _col(Color(0.55, 0.03, 0.03, 0.9)), 1.6, true)
		if blood > 0.7:
			draw_line(_hp(hc, hf, hd, 14.0, 13.0), _hp(hc, hf, hd, 12.0, 22.0), _col(Color(0.5, 0.02, 0.02, 0.9)), 2.6, true)
	_draw_hair(hc, hf, hd, hair_style, hair)
	var glasses: String = look.get("glasses", "")
	if glasses == "sun":
		var lens := _hpoly(hc, hf, hd, [[6.5, -4.5], [16.2, -4.5], [15.8, 1.5], [8.0, 2.0]])
		draw_colored_polygon(lens, _col(Color(0.04, 0.04, 0.05, 0.95)))
		draw_line(_hp(hc, hf, hd, 6.5, -3.5), _hp(hc, hf, hd, -2.0, -1.0), _col(Color(0.05, 0.05, 0.05)), 1.6, true)
		draw_line(_hp(hc, hf, hd, 10.0, -3.6), _hp(hc, hf, hd, 13.5, -3.6), _col(Color(1, 1, 1, 0.25)), 1.2, true)
	elif glasses == "clear":
		var lens := _hpoly(hc, hf, hd, [[7.0, -4.5], [15.5, -4.5], [15.0, 1.2], [8.0, 1.6]])
		var closed := lens.duplicate()
		closed.append(lens[0])
		draw_polyline(closed, _col(Color(0.08, 0.08, 0.08)), 1.3, true)
		draw_line(_hp(hc, hf, hd, 7.0, -3.5), _hp(hc, hf, hd, -2.0, -1.0), _col(Color(0.08, 0.08, 0.08)), 1.2, true)


func _draw_hair_back(hc: Vector2, hf: Vector2, hd: Vector2, style: String, c: Color) -> void:
	var dark := c.darkened(0.25)
	match style:
		"messy_long":
			_poly(_hpoly(hc, hf, hd, [[-14.0, -14.0], [-20.0, 2.0], [-22.0, 18.0], [-17.0, 34.0], [-10.0, 30.0],
				[-6.0, 36.0], [-2.0, 24.0], [-4.0, 10.0]]), dark)
		"long":
			_poly(_hpoly(hc, hf, hd, [[-14.0, -14.0], [-19.0, 0.0], [-19.0, 16.0], [-13.0, 26.0], [-6.0, 24.0], [-5.0, 10.0]]), dark)
		"wig", "bob":
			_poly(_hpoly(hc, hf, hd, [[-14.0, -14.0], [-19.0, 0.0], [-18.0, 14.0], [-10.0, 17.0], [-4.0, 12.0]]), dark)


func _draw_hair(hc: Vector2, hf: Vector2, hd: Vector2, style: String, c: Color) -> void:
	var pts: Array = []
	match style:
		"neat":
			pts = [[-16.6, 4.0], [-17.4, -7.0], [-13.0, -17.5], [-4.0, -23.5], [6.0, -23.0], [13.5, -17.0],
				[15.6, -10.0], [11.0, -13.0], [4.0, -16.0], [-3.0, -15.0], [-9.0, -10.0], [-11.0, -2.0], [-12.5, 6.0]]
		"messy_short":
			pts = [[-16.6, 4.0], [-18.5, -6.0], [-15.0, -14.0], [-16.0, -19.0], [-8.0, -22.0], [-6.0, -26.0], [1.0, -23.0],
				[6.0, -26.0], [9.0, -21.0], [15.0, -19.0], [14.0, -13.0], [16.0, -9.0], [10.0, -12.0], [4.0, -15.0],
				[-3.0, -14.0], [-9.0, -9.0], [-11.0, -1.0], [-12.5, 6.0]]
		"slick":
			pts = [[-16.0, 5.0], [-17.6, -6.0], [-13.0, -17.5], [-2.0, -24.0], [9.0, -23.5], [15.5, -16.5],
				[13.5, -14.5], [4.0, -17.5], [-6.0, -14.0], [-11.0, -5.0], [-12.0, 7.0]]
		"messy_long":
			pts = [[-15.0, 6.0], [-19.0, -6.0], [-15.0, -18.0], [-4.0, -25.0], [8.0, -24.0], [16.0, -17.0], [18.0, -9.0],
				[15.0, -6.0], [16.0, -2.0], [11.0, -8.0], [6.0, -13.0], [0.0, -14.0], [-7.0, -9.0], [-9.0, 2.0], [-12.0, 10.0]]
		"long":
			pts = [[-15.0, 6.0], [-18.0, -6.0], [-14.0, -18.0], [-4.0, -24.0], [8.0, -23.0], [15.0, -16.0], [15.5, -9.0],
				[10.0, -13.0], [3.0, -16.0], [-5.0, -13.0], [-9.0, -3.0], [-11.0, 8.0]]
		"spiky":
			pts = [[-16.6, 4.0], [-18.0, -6.0], [-16.0, -16.0], [-12.0, -24.0], [-8.0, -21.0], [-4.0, -29.0], [0.0, -23.0],
				[5.0, -30.0], [8.0, -23.0], [14.0, -26.0], [14.0, -17.0], [17.0, -14.0], [11.0, -13.0], [3.0, -16.0],
				[-5.0, -14.0], [-10.0, -6.0], [-12.0, 5.0]]
		"receding":
			pts = [[-16.6, 5.0], [-17.4, -6.0], [-14.5, -14.0], [-9.0, -17.0], [-10.0, -12.0], [-11.5, -2.0], [-12.5, 7.0]]
		"shaved", "buzz":
			var a := 0.45 if style == "shaved" else 0.9
			var cap := _hpoly(hc, hf, hd, [[-16.4, 2.0], [-16.8, -7.0], [-13.0, -16.0], [-5.0, -21.6], [3.0, -22.4],
				[10.5, -19.0], [14.0, -13.0], [8.0, -15.0], [-2.0, -15.0], [-10.0, -9.0], [-12.0, 3.0]])
			draw_colored_polygon(cap, _col(Color(c.r, c.g, c.b, a * c.a)))
			return
		"wig", "bob":
			pts = [[-16.0, 10.0], [-18.6, -4.0], [-14.0, -18.0], [-4.0, -24.0], [8.0, -23.0], [15.5, -16.0], [17.0, -6.0],
				[14.0, -9.0], [8.0, -14.0], [0.0, -15.0], [-6.0, -10.0], [-9.0, 0.0], [-11.0, 12.0]]
		"bun":
			_ellipse(_hp(hc, hf, hd, -14.0, -15.0), 7.0 * _h, 6.5 * _h, c.darkened(0.08))
			pts = [[-16.6, 4.0], [-17.4, -7.0], [-13.0, -17.5], [-4.0, -23.0], [6.0, -22.5], [13.5, -16.0],
				[14.6, -10.0], [10.0, -13.0], [2.0, -15.0], [-6.0, -12.0], [-10.0, -4.0], [-12.0, 6.0]]
		"cap":
			pts = [[-16.6, 4.0], [-16.0, -6.0], [-12.0, -12.0], [-11.0, -2.0], [-12.5, 6.0]]
			_poly(_hpoly(hc, hf, hd, pts), c)
			var hat_c := Color(look.get("top_color", Color(0.15, 0.18, 0.28))).darkened(0.1)
			_poly(_hpoly(hc, hf, hd, [[-17.0, -9.0], [-16.0, -20.0], [-6.0, -27.0], [8.0, -26.0], [15.0, -18.0],
				[14.0, -11.0], [24.0, -9.0], [23.0, -7.0], [12.0, -8.0], [-15.0, -7.0]]), hat_c)
			draw_line(_hp(hc, hf, hd, -15.5, -12.5), _hp(hc, hf, hd, 14.0, -12.0), _col(hat_c.darkened(0.4)), 2.0, true)
			_ellipse(_hp(hc, hf, hd, 6.0, -18.0), 2.6, 3.0, Color(0.82, 0.68, 0.28))
			return
		_:
			return
	_poly(_hpoly(hc, hf, hd, pts), c)
	if silhouette.a <= 0.0 and style in ["slick", "neat", "long", "messy_long", "wig", "bob"]:
		var sheen := _hpoly(hc, hf, hd, [[-10.0, -14.0], [-3.0, -20.0], [5.0, -20.5], [-2.0, -18.0], [-8.0, -12.0]])
		draw_colored_polygon(sheen, _col(c.lightened(0.22)))


func _draw_prop(hand: Vector2, fore_ang: float, head_c: Vector2) -> void:
	if prop == "" or prop == "none":
		return
	var d := _dir(fore_ang)
	var n := Vector2(-d.y, d.x)
	match prop:
		"cigarette":
			var a := hand + d * 5.0 + n * 3.0
			var b := a + d.rotated(-0.6) * 13.0
			draw_line(a, b, _col(Color(0.94, 0.92, 0.86)), 2.6, true)
			draw_line(b, b + d.rotated(-0.6) * 2.2, _col(Color(1.0, 0.45, 0.12)), 2.8, true)
			if silhouette.a <= 0.0:
				var smoke := PackedVector2Array()
				for i in 12:
					var tt := i / 11.0
					smoke.append(b + Vector2(sin(_t * 1.6 + tt * 6.0) * 6.0 * tt, -tt * 60.0))
				draw_polyline(smoke, _col(Color(0.85, 0.85, 0.82, 0.18)), 3.0, true)
		"gun":
			var g0 := hand + d * 2.0
			var barrel := g0 + d * 26.0
			draw_line(g0 - n * 3.0, barrel - n * 3.0, _col(Color(0.12, 0.12, 0.13)), 6.5, true)
			draw_colored_polygon(PackedVector2Array([g0 - n * 1.0, g0 + d * 6.0, g0 + d * 4.0 + n * 12.0, g0 - d * 3.0 + n * 11.0]), _col(Color(0.08, 0.08, 0.08)))
		"briefcase":
			var top := hand + Vector2(0, 5)
			_poly(PackedVector2Array([top + Vector2(-22, 6), top + Vector2(22, 6), top + Vector2(22, 40), top + Vector2(-22, 40)]), Color(0.16, 0.12, 0.10))
			draw_rect(Rect2(top + Vector2(-4, 0), Vector2(8, 7)), _col(Color(0.10, 0.08, 0.07)), false, 2.0)
		"soap":
			_poly(PackedVector2Array([hand + Vector2(-9, -6), hand + Vector2(9, -6), hand + Vector2(10, 5), hand + Vector2(-10, 5)]), Color(0.95, 0.66, 0.74))
		"phone":
			draw_line(hand, head_c + Vector2(2, 6), _col(Color(0.08, 0.08, 0.08)), 6.0, true)
		"beer":
			_poly(PackedVector2Array([hand + Vector2(-4, -16), hand + Vector2(4, -16), hand + Vector2(5, 14), hand + Vector2(-5, 14)]), Color(0.32, 0.18, 0.06, 0.95))
			draw_line(hand + Vector2(0, -16), hand + Vector2(0, -26), _col(Color(0.32, 0.18, 0.06)), 3.5, true)
		"cup":
			_poly(PackedVector2Array([hand + Vector2(-6, -10), hand + Vector2(6, -10), hand + Vector2(5, 6), hand + Vector2(-5, 6)]), Color(0.92, 0.9, 0.86))
		"card":
			_poly(PackedVector2Array([hand + d * 3.0, hand + d * 3.0 + n * 18.0, hand + d * 14.0 + n * 18.0, hand + d * 14.0]), Color(0.95, 0.93, 0.88))
		"bag":
			_poly(PackedVector2Array([hand + Vector2(-12, 2), hand + Vector2(12, 2), hand + Vector2(16, 34), hand + Vector2(0, 40), hand + Vector2(-16, 34)]), Color(0.88, 0.86, 0.80, 0.9))
		"catalog":
			_poly(PackedVector2Array([hand + Vector2(-2, -24), hand + Vector2(30, -18), hand + Vector2(30, 14), hand + Vector2(-2, 8)]), Color(0.92, 0.82, 0.30))
		"pot":
			_poly(PackedVector2Array([hand + Vector2(-4, -6), hand + Vector2(40, -6), hand + Vector2(36, 26), hand + Vector2(0, 26)]), Color(0.55, 0.56, 0.58))
		"bottle":
			_poly(PackedVector2Array([hand + Vector2(-5, -14), hand + Vector2(5, -14), hand + Vector2(6, 16), hand + Vector2(-6, 16)]), Color(0.86, 0.86, 0.80))
		"flashlight":
			draw_line(hand, hand + d * 20.0, _col(Color(0.15, 0.15, 0.16)), 7.0, true)


## Global position of a named joint: hip, chest, head, hand_f, hand_b, foot_f, foot_b.
func point(joint: String) -> Vector2:
	if _joints.is_empty():
		return global_position + Vector2(0, -150) * scale
	var local: Vector2 = _xf * Vector2(_joints.get(joint, Vector2(0, -150)))
	return to_global(local)
