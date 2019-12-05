extends ParallaxBackground

# Preloaded sprites of all the stars.
const STARS = [
	preload("res://assets/sprites/star_0.png"),
	preload("res://assets/sprites/star_1.png"),
	preload("res://assets/sprites/star_2.png"),
	preload("res://assets/sprites/star_3.png"),
	preload("res://assets/sprites/star_4.png"),
	preload("res://assets/sprites/star_5.png"),
	preload("res://assets/sprites/star_6.png"),
	preload("res://assets/sprites/star_7.png"),
	preload("res://assets/sprites/star_8.png"),
	preload("res://assets/sprites/star_9.png"),
]
# The sizes of the stars. This array means that, stars
# until the index 3 star (star_0 - star_3) have a size of
# one, stars from index 3+1 to 6 have a size of 2, etc.
const STAR_SIZES = [3, 5, 7, 9]

const PLANETS = [
	preload("res://assets/sprites/planet_0.png"),
]

const N_LAYERS = 50
const MIN_MOTION_SCALE = .4
const MAX_MOTION_SCALE = 1

# How many stars are generated.
# Must be between 0.0 and 1.0
const STAR_FREQUENCY = 1

const WIDTH = 30 # Room width.
const HEIGHT = 30 # Room height.
const TILES_X = 4 # Max stars in a row.
const TILES_Y = 4 # Max stars in a column.
const TILE_OFFSET = 0 # Offset for columns and rows.

var random
var r_seed
var layers = []

# Initialize runtime constants.
var STAR_MAX_SIZE = len(STAR_SIZES)
var N_STAR_SPRITES = len(STARS)

func _ready():
	
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
		
	create_stars(Vector2(0, 0))
	create_stars(Vector2(1, 0))
	create_stars(Vector2(0, 1))
	create_stars(Vector2(1, 1))
	create_stars(Vector2(-1, 0))
	create_stars(Vector2(0, -1))
	create_stars(Vector2(-1, -1))
	create_stars(Vector2(1, -1))
	create_stars(Vector2(-1, 1))
	create_stars(Vector2(-5, 3))
		
func create_stars(sector):
	# Calculate sector coordinates.
	var center_x = (WIDTH * sector.x)
	var center_y = (HEIGHT * sector.y)
	# Create the stars.
	var n_planetas = 0
	for i in range(0, TILES_X):
		for j in range(0, TILES_Y):
			if (random.randf() < STAR_FREQUENCY):
				# Generate random position.
				var x = (float(i) / TILES_X) * WIDTH + (random.randf() - .5) * TILES_X * TILE_OFFSET
				x += center_x - WIDTH / 2
				var y = (float(j) / TILES_Y) * HEIGHT + (random.randf() - .5) * TILES_Y * TILE_OFFSET
				y += center_y - HEIGHT / 2
				
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
				if (star_size == 0 && random.randi_range(0, 200 * n_planetas) == 0):
					# IT'S A PLANET!!
					#sprite = PLANETS[random.randi_range(0, len(PLANETS) - 1)]
					n_planetas += 1
				# Create the star.
				create_star(Vector2(x, y), 1, sprite)

func create_star(pos, layer, sprite):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	var star = Sprite.new()
	star.z_index = layers[layer].z_index
	star.position = pos
	star.texture = sprite
	layers[layer].add_child(star)