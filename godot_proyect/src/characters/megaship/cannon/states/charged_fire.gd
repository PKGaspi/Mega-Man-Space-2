extends CannonState

var charging_fases: int
var charging_time: float
var charging_timer: Timer


func _ready() -> void:
	charging_timer = Timer.new()
	charging_timer.one_shot = true
	add_child(charging_timer)


func input(event: InputEvent) -> void:
	# This doesn't take cd into account. It assumes that cannons does for now.
	if event.is_action_pressed("shoot"):
		charging_timer.start()
	if event.is_action_released("shoot"):
		var time_left = charging_timer.time_left
		charging_timer.stop()
		var power = floor(lerp(0, charging_fases, (charging_time - time_left) / charging_time ))
		cannons.fire(power)
