extends CharacterState


var center: Vector2
var radious: float

var distance: float
var time_to_change := 10
var timer_to_change: Timer

var view_distance: float
var megaship: Megaship

onready var rng = global.init_random()

func _ready() -> void:
	yield(owner, "ready")
	
	var stats = character.stats
	stats.initialize()
	view_distance = stats.get_stat("view_distance")
	
	# Timer to change roaming point every few seconds.
	timer_to_change = Timer.new()
	timer_to_change.name = "TimetToChange"
	timer_to_change.wait_time = time_to_change
	timer_to_change.autostart = true
	timer_to_change.connect("timeout", self, "roam_random_point")
	add_child(timer_to_change)
	
	megaship = global.MEGASHIP


func enter(msg: Dictionary = {}) -> void:
	assert(msg.has("radious"))
	assert(msg.has("center"))
	radious = msg["radious"]
	center = msg["center"]
	
	roam_random_point()


func physics_process(delta: float) -> void:
	# Move.
	_parent.physics_process(delta)
	
	
	# Check State changing.
	if is_instance_valid(megaship):
		var distance_to_megaship = character.global_position.distance_to(megaship.global_position)
		if distance_to_megaship <= view_distance:
			# If we are close to the Megaship, go back to normal behaviour.
			_state_machine.transition_to("Move/Follow/Megaship")
			


func roam_random_point() -> void:
	var new_point = Vector2.RIGHT.rotated(rng.randf_range(0, 2*PI)).normalized() 
	new_point *= rng.randf_range(0, radious)
	new_point += center
	distance = character.global_position.distance_to(new_point)
	_parent.to_follow = new_point
