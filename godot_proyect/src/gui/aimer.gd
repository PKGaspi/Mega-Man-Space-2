class_name Aimer
extends Sprite

var size
var radious := 100.0

func _ready() -> void:
	size = texture.get_size()
	pass

func _process(delta: float) -> void:
	match global.input_type:
		global.INPUT_TYPES.KEY_MOUSE:
			global_position = get_global_mouse_position()
			visible = true
		_:
			var dir = get_aiming_direction()
			position = dir.rotated(-global_rotation) * radious
			visible = dir.length() >= .1
			# TODO: Set position around the MEGASHIP. Maybe a pointing sprite like warnings?


func get_aiming_direction() -> Vector2:
	var dir := Vector2(
				Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
				Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
			)
	if dir.length() > 1:
		dir = dir.normalized()
	
	print(dir)
	return dir
