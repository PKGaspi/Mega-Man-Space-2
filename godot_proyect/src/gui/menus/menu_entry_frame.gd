extends Control


onready var corners := $Corners
onready var flickering_timer := $FlickeringTimer
onready var image := $ImageContainer/TextureRect

var selected : bool = false

func _ready() -> void:
	corners.visible = selected

func _on_FlickeringTimer_timeout() -> void:
	corners.visible = !corners.visible

func set_texture(value : Texture) -> void:
	image.texture = value

func set_selected(value : bool) -> void:
	selected = value
	corners.visible = value
	if selected:
		flickering_timer.start()
	else:
		flickering_timer.stop()

func toggle_selected() -> void:
	set_selected(!selected)
