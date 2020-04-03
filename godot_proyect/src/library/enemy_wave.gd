class_name EnemyWave
extends Node2D


export var enemies: Resource = WeightRandomizer.new()
export var n_total_enemies: int
var n_enemies: int = 0 # Current number of enemies spawned.
export var n_max_enemies_at_once: int
export var radious: float = 500

onready var rng := global.init_random()

signal completed()

func _ready() -> void:
	assert(enemies is WeightRandomizer)
	enemies.initialize()


func _physics_process(delta: float) -> void:
	# Spawn new enemies if possible.
	while n_enemies < n_max_enemies_at_once and n_total_enemies > 0:
		random_enemy_spawn()
	
	# Check if the wave is defeated.
	if n_total_enemies <= 0 and ObjectRegistry.get_n_enemies() == 0:
		print("muy bien")
		emit_signal("completed")
		queue_free()


func random_enemy_spawn() -> void:
	var enemy = enemies.get_random_item()
	
	# TODO: Avoid spawning enemies on-screen.
	var x = rng.randf_range(-radious, radious)
	var y = rng.randf_range(-radious, radious)
	var pos = global_position + Vector2(x, y)
	
	enemy_spawn(enemy, pos)


func enemy_spawn(enemy: PackedScene, pos: Vector2) -> void:
	var inst = enemy.instance()
	inst.global_position = pos
	inst.connect("tree_exited", self, "_on_enemy_tree_exited")
	
	n_total_enemies -= 1
	n_enemies += 1
	ObjectRegistry.register_node(inst)


func _on_enemy_tree_exited() -> void:
	n_enemies -= 1
