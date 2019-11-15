extends Node2D

const STAR = preload("res://scenes/star.tscn")
const NUMBER_OF_LAYERS = 2

var random
var layers = []

func _ready():
	random = RandomNumberGenerator.new()
	for i in range(NUMBER_OF_LAYERS):
		var layer = ParallaxLayer.new()
		var scale = float(i) / NUMBER_OF_LAYERS
		layer.motion_scale = Vector2(scale, scale)
		layers.append(layer)
		get_parent().add_child(layer)
		print(get_parent().get_child_count())
	# Test
	create_star(Vector2(50, 50), 0, "res://assets/sprites/megaship.png")
	create_star(Vector2(70, 0), 1, "res://assets/sprites/megaship.png")
	
func create_star(pos, layer, sprite):
	# Vector2 pos: position of the star.
	# int layer: layer index to place the star.
	# String sprite: route of the texture of the star.
	sprite = load(sprite)
	var star = Sprite.new()
	star.position = pos
	star.texture = sprite
	layers[layer].add_child(star)
	print(layers[layer].get_child_count())