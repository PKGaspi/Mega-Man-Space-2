tool
class_name Toggler
extends TextureRect


export var off_texture: Texture
export var on_texture: Texture
export var checked: bool = false setget set_checked

func _ready() -> void:
	pass


func set_checked(value: bool) -> void:
	checked = value
	texture = on_texture if checked else off_texture


func toggle_checked() -> void:
	set_checked(not get_checked())


func get_checked() -> bool:
	return checked
