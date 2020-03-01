extends Control

#const kdfj = preload("res://src/bullets/bullet.tscn")

var active = false setget set_active

func _ready() -> void:
	set_active(active)
	if !OS.is_debug_build():
		queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_menu"):
		toggle_active()

func set_active(value: bool) -> void:
	active = value
	visible = value

func toggle_active() -> void:
	set_active(!active)
