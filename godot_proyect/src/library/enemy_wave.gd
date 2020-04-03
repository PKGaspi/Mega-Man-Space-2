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
	
	var x = rng.randf_range(-radious, radious)
	var y = rng.randf_range(-radious, radious)
	var pos = global_position + Vector2(x, y)
	
	enemy_spawn(enemy, pos)


func enemy_spawn(enemy: PackedScene, pos: Vector2) -> void:
	var inst = enemy.instance()
	inst.global_position = move_pos_off_screen(pos, 20)
	inst.connect("tree_exited", self, "_on_enemy_tree_exited")
	
	n_total_enemies -= 1
	n_enemies += 1
	ObjectRegistry.register_node(inst)


func _on_enemy_tree_exited() -> void:
	n_enemies -= 1


# Takes a point and checks if it is inside the current camera.
# If it is, it returns the closest point outside the camera + margin.
# If it isn't, it returns the point itself.
func move_pos_off_screen(pos: Vector2, margin: float = 0) -> Vector2:
	var visible_area_size := get_viewport().size
	var visible_area_center := -get_canvas_transform().get_origin()
	var visible_area := Rect2(visible_area_center, visible_area_size).grow(margin)
	
	var dir := visible_area_center.direction_to(pos)
	if dir == Vector2.ZERO: dir = Vector2.UP
	while visible_area.has_point(pos):
		pos += dir
	
	return pos
