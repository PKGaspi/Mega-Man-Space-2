tool
class_name TiledProgress
extends Control

export var max_value: float = 28 setget set_max_value
export var value: float = max_value setget set_value
export var cell_size: Vector2 = Vector2(7, 2)
export var horizontal: bool = false
export(Weapon.TYPES) var palette: int = 0 setget set_palette # Current palette index.

onready var snd_fill := $SndFill
onready var fill_timer := $FillTimer

const PALETTES = preload("res://resources/gui/progress_bar_palettes.tres")

func _ready() -> void:
	set_value(value)
	update_values()

func update_values():
	if get_child_count() == 0:
		call_deferred("update_values")
		return
	
	if horizontal:
		rect_size = Vector2(cell_size.x * max_value, cell_size.y)
		$Cells.rect_size = Vector2(cell_size.x * value, cell_size.y)
	else:
		rect_size = Vector2(cell_size.x, cell_size.y * max_value)
		$Cells.rect_size = Vector2(cell_size.x, cell_size.y * value)

func set_max_value(new_max_value: float) -> void:
	max_value = new_max_value
	set_value(value, false)

func set_value(new_value: float, pause: bool = false) -> void:
	if pause:
		global.pause()
		var diff = new_value - value
		var int_part = floor(diff)
		var i = 0
		while value < max_value and i < int_part:
			set_value(value + sign(diff))
			# Play sound and wait until it finishes.
			snd_fill.play()
			fill_timer.start()
			yield(get_node("FillTimer"), "timeout")
			i += 1
		global.unpause()
	value = clamp(new_value, 0, max_value)
	call_deferred("update_values")

func set_palette(value: int) -> void:
	if get_child_count() == 0:
		call_deferred("set_palette", value)
		return
	
	palette = value
	$Cells.material.set_shader_param("palette", PALETTES.get_frame("default", value))
	# TODO: set empty part color.
