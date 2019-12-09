extends ParallaxBackground

# Preloaded sprites of all the stars.
const STARS = [
	preload("res://assets/sprites/background/star_0.png"),
	preload("res://assets/sprites/background/star_1.png"),
	preload("res://assets/sprites/background/star_2.png"),
	preload("res://assets/sprites/background/star_3.png"),
	preload("res://assets/sprites/background/star_4.png"),
	preload("res://assets/sprites/background/star_5.png"),
	preload("res://assets/sprites/background/star_6.png"),
	preload("res://assets/sprites/background/star_7.png"),
	preload("res://assets/sprites/background/star_8.png"),
	preload("res://assets/sprites/background/star_9.png"),
]
# The sizes of the stars. This array means that, stars
# until the index 3 star (star_0 - star_3) have a size of
# one, stars from index 3+1 to 6 have a size of 2, etc.
const STAR_SIZES = [3, 5, 7, 9]

const PLANETS = [
	preload("res://assets/sprites/background/planet_0.png"),
]

# Initialize runtime constants.
var STAR_MAX_SIZE = len(STAR_SIZES)
var N_STAR_SPRITES = len(STARS)

const N_LAYERS = 50
const MIN_MOTION_SCALE = .4
const MAX_MOTION_SCALE = 1

# How many stars are generated.
# Must be between 0.0 and 1.0
const STAR_FREQUENCY = .1
const PLANET_FREQUENCY = .0004
const MAX_PLANETS_PER_SECTOR = 1

const SECTOR_WIDTH = 160 # Sector width.
const SECTOR_HEIGHT = 100 # Sector height.
const SECTOR_ROWS = 10 # Number of sectors loaded at the same time on a row.
const SECTOR_COLUMNS = 10 # Number of sectors loaded at the same time on a column.
const TILES_X = 4 # Max stars in a sector row.
const TILES_Y = 4 # Max stars in a sector column.
const TILE_OFFSET = 5 # Offset for columns and rows.

var random # Base randomizer.
var r_seed # Base random seed.
var seeds = {} # Seeds for each sector.
var stars = {} # Dictionary with lists of stars for each sector.
var layers = [] # Array of layers.

var prev_sector = Vector2(1000, 1000) # Megaship last sector.

var MEGASHIP

func _ready():
	
	MEGASHIP = get_tree().get_root().get_child(0).get_node("Megaship")
	# Create random generator.
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()
	r_seed = random.seed
	
	# Create parallax layers.
	for i in range(N_LAYERS):
		var layer = ParallaxLayer.new()
		# Interpolate motion scale.
		var t = float(i + 1) / N_LAYERS
		var scale = MIN_MOTION_SCALE * (1 - t) + MAX_MOTION_SCALE * t
		layer.motion_scale = Vector2(scale, scale)
		layer.z_index = i
		add_child(layer)
		layers.append(layer)
		
	create_stars(prev_sector)
	
func _process(delta):
	var sector = pos_to_sector(MEGASHIP.position)
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
	

func pos_to_sector(pos):
	# Vector2 pos: position to check if is on the sector.
	var sector_x = int(pos.x / SECTOR_WIDTH)
	var sector_y = int(pos.y / SECTOR_HEIGHT)
	return Vector2(sector_x, sector_y)

func create_star(pos, layer, sprite):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	var star = Sprite.new()
	star.z_index = layers[layer].z_index
	star.position = pos * layers[layer].motion_scale
	star.texture = sprite
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
				var star_index = min(int((layer * 100) / (N_STAR_SPRITES * N_LAYERS)), N_STAR_SPRITES - 1)
				var prev_size = 0
				var star_size
				for k in range(0, STAR_MAX_SIZE):
					if (star_index <= STAR_SIZES[k]):
						star_index = random.randi_range(prev_size, STAR_SIZES[k])
						star_size = k
						break
					prev_size = STAR_SIZES[k] + 1
				var sprite = STARS[star_index]
				# This star might be a planet!
				if (star_size == 0 && random.randf() < PLANET_FREQUENCY && n_planets < MAX_PLANETS_PER_SECTOR):
					# IT'S A PLANET!!
					n_planets += 1
					sprite = PLANETS[random.randi_range(0, len(PLANETS) - 1)]
				# Create the star.
				stars[sector].append(create_star(Vector2(x, y), layer, sprite))

func destroy_stars(sector):
	# Calculate sector coordinates.
	for star in stars[sector]:
		star.queue_free()
	stars.erase(sector)