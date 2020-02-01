extends TextureRect

var size

func _ready() -> void:
	size = texture.get_size()
	pass

func _process(delta: float) -> void:
	match global.input_type:
		global.INPUT_TYPES.KEY_MOUSE:
			visible = true
			rect_position = get_viewport().get_mouse_position() - size / 2
		_:
			visible = false
		# TODO: Set position around the MEGASHIP. Maybe a pointing sprite like warnings?
	pass
