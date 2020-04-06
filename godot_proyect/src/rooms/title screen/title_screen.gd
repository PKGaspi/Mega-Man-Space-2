extends Control

const SELECT_SCREEN = "res://src/rooms/select stage/select_stage.tscn"

onready var tween = $Tween
onready var camera = $Camera

var to_move : Vector2 = Vector2(0, 300)


func _ready() -> void:
	get_tree().current_scene = self
	ObjectRegistry.reset()
	randomize()
	$Music.play()
	animate_camera()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start"):
		accept_event()
		game_start()


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	animate_camera()


func animate_camera() -> void:
	to_move = to_move.rotated(randf() * 2 * PI)
	tween.interpolate_property(camera, "position",
		camera.position, camera.position + to_move,
		5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()


func game_start():
	get_tree().change_scene(SELECT_SCREEN)
