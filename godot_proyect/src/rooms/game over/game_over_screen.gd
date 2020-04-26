extends Node

var level_data: Resource setget set_level_data

onready var menu := $Control/GameOverMenu


func _ready() -> void:
	get_tree().current_scene = self


func set_level_data(value: Resource) -> void:
	level_data = value
	if not is_instance_valid(menu):
		call_deferred("set_level_data", value)
		return
	
	menu.level_data = level_data
