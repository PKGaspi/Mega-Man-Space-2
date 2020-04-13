extends ParallaxBackground

# Preloaded sprites of all the stars.

export(SpriteFrames) var star_masks = null
export(SpriteFrames) var star_palettes = null
export(SpriteFrames) var planet_masks = null
export(SpriteFrames) var planet_palettes = null

var material = preload("res://resources/palette_swap_material.tres")

export var _to_follow_path: NodePath setget set_to_follow
var to_follow: CanvasItem

# Initialize runtime constants.
onready var N_STAR_MASKS = star_masks.get_frame_count("default")
onready var N_STAR_PALETTES = star_palettes.get_frame_count("default")
onready var N_PLANET_MASKS = planet_masks.get_frame_count("default")
onready var N_PLANET_PALETTES = planet_palettes.get_frame_count("default")

const Z_INDEX_OFFSET = 100
const N_LAYERS = 50
export(float) var MIN_MOTION_SCALE = .4
export(float) var MAX_MOTION_SCALE = 1

# How many stars are generated.
# Must be between 0.0 and 1.0
export(float) var STAR_FREQUENCY = .3
export(float) var PLANET_FREQUENCY = .008
export(int) var MAX_PLANETS_PER_SECTOR = 1

const SECTOR_SIZE_MULTIPLIER = .35
var sector_size: Vector2 # Sector size.
var sector_rows: int # Number of sectors loaded at the same time on a row.
var sector_columns: int # Number of sectors loaded at the same time on a column.
onready var stars_per_sector = 5 # Number of stars to attempt to generate per sector.

var random # Base randomizer.
var r_seed # Base random seed.
var seeds = {} # Seeds for each sector.
var stars = {} # Dictionary with lists of stars for each sector.
var layers = [] # Array of layers.
var materials = {}

var prev_sector = null # Megaship last sector.



func _ready():
	update_sector_values()
	# Create random generator.
	random = global.init_random()
	r_seed = random.seed
	
	
	# Create materials.
	create_materials(star_masks, star_palettes)
	create_materials(planet_masks, planet_palettes)
	
	
	# Create parallax layers.
	for i in range(N_LAYERS):
		var layer = ParallaxLayer.new()
		# Interpolate motion scale.
		var t = float(i + 1) / N_LAYERS
		var scale = lerp(MIN_MOTION_SCALE, MAX_MOTION_SCALE, t)
		layer.motion_scale = Vector2(scale, scale)
		layer.z_index = Z_INDEX_OFFSET + i
		layer.name = "Layer%02d" % i
		add_child(layer)
		layers.append(layer)
	
	
	
	# Connect Viewport size_changes signal.
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	
	set_to_follow(_to_follow_path)


func _physics_process(delta: float) -> void:
	if is_instance_valid(to_follow):
		var sector = pos_to_sector(to_follow.global_position)
		if prev_sector != sector:
			prev_sector = sector
			var active_sectors = Rect2(sector.x - sector_columns / 2, sector.y - sector_rows / 2, sector_columns, sector_columns)
			for s in stars.keys():
				if !active_sectors.has_point(s):
					destroy_stars(s)
			for i in range(-sector_rows / 2, sector_rows / 2):
				for j in range(-sector_columns / 2, sector_columns / 2):
					var new_sector = Vector2(sector.x + i, sector.y + j)
					if !stars.has(new_sector):
						create_stars(new_sector)


func _on_to_follow_tree_exiting():
	to_follow = null


func _on_viewport_size_changed():
	update_sector_values()


func update_sector_values() -> void:
	$BackgroundColor.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	sector_size = get_viewport().get_visible_rect().size * SECTOR_SIZE_MULTIPLIER
	sector_rows = round(get_viewport().get_visible_rect().size.y / 27)
	sector_columns = round(get_viewport().get_visible_rect().size.x / 48)



#########################
## Auxiliar functions. ##
#########################

func set_to_follow(path: NodePath) -> void:
	_to_follow_path = path
	if has_node(_to_follow_path):
		to_follow = get_node(_to_follow_path)
		


func create_materials(masks : SpriteFrames, palettes : SpriteFrames) -> void:
	for i in range(masks.get_frame_count("default")):
		for j in range(palettes.get_frame_count("default")):
			create_material(masks.get_frame("default", i), palettes.get_frame("default", j))


func create_material(mask : Texture, palette : Texture) -> Material:
	var new_material = material.duplicate()
	new_material.set_shader_param("mask", mask)
	new_material.set_shader_param("palette", palette)
	materials[[mask, palette]] = new_material
	return new_material


func pos_to_sector(pos):
	# Vector2 pos: position to check if is on the sector.
	var sector_x = int(pos.x / sector_size.x)
	var sector_y = int(pos.y / sector_size.y)
	return Vector2(sector_x, sector_y)


func create_star(pos, layer, mask, palette):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	var index = layers[layer].get_child_count()
	var star = Sprite.new()
	star.texture = mask
	star.z_index = layers[layer].z_index
	star.position = pos * layers[layer].motion_scale
	star.material = materials[[mask, palette]]
	star.name = "Star%02d" % index
	layers[layer].add_child(star)
	return star


func create_stars(sector):
	# Calculate sector position (top left corner).
	var pos = Vector2(sector_size.x * sector.x, sector_size.y * sector.y)
	
	# Create list entry in the dictionary of stars.
	stars[sector] = []
	
	# Set the seed.
	if !seeds.has(sector):
		seeds[sector] = r_seed * OS.get_ticks_usec()
	random.seed = seeds[sector]
	
	# Create the stars.
	var n_planets = 0
	for i in range(stars_per_sector):
		# Check if a new star is generated. Every time it's
		# harder for a new star to generate.
		if (random.randf() * i < STAR_FREQUENCY):
			# Generate random position.
			var x = random.randi_range(pos.x, pos.x + sector_size.x)
			var y = random.randi_range(pos.y, pos.y + sector_size.y)
			
			# Calculate sprite from layer.
			var star_mask = random.randi_range(0, N_STAR_MASKS - 1)
			var star_palette = random.randi_range(0, N_STAR_PALETTES - 1)
			
			# Calculate layer from mask.
			var layer = floor(float(star_mask) * N_LAYERS / N_STAR_MASKS + random.randf() * N_LAYERS / N_STAR_MASKS)
			
			# Get mask and palette.
			var mask
			var palette
			# This star might be a planet!
			if (star_mask == 0 && random.randf() < PLANET_FREQUENCY && n_planets < MAX_PLANETS_PER_SECTOR):
				# IT'S A PLANET!!
				n_planets += 1
				mask = planet_masks.get_frame("default", random.randi_range(0, N_PLANET_MASKS - 1))
				palette = planet_palettes.get_frame("default", random.randi_range(0, N_PLANET_PALETTES - 1))
			else:
				mask = star_masks.get_frame("default", star_mask)
				palette = star_palettes.get_frame("default", star_palette)
			
			# Create the star.
			stars[sector].append(create_star(Vector2(x, y), layer, mask, palette))


func destroy_stars(sector):
	# Calculate sector coordinates.
	for star in stars[sector]:
		star.queue_free()
	stars.erase(sector)
