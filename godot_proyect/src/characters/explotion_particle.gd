extends AnimatedPaletteSprite

var angular_speed: float
var velocity: Vector2


func _physics_process(delta: float) -> void:
	move(velocity * delta)
	velocity = velocity.rotated(angular_speed * delta)


func move(ammount: Vector2) -> void:
	global_position += ammount
