extends Camera2D

export var _path_to_follow: NodePath setget set_to_follow
var _node_to_follow: Node2D
var _current_transform: RemoteTransform2D

func _ready() -> void:
	yield(owner,"ready")
	set_to_follow(_path_to_follow)

func set_to_follow(value: NodePath) -> void:
	_path_to_follow = value
	var node = get_node(_path_to_follow)
	if node is Node2D:
		_node_to_follow = node 
		if _current_transform != null:
			_current_transform.queue_free()
		_current_transform = RemoteTransform2D.new()
		_current_transform.name = "CameraTransform"
		_current_transform.remote_path = get_path()
		_node_to_follow.add_child(_current_transform)
