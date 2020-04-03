extends Camera2D

export var _path_to_follow: NodePath setget set_to_follow
var _node_to_follow: Node2D
var _current_transform: RemoteTransform2D



func _ready() -> void:
	yield(owner,"ready")
	set_to_follow(_path_to_follow)


func set_to_follow(value: NodePath) -> void:
	_path_to_follow = value
	if !has_node(_path_to_follow):
		return
	var node = get_node(_path_to_follow)
	if node is Node2D:
		_node_to_follow = node 
		if _current_transform != null:
			_current_transform.queue_free()
		# Create a remote transform on the new to_follow node.
		_current_transform = RemoteTransform2D.new()
		_current_transform.name = "CameraTransform"
		_current_transform.remote_path = get_path()
		_node_to_follow.add_child(_current_transform)


func get_visible_area() -> Rect2:
	return Rect2(global_position, get_viewport().size)
