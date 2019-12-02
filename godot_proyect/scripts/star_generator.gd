extends ParallaxBackground

const NUMBER_OF_LAYERS = 7
const WIDTH = 480
const HEIGHT = 270
const TILES_X = 30
const TILES_Y = 30

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
			if (random.randf() < .1):
				var x = (float(i) / TILES_X) * WIDTH
				var y = (float(j) / TILES_Y) * HEIGHT
				create_star(Vector2(x, y), 2, "res://assets/sprites/megaship.png")

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