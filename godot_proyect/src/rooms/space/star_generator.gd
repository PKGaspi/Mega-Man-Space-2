extends ParallaxBackground

# Preloaded sprites of all the stars.

export(SpriteFrames) var star_masks = null
export(SpriteFrames) var star_palettes = null
export(SpriteFrames) var planet_masks = null
export(SpriteFrames) var planet_palettes = null

var empty_star_texture
var empty_planet_texture
var material = preload("res://resources/palette_swap_material.tres")

# Initialize runtime constants.
onready var N_STAR_MASKS = star_masks.get_frame_count("default")
onready var N_STAR_PALETTES = star_palettes.get_frame_count("default")
onready var N_PLANET_MASKS = planet_masks.get_frame_count("default")
onready var N_PLANET_PALETTES = planet_palettes.get_frame_count("default")

const Z_INDEX_OFFSET = 100
const N_LAYERS = 50
const MIN_MOTION_SCALE = .4
const MAX_MOTION_SCALE = 1

# How many stars are generated.
# Must be between 0.0 and 1.0
export(float) var STAR_FREQUENCY = .3
export(float) var PLANET_FREQUENCY = .01
export(int) var MAX_PLANETS_PER_SECTOR = 1

var SECTOR_SIZE = global.SCREEN_SIZE * .35 # Sector size.
const SECTOR_ROWS = 10 # Number of sectors loaded at the same time on a row.
const SECTOR_COLUMNS = 10 # Number of sectors loaded at the same time on a column.
const STARS_PER_SECTOR = 5 # Number of stars to attempt to generate per sector.

var random # Base randomizer.
var r_seed # Base random seed.
var seeds = {} # Seeds for each sector.
var stars = {} # Dictionary with lists of stars for each sector.
var layers = [] # Array of layers.
var materials = {}

var prev_sector = Vector2(1000, 1000) # Megaship last sector.

func _ready():
	
	# Create random generator.
	random = global.init_random()
	r_seed = random.seed
	
	# Create empty textures for stars and planets.
	empty_star_texture = global.create_empty_image(star_masks.get_frame("default", 0).get_size())
	empty_planet_texture = global.create_empty_image(planet_masks.get_frame("default", 0).get_size())
	
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
		add_child(layer)
		layers.append(layer)
	

func _process(delta):
	if global.MEGASHIP != null:
		var sector = pos_to_sector(global.MEGASHIP.position)
		if prev_sector != sector:
			var active_sectors = Rect2(sector.x - SECTOR_COLUMNS / 2, sector.y - SECTOR_ROWS / 2, SECTOR_COLUMNS, SECTOR_COLUMNS)
			for s in stars.keys():
				if !active_sectors.has_point(s):
					destroy_stars(s)
			for i in range(-SECTOR_ROWS / 2, SECTOR_ROWS / 2):
				for j in range(-SECTOR_COLUMNS / 2, SECTOR_COLUMNS / 2):
					var new_sector = Vector2(sector.x + i, sector.y + j)
					if !stars.has(new_sector):
						create_stars(new_sector)
			prev_sector = sector
	

#########################
## Auxiliar functions. ##
#########################

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
	var sector_x = int(pos.x / SECTOR_SIZE.x)
	var sector_y = int(pos.y / SECTOR_SIZE.y)
	return Vector2(sector_x, sector_y)

func create_star(pos, layer, texture, mask, palette):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	var star = Sprite.new()
	star.texture = texture
	star.z_index = layers[layer].z_index
	star.position = pos * layers[layer].motion_scale
	star.material = materials[[mask, palette]]
	star.visible = true
	layers[layer].add_child(star)
	return star

func create_stars(sector):
	# Calculate sector position (top left corner).
	var pos = Vector2(SECTOR_SIZE.x * sector.x, SECTOR_SIZE.y * sector.y)
	
	# Create list entry in the dictionary of stars.
	stars[sector] = []
	
	# Set the seed.
	if !seeds.has(sector):
		seeds[sector] = r_seed * OS.get_ticks_usec()
	random.seed = seeds[sector]
	
	# Create the stars.
	var n_planets = 0
	for i in range(STARS_PER_SECTOR):
		# Check if a new star is generated. Every time it's
		# harder for a new star to generate.
		if (random.randf() * i < STAR_FREQUENCY):
			# Generate random position.
			var x = random.randi_range(pos.x, pos.x + SECTOR_SIZE.x)
			var y = random.randi_range(pos.y, pos.y + SECTOR_SIZE.y)
			
			# Calculate sprite from layer.
			var star_mask = random.randi_range(0, N_STAR_MASKS - 1)
			var star_palette = random.randi_range(0, N_STAR_PALETTES - 1)
			
			# Calculate layer from mask.
			var layer = floor(float(star_mask) * N_LAYERS / N_STAR_MASKS + random.randf() * N_LAYERS / N_STAR_MASKS)
			
			# Get mask and palette.
			var mask
			var palette
			var texture
			# This star might be a planet!
			if (star_mask == 0 && random.randf() < PLANET_FREQUENCY && n_planets < MAX_PLANETS_PER_SECTOR):
				# IT'S A PLANET!!
				n_planets += 1
				mask = planet_masks.get_frame("default", random.randi_range(0, N_PLANET_MASKS - 1))
				palette = planet_palettes.get_frame("default", random.randi_range(0, N_PLANET_PALETTES - 1))
				texture = empty_planet_texture
			else:
				mask = star_masks.get_frame("default", star_mask)
				palette = star_palettes.get_frame("default", star_palette)
				texture = empty_star_texture
			
			# Create the star.
			stars[sector].append(create_star(Vector2(x, y), layer, texture, mask, palette))

func destroy_stars(sector):
	# Calculate sector coordinates.
	for star in stars[sector]:
		star.queue_free()
	stars.erase(sector)