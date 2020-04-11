tool
class_name PointingSprite
extends PaletteSprite



export var _to_owner_path: NodePath
onready var to_owner: CanvasItem = get_node(_to_owner_path) if has_node(_to_owner_path) else to_owner
var pointing_to: Vector2

export var radious: float = 70.0

export(float, 0.0, 1.0, .05) var max_opacity := .9
export(float, 0.0, 1.0, .05) var min_opacity := .2
export var distance_to_disappear: float = 200.0

var initial_distance := 1.0




func _physics_process(delta: float) -> void:
	global_rotation = 0
	position = calculate_position()
	
	# Apply alpha
	var distance = global_position.distance_to(pointing_to)
	initial_distance = max(initial_distance, distance)
	if distance <= distance_to_disappear:
		modulate.a = 0
	else:
		modulate.a = clamp(distance / initial_distance, min_opacity, max_opacity)


func calculate_position() -> Vector2:
	pointing_to = calculate_pointing_to()
	var pos = global_position
	if is_instance_valid(owner) and owner is CanvasItem:
		pos = (owner.global_position.direction_to(pointing_to)).rotated(-owner.global_rotation) * radious
	return pos


func calculate_pointing_to() -> Vector2:
	if is_instance_valid(to_owner):
		pointing_to = to_owner.global_position
	return pointing_to


func _on_pointing_to_enters_screen() -> void:
	visible = false


func _on_pointing_to_exits_screen() -> void:
	visible = true
