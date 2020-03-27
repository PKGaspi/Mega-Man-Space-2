extends State

var megaship: Megaship


func _ready() -> void:
	megaship = global.MEGASHIP
	megaship.connect("tree_exited", self, "_on_megaship_tree_exited")


func physics_process(delta: float) -> void:
	if megaship != null:
		_parent.to_follow = megaship.global_position
		_parent.physics_process(delta)


func _on_megaship_tree_exited() -> void:
	megaship = null
