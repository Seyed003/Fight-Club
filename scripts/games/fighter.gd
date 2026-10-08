class_name Fighter
extends RefCounted
## One combatant in a side-on brawl. Drives a Puppet's poses from a
## small state machine: idle, walk, block, attack, hit, dodge, down, ko.

const MOVES := {
	"jab": {"wind": 0.07, "active": 0.07, "recover": 0.15, "dmg": 5.0, "reach": 112.0, "push": 70.0,
		"pose_w": "jab_wind", "pose": "jab", "sfx": "punch_light", "stun": 0.24},
	"cross": {"wind": 0.15, "active": 0.08, "recover": 0.24, "dmg": 9.5, "reach": 122.0, "push": 150.0,
		"pose_w": "cross_wind", "pose": "cross", "sfx": "punch_heavy", "stun": 0.34},
	"hook": {"wind": 0.11, "active": 0.08, "recover": 0.26, "dmg": 12.0, "reach": 104.0, "push": 210.0,
		"pose_w": "cross_wind", "pose": "hook", "sfx": "punch_heavy", "stun": 0.42},
	"kick": {"wind": 0.2, "active": 0.1, "recover": 0.32, "dmg": 11.0, "reach": 158.0, "push": 230.0,
		"pose_w": "kick_wind", "pose": "kick", "sfx": "kick", "stun": 0.42, "low": true, "body": true},
	"rage": {"wind": 0.16, "active": 0.12, "recover": 0.5, "dmg": 24.0, "reach": 126.0, "push": 380.0,
		"pose_w": "crouch", "pose": "uppercut", "sfx": "punch_heavy", "stun": 0.9, "knockdown": true},
}

signal hit_landed(attacker: Fighter, target: Fighter, dmg: float, blocked: bool)
signal knocked_out(f: Fighter)

var puppet: Puppet
var who := ""
var is_player := false
var max_hp := 100.0
var hp := 100.0
var x := 0.0
var vx := 0.0
var facing := 1
var state := "idle"
var state_t := 0.0
var move := ""
var hit_done := false
var queued := ""
var combo := 0
var combo_t := 0.0
var rage := 0.0
var stun := 0.0
var inv := 0.0
var dodge_cd := 0.0
var speed := 230.0
var power := 1.0
var toughness := 1.0
var min_x := 90.0
var max_x := 1190.0
var can_die := true
var fx: FxLayer
var hits_taken := 0
var hits_landed := 0


func _init(p: Puppet, who_id: String, hp_value := 100.0) -> void:
	puppet = p
	who = who_id
	max_hp = hp_value
	hp = hp_value
	x = p.position.x
	puppet.set_pose("guard", 12.0)
	puppet.anim = "bounce"


func alive() -> bool:
	return state != "ko"


func busy() -> bool:
	return state in ["attack", "hit", "dodge", "down", "ko"]


func update(dt: float, opp: Fighter, input: Dictionary) -> void:
	state_t += dt
	inv -= dt
	dodge_cd -= dt
	combo_t -= dt
	if combo_t <= 0.0:
		combo = 0
	match state:
		"idle", "walk", "block":
			_free_state(dt, opp, input)
		"attack":
			_attack_state(dt, opp, input)
		"hit":
			if state_t >= stun:
				_to_idle()
		"dodge":
			if state_t < 0.22:
				x -= facing * 420.0 * dt
			elif state_t > 0.32:
				_to_idle()
		"down":
			if state_t > 1.5:
				puppet.set_pose("crouch", 6.0)
			if state_t > 2.0:
				inv = 0.7
				_to_idle()
		"ko":
			pass
	if absf(vx) > 1.0:
		x += vx * dt
		vx *= pow(0.004, dt)
	else:
		vx = 0.0
	x = clamp(x, min_x, max_x)
	if state in ["idle", "walk", "block", "hit"] and opp != null:
		facing = 1 if opp.x >= x else -1
	puppet.position.x = x
	puppet.facing = facing


func _free_state(dt: float, opp: Fighter, input: Dictionary) -> void:
	if input.get("block", false):
		if state != "block":
			state = "block"
			state_t = 0.0
			puppet.set_pose("block", 22.0)
			puppet.anim = ""
		return
	if input.get("special", false) and rage >= 100.0:
		_start("rage")
		rage = 0.0
		return
	for m in ["jab", "cross", "kick"]:
		if input.get(m, false):
			var chosen: String = m
			if m == "jab" and combo >= 2 and combo_t > 0.0:
				chosen = "hook"
			_start(chosen)
			return
	if input.get("dodge", false) and dodge_cd <= 0.0:
		state = "dodge"
		state_t = 0.0
		inv = 0.26
		dodge_cd = 0.7
		puppet.set_pose("dodge", 26.0)
		Sound.sfx("whoosh", -8.0)
		return
	var mv: float = input.get("move", 0.0)
	if absf(mv) > 0.1:
		x += mv * speed * dt
		if state != "walk":
			state = "walk"
			puppet.set_pose("guard", 14.0)
			puppet.anim = "bounce"
	else:
		if state != "idle":
			_to_idle()


func _to_idle() -> void:
	state = "idle"
	state_t = 0.0
	puppet.set_pose("guard", 12.0)
	puppet.anim = "bounce"


func _start(m: String) -> void:
	move = m
	state = "attack"
	state_t = 0.0
	hit_done = false
	queued = ""
	puppet.anim = ""
	puppet.set_pose(MOVES[m]["pose_w"], 30.0)
	if m == "rage":
		Sound.sfx("whoosh", -2.0, 0.7)


func _attack_state(_dt: float, opp: Fighter, input: Dictionary) -> void:
	var md: Dictionary = MOVES[move]
	var wind: float = md["wind"]
	var active: float = md["active"]
	var total: float = wind + active + float(md["recover"])
	for m in ["jab", "cross", "kick"]:
		if input.get(m, false) and state_t > wind:
			queued = m
	if state_t < wind:
		return
	if state_t < wind + active:
		if puppet.target_name != md["pose"]:
			puppet.set_pose(md["pose"], 40.0)
			if not hit_done:
				Sound.sfx("whoosh", -14.0, 1.3)
		if not hit_done and opp != null:
			_try_hit(opp, md)
		return
	if puppet.target_name != "guard":
		puppet.set_pose("guard", 14.0)
	var cancel := hit_done and state_t > wind + active + float(md["recover"]) * 0.45
	if (state_t >= total or cancel) and queued != "":
		var next := queued
		if next == "jab" and combo >= 2:
			next = "hook"
		_start(next)
		return
	if state_t >= total:
		_to_idle()


func _try_hit(opp: Fighter, md: Dictionary) -> void:
	var dx := opp.x - x
	if signf(dx) != float(facing) and absf(dx) > 8.0:
		return
	var reach: float = (float(md["reach"]) + (puppet.girth() + opp.puppet.girth() - 2.0) * 40.0) * puppet.scale.x
	if absf(dx) > reach:
		return
	if opp.inv > 0.0 or not opp.alive() or opp.state == "down":
		return
	hit_done = true
	var bonus := 1.0 + (0.35 if combo >= 2 else 0.0)
	var dmg: float = float(md["dmg"]) * power * bonus
	var blocked := opp.take_hit(self, md, dmg)
	if not blocked:
		combo += 1
		combo_t = 0.9
		hits_landed += 1
		rage = min(100.0, rage + dmg * 1.3)
	hit_landed.emit(self, opp, dmg, blocked)


## Returns true when the hit was blocked.
func take_hit(attacker: Fighter, md: Dictionary, dmg: float) -> bool:
	var facing_attacker := (attacker.x - x) * facing >= 0.0
	if state == "block" and facing_attacker:
		var through := 0.5 if md.get("low", false) else 0.12
		dmg *= through
		hp -= dmg / toughness
		vx = attacker.facing * float(md["push"]) * 0.35
		Sound.sfx("block", -4.0)
		if fx != null:
			fx.sparks(puppet.point("hand_f"), 6)
			fx.sweat(puppet.point("head"), Vector2(attacker.facing, -1), 3)
		rage = min(100.0, rage + dmg * 2.0)
		_check_ko(attacker)
		return true
	dmg /= toughness
	hp -= dmg
	hits_taken += 1
	rage = min(100.0, rage + dmg * 1.7)
	Sound.sfx(md["sfx"], 0.0 if dmg > 9.0 else -3.0)
	vx = attacker.facing * float(md["push"])
	var head := puppet.point("head")
	if fx != null:
		fx.blood(head + Vector2(attacker.facing * 6.0, 8.0), Vector2(attacker.facing, -0.4), int(clamp(dmg * 0.9, 2.0, 18.0)), 0.8 + dmg / 20.0)
		fx.sweat(head, Vector2(attacker.facing, -1), 4)
	var lost := 1.0 - hp / max_hp
	puppet.bruise = clamp(lost * 1.05, puppet.bruise, 1.0)
	puppet.blood = clamp(lost * 0.95, puppet.blood, 1.0)
	puppet.anim = ""
	if _check_ko(attacker):
		return false
	if md.get("knockdown", false) or (hp < max_hp * 0.22 and randf() < 0.18):
		state = "down"
		state_t = 0.0
		inv = 1.2
		puppet.set_pose("lie", 10.0)
		Sound.sfx("body_fall", -2.0)
		if fx != null:
			fx.dust(Vector2(x - attacker.facing * -60.0, puppet.position.y), 10)
		return false
	state = "hit"
	state_t = 0.0
	stun = md["stun"]
	puppet.set_pose("hit_body" if md.get("body", false) else "hit", 34.0)
	return false


func _check_ko(attacker: Fighter) -> bool:
	if hp > 0.0:
		return false
	if not can_die:
		hp = 1.0
		return false
	hp = 0.0
	state = "ko"
	state_t = 0.0
	puppet.anim = ""
	puppet.set_pose("lie" if attacker.facing * facing < 0 else "lie_face_down", 7.0)
	Sound.sfx("body_fall")
	if fx != null:
		fx.dust(Vector2(x, puppet.position.y), 16)
	knocked_out.emit(self)
	return true


func tap_out() -> void:
	state = "ko"
	state_t = 0.0
	puppet.anim = ""
	puppet.set_pose("kneel_down", 6.0)
	knocked_out.emit(self)
