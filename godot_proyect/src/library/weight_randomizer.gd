class_name WeightRandomizer
extends Resource

# A dictionary where key is a Variant and value is the weight (int) for
# that Variant to be choosed when get_random_item() is called.
export(Array) var items := []
export(Array, int) var weights := []

var total_weight: int = 0

var rng := global.init_random()



func initialize() -> void:
	assert(len(items) == len(weights))
	calculate_total_weight()


func calculate_total_weight() -> void:
	total_weight = 0
	for weight in weights:
		total_weight += weight

# This returns a variant.
func get_random_item():
	# This assumes that total_weight is correctly cached.
	var random_number = rng.randi_range(1, total_weight)
	for i in range(len(items)):
		random_number -= weights[i] # Substract this item's weight.
		if random_number <= 0:
			return items[i]
	return null
