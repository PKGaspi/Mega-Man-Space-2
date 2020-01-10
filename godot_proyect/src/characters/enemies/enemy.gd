extends "res://src/characters/character.gd"

export (SpriteFrames) var masks
export (SpriteFrames) var palettes

onready var GUILAYER = $"/root/Space/GUILayer"
# Bars.
const PROGRESS_BAR = preload("res://src/gui/progress_bar.tscn")
const BAR_CELL_SIZE = Vector2(4, 2)
var hp_bar_offset = Vector2(-10, 0)
var hp_bar

export(float) var move_speed = 0

var drop = load("res://src/characters/pickups/pickup_randomizer.gd")
export(float) var drop_chance = 1

export(float) var damage = 4 # Collision damage.

var to_follow : Node2D = null
var dir : Vector2 = Vector2()

func _ready():
	if has_node("Sprite") and $Sprite.texture != null:
		var sprite_size = $Sprite.texture.get_size()
		# Init HP bar.
		hp_bar = PROGRESS_BAR.instance()
		hp_bar_offset = Vector2(sprite_size.x / 2 + BAR_CELL_SIZE.x, - sprite_size.y / 2)
		hp_bar.init(BAR_CELL_SIZE, hp_bar_offset, hp_max)
		add_child(hp_bar)
	
	# Connect to_follow exit_tree signal
	if to_follow != null:
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")
	
func _physics_process(delta: float) -> void:
	if to_follow != null:
		dir = global_position.direction_to(to_follow.global_position)
	var motion = dir * move_speed
	move_and_slide(motion)

func init(pos):
	global_position = pos

func _on_to_follow_tree_exiting():
	to_follow = null

#########################
## Auxiliar functions. ##
#########################

func take_damage(damage):
	.take_damage(damage)
	update_bar(hp_bar, hp, hp_max)

func die():
	# Generate an upgrade at random.
	if randf() <= drop_chance:
		var inst = drop.new()
		inst.global_position = global_position
		get_parent().call_deferred("add_child", inst)
	# Super method.
	.die()
	

func collide(collider):
	# Default action on collide.
	collider.hit(self)