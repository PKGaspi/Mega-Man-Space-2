class_name Spawner
extends Position2D

export(PackedScene) var to_spawn # What to spawn.
export(int) var max_spawns # Max spawned objects at the same time in the scene. Cero or Negative means there ins no maximum.
export(int) var total_spawns # Total spawns. When it reaches 0, the spawner destroys itself. Cero or Negative means this wont destroy itself then.
export(float) var time_between_spawns # Time to wait between spawn and spawn.
export(float) var max_distance_to_spawn = 300 # Maximmum distance to Mega Ship to spawn something. Cero or Negative means infinite.

var _spawn_timer: Timer

var n_spawns : int = 0
var spawn_when_free : bool = false # If true, the spawner will spawn as soon as there is space for one more spawn.



func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = time_between_spawns
	add_child(_spawn_timer)
	_spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout")
	_spawn_timer.start()
	pass


func spawn() -> void:
	var inst = to_spawn.instance()
	inst.global_position = global_position
	inst.connect("tree_exited", self, "_on_spawn_tree_exited")
	ObjectRegistry.register_node(inst)
	n_spawns += 1
	total_spawns -= 1
	if total_spawns == 0:
		queue_free()


func _on_spawn_tree_exited() -> void:
	n_spawns -= 1
	if spawn_when_free:
		spawn()
		spawn_when_free = false


func _on_spawn_timer_timeout() -> void:
	if n_spawns < max_spawns or max_spawns <= 0 and is_in_range():
		spawn()
	else:
		spawn_when_free = true


func is_in_range() -> bool:
	return (global.MEGASHIP != null and global.MEGASHIP.global_position.distance_to(global_position) <= max_distance_to_spawn) or max_distance_to_spawn <= 0
