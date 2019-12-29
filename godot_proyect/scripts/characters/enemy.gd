extends "res://scripts/characters/character.gd"

onready var GUILAYER = $"/root/Space/GUILayer"
# Bars.
const PROGRESS_BAR = preload("res://scenes/gui/progress_bar.tscn")
const BAR_CELL_SIZE = Vector2(4, 2)
var hp_bar_offset = Vector2(-10, 0)
var hp_bar

export(float) var move_speed = 0

export(PackedScene) var drop = load("res://scenes/characters/upgrade.tscn")
export(float) var upgrade_chance = .2

export(float) var damage = 4 # Collision damage.

var to_follow : Node2D = null
var dir : Vector2 = Vector2()

func _ready():
	var sprite_size = $Sprite.texture.get_size()
	# Init HP bar.
	hp_bar = PROGRESS_BAR.instance()
	hp_bar_offset = Vector2(sprite_size.x / 2 + BAR_CELL_SIZE.x, - sprite_size.y / 2)
	hp_bar.init(BAR_CELL_SIZE, hp_bar_offset, hp_max)
	add_child(hp_bar)
	pass
	
func _physics_process(delta: float) -> void:
	if to_follow != null:
		dir = global_position.direction_to(to_follow.global_position)
	var motion = dir * move_speed
	move_and_slide(motion)
	
	hp_bar.position = hp_bar_offset

func init(pos):
	global_position = pos

#########################
## Auxiliar functions. ##
#########################

func take_damage(damage):
	.take_damage(damage)
	update_bar(hp_bar, hp, hp_max)

func die():
	# Generate an upgrade at random.
	if randf() <= upgrade_chance:
		var inst = drop.instance()
		inst.global_position = global_position
		get_parent().add_child(inst)
	# Super method.
	.die()
	

func collide(collider):
	# Default action on collide.
	collider.hit(self)