class_name Poses
extends RefCounted
## Named body poses for Puppet.
##
## Keys (radians unless noted):
##   t      torso lean, + leans forward
##   h      head tilt, + looks down
##   uaf/faf  front upper arm (0 = hanging, + swings forward/up) and elbow bend
##   uab/fab  back arm, same convention
##   ff/fb  front / back foot x offset from the body origin (px)
##   ffy/fby  foot lift above the floor (px)
##   hx/hy  hip shift forward / hip drop toward the floor (px)
##   rot    whole-body rotation around the feet, + topples forward

const BASE := {
	"t": 0.02, "h": 0.0,
	"uaf": 0.08, "faf": 0.15, "uab": -0.06, "fab": 0.12,
	"ff": 10.0, "fb": -10.0, "ffy": 0.0, "fby": 0.0,
	"hx": 0.0, "hy": 2.0, "rot": 0.0,
}

const P := {
	"stand": {},
	"stand_relaxed": {"t": -0.02, "uaf": 0.02, "faf": 0.08, "uab": -0.02, "fab": 0.08, "ff": 14.0, "fb": -16.0},
	"hands_pockets": {"uaf": -0.12, "faf": 0.55, "uab": -0.22, "fab": 0.6, "t": -0.03},
	"arms_crossed": {"uaf": 0.35, "faf": 2.15, "uab": 0.25, "fab": 2.25, "t": -0.02},
	"talk": {"uaf": 0.45, "faf": 1.2, "uab": 0.0, "fab": 0.2},
	"talk_open": {"uaf": 0.7, "faf": 0.7, "uab": 0.35, "fab": 0.6, "t": 0.05},
	"point": {"uaf": 1.45, "faf": 0.05, "t": 0.06},
	"shrug": {"uaf": 0.35, "faf": 1.6, "uab": 0.3, "fab": 1.6, "h": -0.1},
	"think": {"uaf": 0.3, "faf": 2.6, "h": 0.2, "uab": 0.1, "fab": 1.4},
	"head_down": {"h": 0.45, "t": 0.12, "uaf": 0.02, "faf": 0.05, "uab": 0.0, "fab": 0.05},
	"smoke": {"uaf": 0.25, "faf": 2.7, "uab": 0.1, "fab": 1.3, "h": -0.05},
	"hold": {"uaf": 0.55, "faf": 1.25, "uab": 0.45, "fab": 1.3},
	"phone": {"uaf": 0.3, "faf": 2.85, "h": 0.1},
	"hug": {"uaf": 1.25, "faf": 0.85, "uab": 1.15, "fab": 0.95, "t": 0.18, "ff": 14.0, "fb": -6.0},
	"hugged": {"uaf": 0.9, "faf": 1.2, "uab": 0.8, "fab": 1.3, "t": 0.1, "h": 0.25},
	"cry": {"uaf": 0.55, "faf": 2.55, "uab": 0.45, "fab": 2.6, "h": 0.5, "t": 0.22},
	"arms_up": {"uaf": 2.85, "faf": 0.1, "uab": 2.75, "fab": 0.15, "h": -0.25},
	"cheer": {"uaf": 2.5, "faf": 0.6, "uab": 1.2, "fab": 1.8, "h": -0.2},
	"surrender": {"uaf": 1.9, "faf": 1.5, "uab": 1.8, "fab": 1.6},
	"walk": {"t": 0.06},
	"run": {"t": 0.25},
	"sit": {"hy": 72.0, "ff": 64.0, "fb": 56.0, "t": 0.0, "uaf": 0.4, "faf": 1.05, "uab": 0.3, "fab": 1.1},
	"sit_slump": {"hy": 76.0, "ff": 70.0, "fb": 60.0, "t": 0.28, "h": 0.35, "uaf": 0.45, "faf": 0.8, "uab": 0.35, "fab": 0.9},
	"sit_lean_back": {"hy": 72.0, "ff": 68.0, "fb": 58.0, "t": -0.18, "uaf": -0.25, "faf": 0.5, "uab": -0.3, "fab": 0.4},
	"sit_cross": {"hy": 72.0, "ff": 70.0, "fb": 56.0, "ffy": 16.0, "t": -0.04, "uaf": 0.3, "faf": 1.4, "uab": 0.2, "fab": 1.5},
	"sit_floor": {"hy": 128.0, "ff": 92.0, "fb": 80.0, "t": 0.15, "uaf": 0.6, "faf": 0.9, "uab": 0.5, "fab": 1.0},
	"crouch": {"hy": 62.0, "ff": 34.0, "fb": -26.0, "t": 0.35, "uaf": 0.5, "faf": 1.0, "uab": 0.3, "fab": 1.0},
	"kneel": {"hy": 70.0, "ff": 40.0, "fb": -40.0, "fby": 0.0, "t": 0.05, "uaf": 0.2, "faf": 0.4, "uab": 0.1, "fab": 0.4},
	"kneel_down": {"hy": 92.0, "ff": 30.0, "fb": -60.0, "t": 0.45, "h": 0.4, "uaf": 1.1, "faf": 0.2, "uab": 1.0, "fab": 0.25},
	"lie": {"rot": -1.5708, "uaf": 0.4, "faf": 0.3, "uab": -0.3, "fab": 0.2, "h": -0.1},
	"lie_face_down": {"rot": 1.5708, "uaf": 2.6, "faf": 0.3, "uab": 2.4, "fab": 0.4, "h": -0.2},
	"dead": {"rot": -1.5708, "uaf": 1.2, "faf": 0.5, "uab": -0.6, "fab": 0.1, "h": 0.3, "ff": 22.0, "fb": -4.0},
	# Fighting
	"guard": {"t": 0.14, "h": 0.12, "uaf": 0.75, "faf": 2.0, "uab": 0.55, "fab": 2.25, "ff": 34.0, "fb": -30.0, "hy": 10.0},
	"jab_wind": {"t": 0.1, "h": 0.12, "uaf": 0.55, "faf": 2.3, "uab": 0.55, "fab": 2.25, "ff": 34.0, "fb": -30.0, "hy": 12.0},
	"jab": {"t": 0.24, "h": 0.1, "uaf": 1.58, "faf": 0.04, "uab": 0.5, "fab": 2.3, "ff": 42.0, "fb": -30.0, "hy": 12.0, "hx": 8.0},
	"cross_wind": {"t": 0.0, "h": 0.12, "uaf": 0.8, "faf": 2.0, "uab": 0.15, "fab": 2.4, "ff": 34.0, "fb": -32.0, "hy": 12.0, "hx": -4.0},
	"cross": {"t": 0.36, "h": 0.1, "uaf": 0.6, "faf": 2.0, "uab": 1.62, "fab": 0.04, "ff": 44.0, "fb": -26.0, "hy": 14.0, "hx": 14.0},
	"hook": {"t": 0.3, "h": 0.12, "uaf": 1.45, "faf": 1.2, "uab": 0.5, "fab": 2.2, "ff": 40.0, "fb": -28.0, "hy": 14.0, "hx": 10.0},
	"uppercut": {"t": 0.2, "h": -0.05, "uaf": 2.3, "faf": 0.8, "uab": 0.5, "fab": 2.2, "ff": 36.0, "fb": -30.0, "hy": 4.0, "hx": 10.0},
	"kick_wind": {"t": -0.05, "uaf": 0.8, "faf": 1.9, "uab": 0.3, "fab": 2.0, "ff": 30.0, "ffy": 50.0, "fb": -20.0, "hy": 8.0},
	"kick": {"t": -0.3, "h": 0.15, "uaf": 0.6, "faf": 1.8, "uab": -0.4, "fab": 1.2, "ff": 128.0, "ffy": 108.0, "fb": -24.0, "hy": 6.0, "hx": -6.0},
	"block": {"t": 0.08, "h": 0.32, "uaf": 1.15, "faf": 2.65, "uab": 1.05, "fab": 2.7, "ff": 28.0, "fb": -36.0, "hy": 16.0},
	"dodge": {"t": -0.35, "h": -0.1, "uaf": 0.6, "faf": 2.1, "uab": 0.4, "fab": 2.2, "ff": 20.0, "fb": -44.0, "hy": 18.0, "hx": -16.0},
	"hit": {"t": -0.32, "h": -0.42, "uaf": 0.5, "faf": 0.6, "uab": -0.4, "fab": 0.4, "ff": 30.0, "fb": -34.0, "hy": 8.0, "hx": -10.0},
	"hit_body": {"t": 0.5, "h": 0.4, "uaf": 0.5, "faf": 1.9, "uab": 0.4, "fab": 2.0, "ff": 24.0, "fb": -30.0, "hy": 20.0, "hx": -6.0},
	"stagger": {"t": -0.15, "h": 0.3, "uaf": 0.3, "faf": 0.5, "uab": -0.2, "fab": 0.4, "ff": 16.0, "fb": -40.0, "hy": 14.0},
	"taunt": {"t": -0.1, "h": -0.15, "uaf": 0.2, "faf": 0.6, "uab": 0.2, "fab": 0.6, "ff": 24.0, "fb": -24.0, "hy": 4.0},
	"pummel": {"hy": 80.0, "ff": 36.0, "fb": -40.0, "t": 0.6, "h": 0.5, "uaf": 1.0, "faf": 0.1, "uab": 0.5, "fab": 2.2},
	"pummel_up": {"hy": 80.0, "ff": 36.0, "fb": -40.0, "t": 0.35, "h": 0.4, "uaf": 2.4, "faf": 1.6, "uab": 0.5, "fab": 2.2},
	"self_punch": {"t": 0.05, "h": -0.35, "uaf": 1.6, "faf": 2.6, "uab": 0.3, "fab": 1.0, "hx": -6.0},
	"gun_aim": {"uaf": 1.5, "faf": 0.02, "uab": 0.2, "fab": 0.4, "t": 0.04},
	"gun_mouth": {"uaf": 1.1, "faf": 2.35, "h": -0.15, "uab": 0.1, "fab": 0.3},
	"steer": {"hy": 72.0, "ff": 70.0, "fb": 62.0, "uaf": 1.05, "faf": 0.55, "uab": 1.0, "fab": 0.6, "t": 0.08},
	"steer_free": {"hy": 72.0, "ff": 70.0, "fb": 62.0, "uaf": 0.1, "faf": 0.6, "uab": 0.0, "fab": 0.5, "t": -0.12, "h": -0.25},
	"stir": {"uaf": 0.95, "faf": 0.75, "uab": 0.5, "fab": 1.2, "t": 0.2, "h": 0.35},
	"present": {"uaf": 1.0, "faf": 0.5, "uab": 0.9, "fab": 0.6, "t": 0.1},
	"hand_out": {"uaf": 1.0, "faf": 0.3, "t": 0.05},
	"fall_back": {"rot": -0.8, "t": -0.3, "h": -0.4, "uaf": 1.6, "faf": 0.3, "uab": 1.2, "fab": 0.2},
}


static func get_pose(pose_name: String) -> Dictionary:
	var out := BASE.duplicate()
	if P.has(pose_name):
		var p: Dictionary = P[pose_name]
		for k in p:
			out[k] = p[k]
	elif pose_name != "":
		push_warning("Poses: unknown pose %s" % pose_name)
	return out


static func has_pose(pose_name: String) -> bool:
	return P.has(pose_name)
