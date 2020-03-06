extends HBoxContainer

onready var ship_pos = get_node("Values/ShipPos")
onready var room = get_node("Values/Room")
onready var fps = get_node("Values/Fps")
onready var build = get_node("Values/Build")

const NULL_VALUE: String = "---"

func _process(delta: float) -> void:
	# Set values.
	
	if global.MEGASHIP is Megaship:
		ship_pos.text = "(%.1f, " % global.MEGASHIP.global_position.x + "%.1f)" % global.MEGASHIP.global_position.y
	else:
		ship_pos.text = NULL_VALUE
	
	fps.text = str(Engine.get_frames_per_second())
	
	room.text = get_tree().current_scene.name if get_tree().current_scene else NULL_VALUE
	
	build.text = NULL_VALUE
