extends Node2D

# List of all enemies to generate.
export(Array) var enemies = null
onready var enemies_len = len(enemies)

const WARNING = preload("res://scripts/gui/pointing_sprite.gd")
export(SpriteFrames)var warning_masks
export(SpriteFrames)var warning_palettes
var warning_material = preload("res://other/palette_swap_material.tres").duplicate()
var warning_texture

onready var CENTER_TEXT = $"/root/Space/GUILayer/CenterContainer/CenterText"

# Zone where enemies spawn.
const AREA_SIZE = Vector2(200, 200)
const AREA_LIMITS = Rect2(Vector2(-2000, -2000), Vector2(4000, 4000))
var min_distance : float = AREA_LIMITS.size.length() / 4
var max_distance : float = AREA_LIMITS.size.length() / 2
var spawn_area : Rect2
var width : float
var height : float
var centre : Vector2

var horde : bool = false
var total_enemies : int = 10
var n_enemies : int = 0
var max_enemies : int = 4

var warning : Sprite = null
var warning_animation : bool = false
var visibility_notifier : VisibilityNotifier2D = null

const TOTAL_ENEMIES_RANDOM_RANGE = Vector2(8, 15)
const MAX_ENEMIES_RANDOM_RANGE = Vector2(3, 6)

var random

func _ready():
	random = global.init_random()
	
	var mask = warning_masks.get_frame("default", 0)
	warning_texture = global.create_empty_image(mask.get_size())
	warning_material.set_shader_param("mask", mask)
	warning_material.set_shader_param("palette", warning_palettes.get_frame("default", 0))

func _process(delta):
	if horde:
		while n_enemies < min(max_enemies, total_enemies):
			var x = random.randf_range(- width / 2, width / 2) + centre.x
			var y = random.randf_range(- height / 2, height / 2) + centre.y
			create_enemy(Vector2(x, y), random.randi_range(0, enemies_len - 1))
		if total_enemies == 0:
			horde = false
			new_random_horde()
		
		pass # Generate a new round or the boss.

func _on_enemy_death():
	count_death()

func new_horde(new_spawn, total_enemies, max_enemies):
	# TODO: play new horde sound.
	horde = true
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
	
func new_random_horde(area_limits = AREA_LIMITS, total_enemies_range = TOTAL_ENEMIES_RANDOM_RANGE, max_enemies_range = MAX_ENEMIES_RANDOM_RANGE):
	var new_pos = Vector2(random.randf_range(area_limits.position.x, area_limits.end.x), random.randf_range(area_limits.position.y, area_limits.end.y))
	var distance = spawn_area.position.distance_to(new_pos)
	while !(distance > min_distance and distance < max_distance):
		# Keep looking for a new location until it is in between max and min distance.
		new_pos = Vector2(random.randf_range(area_limits.position.x, area_limits.end.x), random.randf_range(area_limits.position.y, area_limits.end.y))
		distance = spawn_area.position.distance_to(new_pos)
	var new_spawn = Rect2(new_pos, AREA_SIZE)
	var total_enemies = random.randi_range(total_enemies_range.x, total_enemies_range.y)
	var max_enemies = random.randi_range(max_enemies_range.x, max_enemies_range.y)
	new_horde(new_spawn, total_enemies, max_enemies)
	

#########################
## Auxiliar functions. ##
#########################

func create_warning(centre : Vector2) -> void:
	CENTER_TEXT.set_animation("warning", 3)
	warning = WARNING.new()
	warning.init(warning_texture, centre, null, Vector2(), global.MEGASHIP)
	warning.material = warning_material
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
	inst.connect("death", self, "_on_enemy_death")
	add_child(inst)

func count_death():
	# TODO: Play death sound here.
	n_enemies -= 1
	total_enemies -= 1