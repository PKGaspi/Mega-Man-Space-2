class_name EnemyWaveData
extends Resource


export var boss: PackedScene
var boss_spawned := false
export var enemies: Resource = WeightRandomizer.new()
export var n_total_enemies: int
var n_enemies: int = 0 # Current number of enemies spawned.
var n_spawns_left: int
export var n_max_enemies_at_once: int
export var center: Vector2
export var radious: float = 500

var rng: RandomNumberGenerator


func initialize() -> void:
	assert(enemies is WeightRandomizer)
	enemies.initialize()
	
	n_spawns_left = n_total_enemies
	
	rng = global.init_random()
	
	if not ObjectRegistry.is_connected("enemy_registered", self, "_on_enemy_registered"):
		ObjectRegistry.connect("enemy_registered", self, "_on_enemy_registered")


func _on_enemy_registered(enemy) -> void:
	n_enemies += 1
	enemy.connect("tree_exited", self, "_on_enemy_tree_exited")


func _on_enemy_tree_exited() -> void:
	n_enemies -= 1


#########
## API ##
#########


func get_random_enemy():
	return enemies.get_random_item()


func get_random_point() -> Vector2:
	var x = rng.randf_range(-radious, radious)
	var y = rng.randf_range(-radious, radious)
	return center + Vector2(x, y)


func spawn_enemy(enemy: PackedScene, pos: Vector2) -> Enemy:
	if enemy == null:
		return null
	
	var inst = enemy.instance()
	inst.global_position = pos
	
	n_spawns_left -= 1
	ObjectRegistry.register_node(inst)
	return inst


func can_spawn() -> bool:
	return n_enemies < n_max_enemies_at_once and n_spawns_left > 0


func is_completed() -> bool:
	return n_spawns_left <= 0 and n_enemies <= 0 and (boss_spawned or boss == null)

