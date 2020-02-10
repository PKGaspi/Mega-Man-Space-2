extends Control

var selected : bool = false

func _ready() -> void:
	$Corners.visible = selected

func _on_FlickeringTimer_timeout() -> void:
	$Corners.visible = !$Corners.visible

func set_image(value : Texture) -> void:
	$ImageContainer/TextureRect.texture = value

func set_selected(value : bool) -> void:
	selected = value
	if selected:
		$FlickeringTimer.start()
	else:
		$FlickeringTimer.stop()

func toggle_selected() -> void:
	set_selected(!selected)
