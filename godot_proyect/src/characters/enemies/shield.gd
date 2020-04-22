class_name Shield
extends StaticBody2D


onready var collision_box := $CollisionBox


func enable() -> void:
	collision_box.disabled = false
	visible = true


func disable() -> void:
	collision_box.disabled = true
	visible = false
