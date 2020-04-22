extends State

export var attacks: Resource = WeightRandomizer.new()


func _ready() -> void:
	assert(attacks is WeightRandomizer)
	attacks.initialize()


func enter(msg: Dictionary = {}) -> void:
	_state_machine.transition_to(attacks.get_random_item())
