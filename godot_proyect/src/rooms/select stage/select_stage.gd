extends Control

const LVL_SCENE = preload("res://src/rooms/space/space.tscn")

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

func _on_entry_actioned(column, row) -> void:
	if column != 0 or row != 0:
		var lvl = LVL_SCENE.instance()
		lvl.lvl_id = COORDS_TO_WEAPONS[Vector2(column, row)]
		
		get_tree().root.add_child(lvl)
		queue_free()
