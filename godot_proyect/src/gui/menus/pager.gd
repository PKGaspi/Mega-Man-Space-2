extends Control

var pages = []
var n_pages : int = 0
export(int) var page_index : int = 0
var current_page : Node

func _ready() -> void:
	# Add pages.
	for child in get_children():
		child.visible = false
		pages.append(child)
		n_pages += 1
	
	# Set valid current page.
# warning-ignore:narrowing_conversion
	page_index = clamp(page_index, 0, n_pages - 1)
	pages[page_index].visible = true
	current_page = pages[page_index]

func set_page(value : int) -> void:
	pages[page_index].visible = false
# warning-ignore:narrowing_conversion
	page_index = clamp(value, 0, n_pages - 1)
	pages[page_index].visible = true
	current_page = pages[page_index]

func next_page() -> void:
	set_page((page_index + 1) % n_pages)
