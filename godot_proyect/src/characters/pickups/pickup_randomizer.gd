extends Node2D

const UPGRADE = preload("res://src/characters/pickups/upgrade.tscn")
const PICKUP = preload("res://src/characters/pickups/filler_pickup.tscn")

const UPGRADE_CHANCE = .4

func _ready():
	randomize()
	if randf() <= UPGRADE_CHANCE:
		transform_into(UPGRADE)
	else:
		transform_into(PICKUP)

func transform_into(scene : PackedScene) -> void:
	var inst = scene.instance()
	inst.init(global_position)
	get_parent().call_deferred("add_child", inst)
	queue_free()
