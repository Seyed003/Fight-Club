extends Node
## Entry scene. Everything else is built in code and swapped in by Game.


func _ready() -> void:
	Game.boot(self)
