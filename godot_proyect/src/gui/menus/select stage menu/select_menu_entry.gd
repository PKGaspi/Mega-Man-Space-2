extends Control

export(int) var column : int = 0
export(int) var row : int = 0

export(Texture) var texture : Texture = null

export(GDScript) var _action_on_press : GDScript = preload("res://src/gui/menus/menuaction_load_level.gd")

var selected : bool

signal action_executed

func _ready() -> void:
	set_texture(texture)

func set_texture(value : Texture) -> void:
	$FrameContainer/MenuEntryFrame.set_texture(value)
	
func set_selected(value : bool) -> void:
	selected = value
	$FrameContainer/MenuEntryFrame.set_selected(value)

func toggle_selected() -> void:
	set_selected(!selected)

func action() -> void:
	if _action_on_press != null:
		var script = _action_on_press.new()
		script.action(column, row)
		emit_signal("action_executed", column, row)
		
