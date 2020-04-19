extends EnemyState

var path: Array
var init_pos: Vector2
var mid_pos: Vector2
var end_pos: Vector2

var path_index := 0

var timer: Timer = Timer.new()


func _ready() -> void:
	timer.wait_time = 1.2
	add_child(timer)

func _on_timer_timeout() -> void:
	next_point()


func enter(msg: Dictionary = {}) -> void:
	# Calculate init position and path to follow.
	
	var megaship_dir := Vector2(sin(megaship.global_rotation), cos(megaship.global_rotation)).normalized()
	
	init_pos = megaship.global_position + megaship_dir * 400
	mid_pos = megaship.global_position + megaship_dir.rotated(-PI/4) * 220
	end_pos = megaship.global_position + megaship_dir.rotated(-PI/2) * 100
	
	path = [init_pos, mid_pos, end_pos]
	path_index = 0
	character.global_position = init_pos
	
	timer.connect("timeout", self, "_on_timer_timeout")
	
	next_point()


func exit() -> void:
	timer.stop()
	timer.disconnect("timeout", self, "_on_timer_timeout")


func next_point() -> void:
	path_index += 1
	if path_index < len(path):
		_parent.to_follow = path[path_index]
		timer.start()
	else:
		_state_machine.transition_to("EndSpawnAnimation")
	
