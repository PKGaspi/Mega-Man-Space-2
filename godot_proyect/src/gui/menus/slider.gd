class_name gspSlider
extends Control



onready var slider = $Slider


func set_max_value(new_max_value: float) -> void:
	slider.max_value = new_max_value


func set_min_value(new_min_value: float) -> void:
	slider.min_value = new_min_value


func set_value(new_value: float) -> void:
	slider.value = new_value


func get_value() -> float:
	return slider.value


func set_ratio(new_ratio: float) -> void:
	slider.ratio = new_ratio


func get_ratio() -> float:
	return slider.ratio


func add_step() -> bool:
	if get_ratio() == 1:
		return false
	
	slider.value += slider.step
	return true


func substract_step() -> bool:
	if get_ratio() == 0:
		return false
	
	slider.value -= slider.step
	return true
