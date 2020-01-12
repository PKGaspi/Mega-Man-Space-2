extends "res://src/characters/character.gd"

export (SpriteFrames) var masks
export (SpriteFrames) var palettes

onready var GUILAYER = $"/root/Space/GUILayer"
# Bars.
const PROGRESS_BAR = preload("res://src/gui/progress_bar.tscn")
const BAR_CELL_SIZE = Vector2(4, 2)
var hp_bar_offset = Vector2(-10, 0)
var hp_bar
export(bool) var show_hp_bar = true

export(float) var move_speed = 0
export(bool) var follow_megaship = false
export(float) var follow_max_distance = -1
var to_follow : Node2D = null
var dir : Vector2 = Vector2()

var drop = load("res://src/characters/pickups/pickup_randomizer.gd")
export(float) var drop_chance = .5

export(float) var damage = 4 # Collision damage.



func _ready():
	# Init HP bar.
	hp_bar = PROGRESS_BAR.instance()
	hp_bar.init(BAR_CELL_SIZE, $BarPosition.position, hp_max)
	hp_bar.visible = show_hp_bar
	hp_bar.set_palette(4)
	add_child(hp_bar)
	
	# Connect to_follow exit_tree signal
	if follow_megaship:
		to_follow = global.MEGASHIP
	if to_follow != null:
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")
	
func _physics_process(delta: float) -> void:
	if to_follow != null:
		dir = global_position.direction_to(to_follow.global_position)
	if follow_max_distance < 0 or global_position.distance_to(to_follow.global_position) <= follow_max_distance:
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
	hp_bar.update_values(hp, hp_max, 0)

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