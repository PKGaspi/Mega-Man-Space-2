extends ParallaxLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var sprite
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = load(sprite)
	get_node("Sprite").texture = sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
