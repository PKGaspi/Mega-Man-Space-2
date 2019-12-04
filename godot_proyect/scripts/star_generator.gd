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
const STAR_FREQUENCY = .5

const WIDTH = 1920 # Room width.
const HEIGHT = 1080 # Room height.
const TILES_X = 40 # Max stars in a row.
const TILES_Y = 40 # Max stars in a column.
const TILE_OFFSET = 10 # Offset for columns and rows.

var random
var r_seed
var layers = []

func _ready():
	
	# Initialize more constants.
	var STAR_MAX_SIZE = len(STAR_SIZES)
	var N_STAR_SPRITES = len(STARS)
	# Create random generator.
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()
	
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
		
	# Create the stars.
	for i in range(0, TILES_X):
		for j in range(0, TILES_Y):
			if (random.randf() < STAR_FREQUENCY):
				# Generate random position.
				var x = (float(i) / TILES_X) * WIDTH + (random.randf() - .5) * TILES_X * TILE_OFFSET
				x -= WIDTH / 2
				var y = (float(j) / TILES_Y) * HEIGHT + (random.randf() - .5) * TILES_Y * TILE_OFFSET
				y -= HEIGHT / 2
				
				# Generate random layer.
				var layer = random.randi_range(0, N_LAYERS - 1)
				
				# Calculate sprite from layer.
				var star_index = min(int((layer * 100) / (N_STAR_SPRITES * N_LAYERS)), N_STAR_SPRITES - 1)
				print(star_index)
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
				if (star_size == 0 && random.randi_range(0, 128) == 69):
					# IT'S A PLANET!!
					sprite = PLANETS[random.randi_range(0, len(PLANETS) - 1)]
				# Create the star.
				create_star(Vector2(x, y), layer, sprite)

func create_star(pos, layer, sprite):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	var star = Sprite.new()
	star.z_index = layers[layer].z_index
	star.position = pos
	star.texture = sprite
	layers[layer].add_child(star)