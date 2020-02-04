extends Control

var to_move : Vector2 = Vector2(0, 100)
func _ready() -> void:
	$Music.play()
	animate_camera()
	
func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	animate_camera()
	
func animate_camera() -> void:
	to_move = to_move.rotated(randf() * PI)
	var tween = $Tween
	var camera = $Camera
	tween.interpolate_property(camera, "position",
		camera.position, camera.position + to_move,
		5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	


