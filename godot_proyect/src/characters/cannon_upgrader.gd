extends Node2D

export var n_cannons: int = 1

func fire() -> bool:
	if n_cannons > 0 and n_cannons <= get_child_count():
		return get_child(n_cannons - 1).fire()
	return false
