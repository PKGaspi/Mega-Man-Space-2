extends ParallaxBackground

const NUMBER_OF_LAYERS = 7

# How many stars are generated.
# Must be between 0.0 and 1.0
const STAR_FREQUENCY = .5 

const WIDTH = 480 # Screen width.
const HEIGHT = 270 # Screen height.
const TILES_X = 10 # Max stars in a row.
const TILES_Y = 10 # Max stars in a column.
const TILE_OFFSET = 5 # Offset for columns and rows.

var random
var r_seed
var layers = []

func _ready():
	random = RandomNumberGenerator.new()
	r_seed = random.seed
	for i in range(NUMBER_OF_LAYERS):
		var layer = ParallaxLayer.new()
		var scale = float(i + 1) / NUMBER_OF_LAYERS
		layer.motion_scale = Vector2(scale, scale)
		layer.z_index = i
		add_child(layer)
		layers.append(layer)
	
func _process(delta):
	for i in range(0, get_child_count()):
		var layer = get_child(i)
		for j in range(0, layer.get_child_count()):
			layer.get_child(j).queue_free()
	random = RandomNumberGenerator.new()
	random.seed = r_seed
	for i in range(0, TILES_X):
		for j in range(0, TILES_Y):
			if (random.randf() < STAR_FREQUENCY):
				var x = (float(i) / TILES_X) * WIDTH + random.randf() * TILES_X * TILE_OFFSET
				x -= WIDTH / 2
				var y = (float(j) / TILES_Y) * HEIGHT + random.randf() * TILES_Y * TILE_OFFSET
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