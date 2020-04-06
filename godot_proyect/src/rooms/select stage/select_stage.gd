extends Control

const LEVEL_SCENE = preload("res://src/rooms/level/level.tscn")

onready var menu = $SelectStageMenu


func _ready() -> void:
	menu.connect("actioned", self, "_on_entry_actioned")
	get_tree().current_scene = self


func _on_entry_actioned(entry_data) -> void:
	if entry_data is LevelData:
		# TODO: Replace with level selected animation.
		load_level(entry_data)


func load_level(level_data: LevelData) -> void:
	var inst = LEVEL_SCENE.instance()
	inst.level_data = level_data
	get_tree().current_scene = inst
	get_tree().root.add_child(inst)
	queue_free()
	
