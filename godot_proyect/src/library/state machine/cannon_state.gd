class_name CannonState
extends State


var cannons: Node


func _ready() -> void:
	yield(owner, "ready")
	cannons = owner
