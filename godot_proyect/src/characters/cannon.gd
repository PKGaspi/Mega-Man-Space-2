extends Position2D

export var projectile: PackedScene # What to shoot.
export var max_projectiles: int = 3 # Max number of projectiles at once on the screen.

onready var _shooting_cd_timer := $ShootingCDTimer
var n_projectiles: int = 0 # Current number of projectiles on screen.


func _on_projectile_tree_exiting() -> void:
	n_projectiles -= 1


func shoot() -> void:
	if n_projectiles >= max_projectiles or not _shooting_cd_timer.is_stopped():
		return
		
	var inst = projectile.instance()
	inst.global_position = global_position
	inst.global_rotation = global_rotation
	inst.connect("tree_exited", self, "_on_projectile_tree_exiting")
	
	ObjectRegistry.register_projectile(inst)
	n_projectiles += 1
	
	_shooting_cd_timer.start()

