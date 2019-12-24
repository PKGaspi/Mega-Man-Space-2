extends Sprite

var pointing_to : Vector2
var to_owner : Node2D
var pointing_from : Vector2
var from_owner : Node2D


var close
var radius : float = 90

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if from_owner != null:
		pointing_from = from_owner.global_position
	if to_owner != null:
		pointing_to = to_owner.global_position
		
	global_position = pointing_from + pointing_from.direction_to(pointing_to) * radius

func init(pointing_to, to_owner = null, pointing_from = Vector2(), from_owner = null):
	self.pointing_to = pointing_to
	self.to_owner = to_owner
	self.pointing_from = pointing_from
	self.from_owner = from_owner
	
func _on_pointing_to_enters_screen():
	visible = false
	
func _on_pointing_to_exits_screen():
	visible = true