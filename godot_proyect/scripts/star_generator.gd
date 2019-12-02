extends ParallaxBackground

const NUMBER_OF_LAYERS = 7

var random
var layers = []

func _ready():
	random = RandomNumberGenerator.new()
	for i in range(NUMBER_OF_LAYERS):
		var layer = ParallaxLayer.new()
		var scale = float(i + 1) / NUMBER_OF_LAYERS
		layer.motion_scale = Vector2(scale, scale)
		layer.z_index = i
		add_child(layer)
		layers.append(layer)
	create_star(Vector2(20, -20), 4, "res://assets/sprites/megaship.png")
	create_star(Vector2(26, -18), 6, "res://assets/sprites/megaship.png")
	create_star(Vector2(12, -22), 5, "res://assets/sprites/megaship.png")
	
func create_star(pos, layer, sprite):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	sprite = load(sprite)
	var star = Sprite.new()
	star.z_index = layers[layer].z_index
	print(star.z_index)
	star.position = pos
	star.texture = sprite
	layers[layer].add_child(star)