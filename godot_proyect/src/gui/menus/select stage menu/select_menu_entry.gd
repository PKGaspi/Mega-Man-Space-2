extends Control

export(int) var column : int = 0
export(int) var row : int = 0

export(Texture) var texture : Texture = null

var selected : bool = false

signal actioned

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
	emit_signal("actioned", column, row)
	
