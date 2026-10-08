extends "res://scripts/locations/basement.gd"
## The same basement, crowd seated for Tyler's speech: brighter, quieter.


func _init() -> void:
	super()
	ambient = Color(0.34, 0.35, 0.34)
	amb_db = -16.0
	excite = 0.05
