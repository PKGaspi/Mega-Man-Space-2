class_name AnimatedPaletteSprite
extends AnimatedSprite

export(SpriteFrames) var palettes

func _ready() -> void:
	connect("frame_changed", self, "_on_frame_changed")



func set_animation(value: String) -> void:
	assert(frames.has_animation(value))
	.set_animation(value)
	set_mask(frame)


func set_palette(value: int) -> void:
	if material != null:
		material.set_shader_param("palette", palettes.get_frame("default", value))
		

func set_mask(value: int) -> void:
	if material != null:
		material.set_shader_param("mask", frames.get_frame(animation, value))

func _on_frame_changed() -> void:
	set_mask(frame)
