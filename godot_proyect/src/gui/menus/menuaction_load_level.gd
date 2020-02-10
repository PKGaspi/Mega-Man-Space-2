extends Node

const LEVEL = preload("res://src/rooms/space/space.tscn")

var WEAPONS = global.WEAPONS

var COORDS_TO_WEAPONS = {
	Vector2(-1, -1) : WEAPONS.BUBBLE,
	Vector2(0, -1) : WEAPONS.AIR,
	Vector2(1, -1) : WEAPONS.QUICK,
	Vector2(-1, 0) : WEAPONS.HEAT,
	Vector2(0, 0) : WEAPONS.MEGA,
	Vector2(1, 0) : WEAPONS.WOOD,
	Vector2(-1, 1) : WEAPONS.METAL,
	Vector2(0, 1) : WEAPONS.FLASH,
	Vector2(1, 1) : WEAPONS.CRASH,
}

func action(column : int, row : int) -> void:
	var inst = LEVEL.instance()
	inst.lvl_id = COORDS_TO_WEAPONS[Vector2(column, row)]
	
	global.get_tree().root.add_child(inst)
