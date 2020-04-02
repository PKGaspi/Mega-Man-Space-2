class_name PointingSprite
extends Sprite



export var _to_owner_path: NodePath
onready var to_owner: CanvasItem = get_node(_from_owner_path)
var pointing_to: Vector2
export var _from_owner_path: NodePath
onready var from_owner: CanvasItem = get_node(_from_owner_path)
var pointing_from: Vector2

export var radious : float = 70

export(float, 0.0, 1.0, .05) var max_opacity := .9
export(float, 0.0, 1.0, .05) var min_opacity := .2

var initial_distance := 1.0


func _ready() -> void:
	global_position = calculate_position()



func _physics_process(delta: float) -> void:
	global_position = calculate_position()
	var distance = pointing_from.distance_to(pointing_to)
	initial_distance = max(initial_distance, distance)
	modulate.a = clamp(distance / initial_distance, min_opacity, max_opacity)


func calculate_position() -> Vector2:
	pointing_from = start_position()
	pointing_to = end_position()
		
	return pointing_from + pointing_from.direction_to(pointing_to) * radious


func start_position() -> Vector2:
	if is_instance_valid(from_owner):
		pointing_from =  from_owner.global_position
	return pointing_from


func end_position() -> Vector2:
	if is_instance_valid(to_owner):
		pointing_to = to_owner.global_position
	return pointing_to


func _on_pointing_to_enters_screen() -> void:
	visible = false


func _on_pointing_to_exits_screen() -> void:
	visible = true
