extends ParallaxBackground

#const STAR = preload("res://scenes/star.tscn")

const NUMBER_OF_LAYERS = 100
const MIN_MOTION_SCALE = .4
const MAX_MOTION_SCALE = 1

# How many stars are generated.
# Must be between 0.0 and 1.0
const STAR_FREQUENCY = .3 

const WIDTH = 1920 # Room width.
const HEIGHT = 1080 # Room height.
const TILES_X = 20 # Max stars in a row.
const TILES_Y = 20 # Max stars in a column.
const TILE_OFFSET = 10 # Offset for columns and rows.

var random
var r_seed
var layers = []

func _ready():
	
	# Create random generator.
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()
	
	# Create parallax layers.
	for i in range(NUMBER_OF_LAYERS):
		var layer = ParallaxLayer.new()
		# Interpolate motion scale.
		var t = float(i + 1) / NUMBER_OF_LAYERS
		var scale = MIN_MOTION_SCALE * (1 - t) + MAX_MOTION_SCALE * t
		layer.motion_scale = Vector2(scale, scale)
		layer.z_index = i
		add_child(layer)
		layers.append(layer)
		
	# Create the stars.
	for i in range(0, TILES_X):
		for j in range(0, TILES_Y):
			if (random.randf() < STAR_FREQUENCY):
				var x = (float(i) / TILES_X) * WIDTH + (random.randf() - .5) * TILES_X * TILE_OFFSET
				x -= WIDTH / 2
				var y = (float(j) / TILES_Y) * HEIGHT + (random.randf() - .5) * TILES_Y * TILE_OFFSET
				y -= HEIGHT / 2
				var layer = int(random.randf() * NUMBER_OF_LAYERS)
				create_star(Vector2(x, y), layer, "res://assets/sprites/lemon.png")

func create_star(pos, layer, sprite):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	sprite = load(sprite)
	var star = Sprite.new()
	star.z_index = layers[layer].z_index
	star.position = pos
	star.texture = sprite
	layers[layer].add_child(star)