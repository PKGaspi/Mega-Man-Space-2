class_name CharacterState
extends State

var character: Character

func _ready() -> void:
	yield(owner, "ready")
	character = owner
