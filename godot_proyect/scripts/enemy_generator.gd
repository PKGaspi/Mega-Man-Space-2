extends Node2D

# List of all enemies to generate.
export(Array) var enemies = null
onready var enemies_len = len(enemies)

const WARNING = preload("res://scripts/pointing_sprite.gd")
const TEST = preload("res://assets/sprites/gui/warning/warning_mask.png")

# Zone where enemies spawn.
const AREA_SIZE = Vector2(200, 200)
const AREA_LIMITS = Rect2(Vector2(-400, -400), Vector2(800, 800))
var spawn_area 	: Rect2
var width		: float
var height 		: float
var centre 		: Vector2

var total_enemies = 10
var n_enemies = 0
var max_enemies = 4

var warning = null
var visibility_notifier = null

const TOTAL_ENEMIES_RANDOM_RANGE = Vector2(8, 15)
const MAX_ENEMIES_RANDOM_RANGE = Vector2(3, 6)

var random

func _ready():
	random = global.init_random()
	new_random_horde(AREA_LIMITS, TOTAL_ENEMIES_RANDOM_RANGE, MAX_ENEMIES_RANDOM_RANGE)

func _process(delta):
	while n_enemies < min(max_enemies, total_enemies):
		var x = random.randf_range(- width / 2, width / 2) + centre.x
		var y = random.randf_range(- height / 2, height / 2) + centre.y
		create_enemy(Vector2(x, y), random.randi_range(0, enemies_len - 1))
	if total_enemies == 0:
		new_random_horde(AREA_LIMITS, TOTAL_ENEMIES_RANDOM_RANGE, MAX_ENEMIES_RANDOM_RANGE)
		
		pass # Generate a new round or the boss.

func new_horde(new_spawn, total_enemies, max_enemies):
	if warning != null:
		warning.queue_free()
		visibility_notifier.queue_free()
	self.spawn_area = new_spawn
	self.width = spawn_area.size.x
	self.height = spawn_area.size.y
	self.centre = spawn_area.position.linear_interpolate(spawn_area.end, .5)
	self.total_enemies = total_enemies
	self.max_enemies = max_enemies
	create_warning(centre)
	
func new_random_horde(area_limits, total_enemies_range, max_enemies_range):
		var new_spawn = Rect2(Vector2(random.randf_range(area_limits.position.x, area_limits.end.x), random.randf_range(area_limits.position.y, area_limits.end.y)), AREA_SIZE)
		var total_enemies = random.randi_range(total_enemies_range.x, total_enemies_range.y)
		var max_enemies = random.randi_range(max_enemies_range.x, max_enemies_range.y)
		new_horde(new_spawn, total_enemies, max_enemies)
	

#########################
## Auxiliar functions. ##
#########################

func create_warning(centre : Vector2) -> void:
	warning = WARNING.new()
	warning.init(centre, null, Vector2(), global.MEGASHIP)
	warning.texture = TEST
	visibility_notifier = VisibilityNotifier2D.new()
	visibility_notifier. global_position = centre
	visibility_notifier.connect("screen_entered", warning, "_on_pointing_to_enters_screen")
	visibility_notifier.connect("screen_exited", warning, "_on_pointing_to_exits_screen")
	add_child(warning)
	add_child(visibility_notifier)


func create_enemy(pos, enemy_index):
	n_enemies += 1
	var inst = enemies[enemy_index].instance()
	inst.init(pos)
	add_child(inst)

func count_death():
	# TODO: Play death sound here.
	n_enemies -= 1
	total_enemies -= 1