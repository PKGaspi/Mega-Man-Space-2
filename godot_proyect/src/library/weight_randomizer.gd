class_name WeightRandomizer
extends Resource

# A dictionary where key is a Variant and value is the weight (int) for
# that Variant to be choosed when get_random_item() is called.
export var items := {}

var total_weight: int = 0

var rng := global.init_random()



func initialize() -> void:
	calculate_total_weight()


func calculate_total_weight() -> void:
	total_weight = 0
	for item in items:
		total_weight += items[item]


func get_random_item():
	# This assumes that total_weight is correctly cached.
	var random_number = rng.randi_range(1, total_weight)
	for item in items:
		random_number -= items[item] # Substract this item's weight.
		if random_number <= 0:
			return item
	return null
