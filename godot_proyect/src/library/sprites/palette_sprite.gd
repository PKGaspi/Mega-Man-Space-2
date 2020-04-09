tool
class_name PaletteSprite
extends Sprite

export(SpriteFrames) var palettes
export var palette: int = 0 setget set_palette


func _init() -> void:
	set_texture(texture)


func set_texture(texture: Texture) -> void:
	.set_texture(texture)
	if material != null:
		material.set_shader_param("mask", texture)


func set_palette(value: int) -> void:
	palette = value
	if material != null:
		material.set_shader_param("palette", palettes.get_frame("default", value))
