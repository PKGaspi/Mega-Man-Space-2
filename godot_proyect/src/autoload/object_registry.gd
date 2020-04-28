extends Node

onready var _projectiles:= $Projectiles
onready var _enemies:= $Enemies
onready var _pickups:= $Pickups

var current_scene: Node

signal enemy_registered(enemy)
signal boss_registered(boss)


func _ready() -> void:
	current_scene = get_tree().current_scene


func set_visibility(value: bool) -> void:
	for child in get_children():
		if child is CanvasItem:
			child.visible = value


func reset() -> void:
	for layer in get_children():
		for child in layer.get_children():
			child.queue_free()


func register_node(node: Node) -> void:
	if node is Bullet:
		register_projectile(node)
	elif node is Enemy:
		register_enemy(node)
	elif node is Pickup:
		register_pickup(node)


func register_projectile(projectile: Node) -> void:
	_projectiles.call_deferred("add_child", projectile)


func register_enemy(enemy: Node) -> void:
	# Register in GameStats.
	var new_val = GameStats.enemies_spawned[enemy.filename] + 1 if GameStats.enemies_spawned.has(enemy.filename) else 1
	GameStats.enemies_spawned[enemy.filename] = new_val
	
	_enemies.call_deferred("add_child", enemy)
	if enemy is Boss:
		emit_signal("boss_registered", enemy)
	emit_signal("enemy_registered", enemy)


func register_pickup(pickup: Node) -> void:
	# Register in GameStats.
	var new_val = GameStats.pickups_spawned[pickup.filename] + 1 if GameStats.pickups_spawned.has(pickup.filename) else 1
	GameStats.pickups_spawned[pickup.filename] = new_val
	
	_pickups.call_deferred("add_child", pickup)


func get_enemies() -> Array:
	return _enemies.get_children()


func get_enemy_count() -> int:
	return _enemies.get_child_count()
