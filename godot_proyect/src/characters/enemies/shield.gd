class_name Shield
extends StaticBody2D


func _init() -> void:
	set_collision_layer_bit(5, true)
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(3, true)
