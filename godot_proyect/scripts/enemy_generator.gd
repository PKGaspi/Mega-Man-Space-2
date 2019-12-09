extends Node2D

const ENEMIES = [
	preload("res://scenes/enemies/asteroid.tscn")
]

const WIDTH = 100
const HEIGHT = 100

var total_enemies = 10
var n_enemies = 0
var max_enemies = 4

var region_centre = Vector2(100, 100)

var random

# A true/false array for the enemies this generator can spawn
var enemies_generated = [
	true
]

func _ready():
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()

func _process(delta):
	while n_enemies < min(max_enemies, total_enemies):
		var x = random.randf_range(- WIDTH / 2, WIDTH / 2) + region_centre.x
		var y = random.randf_range(- HEIGHT / 2, HEIGHT / 2) + region_centre.y
		create_enemy(Vector2(x, y), 0)
	if total_enemies == 0:
		init(random.randi_range(8, 15), random.randi_range(3, 6), Vector2(random.randi_range(-200, 200), random.randi_range(-200, 200)))
		
		pass # Generate a new round or the boss.

func init(total_enemies, max_enemies, region_centre):
	self.total_enemies = total_enemies
	self.max_enemies = max_enemies
	self.region_centre = region_centre
	# TODO: Create warning alert pointing region_centre.
	print("More enemies at " + str(region_centre))

func create_enemy(pos, enemy_index):
	if enemies_generated[enemy_index]:
		n_enemies += 1
		var inst = ENEMIES[enemy_index].instance()
		inst.init(pos)
		add_child(inst)

func count_death():
	n_enemies -= 1
	total_enemies -= 1