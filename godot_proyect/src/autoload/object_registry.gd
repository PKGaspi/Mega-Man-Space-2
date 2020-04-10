extends Node

onready var _projectiles:= $Projectiles
onready var _enemies:= $Enemies
onready var _pickups:= $Pickups

var current_scene: Node

signal enemy_registered(enemy)

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
	_enemies.call_deferred("add_child", enemy)
	emit_signal("enemy_registered", enemy)


func register_pickup(pickup: Node) -> void:
	_pickups.call_deferred("add_child", pickup)


func get_enemies() -> Array:
	return _enemies.get_children()


func get_enemy_count() -> int:
	return _enemies.get_child_count()
