class_name EnemyState
extends CharacterState


var megaship: Megaship

func _ready() -> void:
	yield(owner, "ready")
	
	megaship = global.MEGASHIP
