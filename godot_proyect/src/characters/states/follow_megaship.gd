extends CharacterState

var view_distance: float
var megaship: Megaship


func _ready() -> void:
	yield(owner,"ready")
	
	var stats = character.stats
	stats.initialize()
	
	view_distance = stats.get_stat("view_distance")
	
	megaship = global.MEGASHIP
	if megaship is Megaship:
		megaship.connect("tree_exited", self, "_on_megaship_tree_exited")


func physics_process(delta: float) -> void:
	# Move.
	if megaship != null:
		_parent.to_follow = megaship.global_position
	_parent.physics_process(delta)
	
	# Check State changing.
	if megaship != null:
		var distance_to_megaship = character.global_position.distance_to(megaship.global_position)
		if distance_to_megaship > view_distance:
			roam()


func roam() -> void:
			var msg = {
				"center": character.global_position,
				"radious": 100,
			}
			_state_machine.transition_to("Iddle", msg)


func _on_megaship_tree_exited() -> void:
	megaship = null
	roam()
