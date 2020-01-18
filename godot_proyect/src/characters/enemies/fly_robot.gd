extends "res://src/characters/enemies/enemy.gd"

enum STATES {
	ACCELERATING,
	DEACCELERATING
}

var state = STATES.ACCELERATING

func _ready() -> void:
	print("hola")
	destination = global.MEGASHIP.global_position
	set_palette(0)
	$SprBody.texture = global.create_empty_image(masks.get_frame("body", 0).get_size())
	$SprPropeller.texture = global.create_empty_image(masks.get_frame("propeller", 0).get_size())
	pass

func _process(delta: float) -> void:
	to_follow_on_range = global_position.distance_to(global.MEGASHIP.global_position) <= follow_max_distance
	match state:
		STATES.ACCELERATING:
			acceleration = clamp(acceleration + .4 * delta, 0, 1)
			var distance = global_position.distance_to(destination)
			print(distance)
			if distance <= move_speed * acceleration or !to_follow_on_range:
				follow_destination = false
				state = STATES.DEACCELERATING
		
		STATES.DEACCELERATING:
			var deaccel = .1 if to_follow_on_range else .5
			acceleration = clamp(acceleration - deaccel * delta, 0, 1)
			if acceleration <= 0 and to_follow_on_range:
				follow_destination = true
				destination = global.MEGASHIP.global_position
				dir = global_position.direction_to(destination)
				state = STATES.ACCELERATING
	# Update animation masks.
	$SprBody.material.set_shader_param("mask", $AnimBody.frames.get_frame("body", $AnimBody.frame))
	$SprPropeller.material.set_shader_param("mask", $AnimPropeller.frames.get_frame("propeller", $AnimPropeller.frame))

func set_palette(new_palette : int) -> void:
	$SprBody.material.set_shader_param("palette", palettes.get_frame("default", new_palette))
	$SprPropeller.material.set_shader_param("palette", palettes.get_frame("default", new_palette))
	