class_name FightAI
extends RefCounted
## Produces the same input dictionary a player would, from a personality:
## how pushy, how quick to react, how often it blocks or slips a punch.

const PRESETS := {
	"tyler_tutorial": {"hp": 140.0, "aggr": 0.32, "react": 0.4, "block": 0.18, "dodge": 0.05, "speed": 200.0, "power": 0.55,
		"moves": ["jab", "jab", "cross"]},
	"member": {"hp": 90.0, "aggr": 0.45, "react": 0.32, "block": 0.2, "dodge": 0.08, "speed": 215.0, "power": 0.8,
		"moves": ["jab", "jab", "cross", "kick"]},
	"ricky": {"hp": 95.0, "aggr": 0.55, "react": 0.3, "block": 0.15, "dodge": 0.05, "speed": 230.0, "power": 0.85,
		"moves": ["jab", "cross", "cross"]},
	"bob": {"hp": 170.0, "aggr": 0.42, "react": 0.45, "block": 0.08, "dodge": 0.0, "speed": 140.0, "power": 1.35,
		"moves": ["cross", "cross", "jab"], "tough": 1.1},
	"angel": {"hp": 105.0, "aggr": 0.62, "react": 0.22, "block": 0.3, "dodge": 0.25, "speed": 290.0, "power": 0.9,
		"moves": ["jab", "jab", "kick", "cross"]},
	"stranger": {"hp": 110.0, "aggr": 0.6, "react": 0.25, "block": 0.15, "dodge": 0.05, "speed": 220.0, "power": 1.0,
		"moves": ["jab", "cross"]},
	"monkey": {"hp": 100.0, "aggr": 0.55, "react": 0.25, "block": 0.25, "dodge": 0.1, "speed": 240.0, "power": 1.0,
		"moves": ["jab", "cross", "kick"]},
	"tyler_final": {"hp": 230.0, "aggr": 0.72, "react": 0.14, "block": 0.42, "dodge": 0.3, "speed": 285.0, "power": 1.25,
		"moves": ["jab", "jab", "cross", "kick", "cross"], "tough": 1.15},
}

var p: Dictionary
var _think := 0.0
var _plan := "approach"
var _block_t := 0.0
var _press := ""
var _retreat_t := 0.0
var passive := false


func _init(preset: String) -> void:
	p = PRESETS.get(preset, PRESETS["member"])


func input(me: Fighter, opp: Fighter, dt: float) -> Dictionary:
	var out := {"move": 0.0}
	if passive or not me.alive() or opp == null:
		return out
	_think -= dt
	_block_t -= dt
	_retreat_t -= dt
	var dist := absf(opp.x - me.x)
	var toward := signf(opp.x - me.x)
	var reach := (112.0 + (me.puppet.girth() + opp.puppet.girth() - 2.0) * 40.0) * me.puppet.scale.x
	# Reacting to an incoming attack.
	if opp.state == "attack" and dist < 175.0 and _think <= 0.0:
		_think = float(p["react"]) * randf_range(0.7, 1.3)
		var r := randf()
		if r < float(p["block"]):
			_block_t = randf_range(0.35, 0.7)
		elif r < float(p["block"]) + float(p["dodge"]):
			out["dodge"] = true
			return out
	if _block_t > 0.0:
		out["block"] = true
		return out
	if not opp.alive() or opp.state == "down":
		if dist < 160.0:
			out["move"] = -toward * 0.6
		return out
	if _retreat_t > 0.0:
		out["move"] = -toward
		return out
	if _think <= 0.0:
		_think = randf_range(0.18, 0.42) * (1.4 - float(p["aggr"]))
		if dist > reach * 0.95:
			_plan = "approach"
		elif randf() < float(p["aggr"]):
			var moves: Array = p["moves"]
			_press = moves[randi() % moves.size()]
			if _press == "kick" and dist < reach * 0.6:
				_press = "jab"
		elif randf() < 0.3:
			_retreat_t = randf_range(0.2, 0.5)
		else:
			_plan = "hold"
		if me.rage >= 100.0 and dist < reach and randf() < 0.5:
			_press = "special"
	if _press != "":
		out[_press] = true
		_press = ""
		return out
	if _plan == "approach" and dist > reach * 0.8:
		out["move"] = toward
	return out
