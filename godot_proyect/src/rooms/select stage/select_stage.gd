extends Control

const LVL_SCENE = preload("res://src/rooms/level/level.tscn")

var COORDS_TO_WEAPONS = {
	Vector2(-1, -1) : Weapon.TYPES.BUBBLE,
	Vector2(0, -1) : Weapon.TYPES.AIR,
	Vector2(1, -1) : Weapon.TYPES.QUICK,
	Vector2(-1, 0) : Weapon.TYPES.HEAT,
	Vector2(0, 0) : Weapon.TYPES.MEGA,
	Vector2(1, 0) : Weapon.TYPES.WOOD,
	Vector2(-1, 1) : Weapon.TYPES.METAL,
	Vector2(0, 1) : Weapon.TYPES.FLASH,
	Vector2(1, 1) : Weapon.TYPES.CRASH,
}


func _ready() -> void:
	get_tree().current_scene = self


func _on_entry_actioned(column: int, row: int) -> void:
	if column != 0 or row != 0:
		var lvl = LVL_SCENE.instance()
		lvl.lvl_id = COORDS_TO_WEAPONS[Vector2(column, row)]
		
		get_tree().root.add_child(lvl)
		queue_free()
