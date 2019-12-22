extends ParallaxBackground

# Preloaded sprites of all the stars.

export(SpriteFrames) var star_masks = null
export(SpriteFrames) var star_palettes = null
export(SpriteFrames) var planet_textures = null

var texture = preload("res://assets/sprites/background/star_0.png")
var material = preload("res://other/palette_swap_material.tres")

# Initialize runtime constants.
onready var N_STAR_MASKS = star_masks.get_frame_count("default")
onready var N_STAR_PALETTES = star_palettes.get_frame_count("default")

const Z_INDEX_OFFSET = 100
const N_LAYERS = 50
const MIN_MOTION_SCALE = .4
const MAX_MOTION_SCALE = 1

# How many stars are generated.
# Must be between 0.0 and 1.0
const STAR_FREQUENCY = .4
const PLANET_FREQUENCY = -1
const MAX_PLANETS_PER_SECTOR = 1

const SECTOR_WIDTH = global.SCREEN_SIZE.x  # Sector width.
const SECTOR_HEIGHT = global.SCREEN_SIZE.y  # Sector height.
const SECTOR_ROWS = 4 # Number of sectors loaded at the same time on a row.
const SECTOR_COLUMNS = 4 # Number of sectors loaded at the same time on a column.
const TILES_X = 4 # Max stars in a sector row.
const TILES_Y = 4 # Max stars in a sector column.
const TILE_OFFSET = 10 # Offset for columns and rows.

var random # Base randomizer.
var r_seed # Base random seed.
var seeds = {} # Seeds for each sector.
var stars = {} # Dictionary with lists of stars for each sector.
var layers = [] # Array of layers.

var prev_sector = Vector2(1000, 1000) # Megaship last sector.

func _ready():
	
	# Create random generator.
	random = global.init_random()
	r_seed = random.seed
	
	# Create parallax layers.
	for i in range(N_LAYERS):
		var layer = ParallaxLayer.new()
		# Interpolate motion scale.
		var t = float(i + 1) / N_LAYERS
		var scale = MIN_MOTION_SCALE * (1 - t) + MAX_MOTION_SCALE * t
		layer.motion_scale = Vector2(scale, scale)
		layer.z_index = Z_INDEX_OFFSET + i
		add_child(layer)
		layers.append(layer)
		
	create_stars(prev_sector)
	
func _process(delta):
	var sector = pos_to_sector(global.MEGASHIP.position)
	var sector_x = sector.x
	var sector_y = sector.y
	if prev_sector != sector:
		for s in stars.keys():
			if sector.distance_to(s) >= 2:
				destroy_stars(s)
		for i in range(-SECTOR_ROWS / 2, SECTOR_ROWS / 2):
			for j in range(-SECTOR_COLUMNS / 2, SECTOR_COLUMNS / 2):
				var new_sector = Vector2(sector_x + i, sector_y + j)
				if !stars.has(new_sector):
					create_stars(new_sector)
		prev_sector = sector
	

#########################
## Auxiliar functions. ##
#########################

func pos_to_sector(pos):
	# Vector2 pos: position to check if is on the sector.
	var sector_x = int(pos.x / SECTOR_WIDTH)
	var sector_y = int(pos.y / SECTOR_HEIGHT)
	return Vector2(sector_x, sector_y)

func create_star(pos, layer, mask, palette):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	var star = Sprite.new()
	star.texture = texture
	star.z_index = layers[layer].z_index
	star.position = pos * layers[layer].motion_scale
	material.set_shader_param("mask", star_masks.get_frame("default", mask))
	material.set_shader_param("palette", star_palettes.get_frame("default", palette))
	star.material = material.duplicate(true)
	star.visible = true
	layers[layer].add_child(star)
	return star

func create_stars(sector):
	# Calculate sector coordinates.
	var center_x = (SECTOR_WIDTH * sector.x)
	var center_y = (SECTOR_HEIGHT * sector.y)
	
	# Create list entry in the dictionary of stars.
	stars[sector] = []
	
	# Set the seed.
	if !seeds.has(sector):
		seeds[sector] = r_seed * OS.get_ticks_usec()
	random.seed = seeds[sector]
	
	# Create the stars.
	var n_planets = 0
	for i in range(0, TILES_X):
		for j in range(0, TILES_Y):
			if (random.randf() < STAR_FREQUENCY):
				# Generate random position.
				var x = (float(i) / TILES_X) * SECTOR_WIDTH + (random.randf() - .5) * TILES_X * TILE_OFFSET
				x += center_x
				var y = (float(j) / TILES_Y) * SECTOR_HEIGHT + (random.randf() - .5) * TILES_Y * TILE_OFFSET
				y += center_y
				
				# Generate random layer.
				var layer = random.randi_range(0, N_LAYERS - 1)
				
				# Calculate sprite from layer.
				var star_mask = floor((float(layer) / (N_LAYERS)) * N_STAR_MASKS)
				print(star_mask)
				var star_palette = random.randi_range(0, N_STAR_PALETTES - 1)
				# This star might be a planet!
				if (star_mask == 0 && random.randf() < PLANET_FREQUENCY && n_planets < MAX_PLANETS_PER_SECTOR):
					# IT'S A PLANET!!
					n_planets += 1
				
				# Create the star.
				stars[sector].append(create_star(Vector2(x, y), layer, star_mask, star_palette))

func destroy_stars(sector):
	# Calculate sector coordinates.
	for star in stars[sector]:
		star.queue_free()
	stars.erase(sector)