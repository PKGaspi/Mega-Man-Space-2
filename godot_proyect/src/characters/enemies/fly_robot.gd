extends "res://src/characters/enemies/enemy.gd"

const PROPELLER_SPEED = 10

enum STATES {
	ACCELERATING,
	DEACCELERATING
}

var state = STATES.ACCELERATING
var original_follow_max_distance

func _ready() -> void:
	destination = to_follow.global_position
	set_palette(int(round(randf())))
	$SprBody.texture = global.create_empty_image(masks.get_frame($AnimBody.animation, 0).get_size())
	$SprPropeller.texture = global.create_empty_image(masks.get_frame($AnimPropeller.animation, 0).get_size())
	original_follow_max_distance = follow_max_distance

func _process(delta: float) -> void:
	to_follow_on_range = is_in_range(to_follow, follow_max_distance)
	match state:
		STATES.ACCELERATING:
			var accel = .5
			acceleration = clamp(acceleration + accel * delta, 0, 1)
			var distance = global_position.distance_to(destination)
			if distance <= move_speed * acceleration / 2 or !to_follow_on_range:
				set_state(STATES.DEACCELERATING)
		STATES.DEACCELERATING:
			var accel = -.7
			acceleration = clamp(acceleration + accel * delta, 0, 1)
			if acceleration <= 0 and to_follow_on_range:
				set_state(STATES.ACCELERATING)
	# Update animation masks.
	$AnimPropeller.speed_scale = acceleration * PROPELLER_SPEED
	$SprBody.material.set_shader_param("mask", $AnimBody.frames.get_frame($AnimBody.animation, $AnimBody.frame))
	$SprPropeller.material.set_shader_param("mask", $AnimPropeller.frames.get_frame($AnimPropeller.animation, $AnimPropeller.frame))

func set_palette(new_palette : int) -> void:
	$SprBody.material.set_shader_param("palette", palettes.get_frame("default", new_palette))
	$SprPropeller.material.set_shader_param("palette", palettes.get_frame("default", new_palette))

func collide(collider):
	.collide(collider)
	set_state(STATES.DEACCELERATING)
	
func set_state(new_state):
	state = new_state
	match state:
		STATES.ACCELERATING:
			dynamic_dir = true
			#destination = to_follow.global_position
			#dir = global_position.direction_to(destination)
			follow_max_distance = -1
			$AnimBody.play("body_charging")
		STATES.DEACCELERATING:
			follow_max_distance = original_follow_max_distance
			dynamic_dir = false
			$AnimBody.play("body_iddle")