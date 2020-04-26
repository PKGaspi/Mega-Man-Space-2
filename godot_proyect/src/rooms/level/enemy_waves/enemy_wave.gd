class_name EnemyWave
extends Node2D


export var wave_data: Resource = EnemyWaveData.new()

signal completed()
signal main_boss_spawned(boss)

func _ready() -> void:
	wave_data.initialize()


func _physics_process(delta: float) -> void:
	# Spawn new enemies if possible.
	while wave_data.can_spawn():
		spawn_random_enemy()
	
	# Check if the wave is defeated.
	if wave_data.is_completed():
		end()


func end() -> void:
	# End this wave.
	print("muy bien")
	emit_signal("completed")
	queue_free()

func spawn_boss() -> void:
	wave_data.boss_spawned = true
	var inst: Boss = spawn_enemy(wave_data.boss, wave_data.get_random_point())
	emit_signal("main_boss_spawned", inst)
	inst.start_spawn_animation()


func spawn_random_enemy() -> void:
	var enemy = wave_data.get_random_enemy()
	var pos = wave_data.get_random_point()
	
	spawn_enemy(enemy, pos)


func spawn_enemy(enemy: PackedScene, pos: Vector2) -> Enemy:
	pos = move_point_off_screen(pos, 20)
	return wave_data.spawn_enemy(enemy, pos)



# Takes a point and checks if it is inside the current camera.
# If it is, it returns the closest point outside the camera + margin.
# If it isn't, it returns the point itself.
func move_point_off_screen(pos: Vector2, margin: float = 0) -> Vector2:
	var visible_area_size := get_viewport().get_visible_rect().size
	var visible_area_center := -get_canvas_transform().get_origin()
	var visible_area := Rect2(visible_area_center, visible_area_size).grow(margin)
	
	var dir := visible_area_center.direction_to(pos)
	if dir == Vector2.ZERO: dir = Vector2.UP
	while visible_area.has_point(pos):
		# This method is clanky but it works and idc.
		pos += dir
	
	return pos
