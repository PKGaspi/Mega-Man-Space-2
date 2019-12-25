extends Sprite

var max_opacity = .9
var min_opacity = .2

var pointing_to : Vector2
var to_owner : Node2D
var pointing_from : Vector2
var from_owner : Node2D

var initial_distance

var opacity_on_distance : bool = true

var radius : float = 70

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pointing_from = start_position()
	pointing_to = end_position()
		
	global_position = pointing_from + pointing_from.direction_to(pointing_to) * radius
	var distance = pointing_from.distance_to(pointing_to)
	initial_distance = max(initial_distance, distance)
	modulate.a = clamp(distance / initial_distance, min_opacity, max_opacity)

func init(texture, pointing_to, to_owner = null, pointing_from = Vector2(), from_owner = null):
	self.texture = texture
	self.pointing_to = pointing_to
	self.to_owner = to_owner
	self.pointing_from = pointing_from
	self.from_owner = from_owner
	initial_distance = start_position().distance_to(end_position())

func start_position() -> Vector2:
	if from_owner != null:
		return from_owner.global_position
	return pointing_from
		
func end_position() -> Vector2:
	if to_owner != null:
		return to_owner.global_position
	return pointing_to

func _on_pointing_to_enters_screen() -> void:
	visible = false
	
func _on_pointing_to_exits_screen() -> void:
	visible = true