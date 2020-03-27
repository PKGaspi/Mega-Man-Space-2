extends Node

onready var _projectiles:= $Projectiles
onready var _enemies:= $Enemies
onready var _pickups:= $Pickups


func _ready() -> void:
	global.connect("user_paused", self, "_on_user_paused")


func _on_user_paused(value: bool) -> void:
	for child in get_children():
		if child is CanvasItem:
			child.visible = !value


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


func register_pickup(pickup: Node) -> void:
	_pickups.call_deferred("add_child", pickup)
