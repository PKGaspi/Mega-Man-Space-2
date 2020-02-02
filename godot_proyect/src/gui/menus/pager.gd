extends Control

var pages = []
var n_pages = 0
export(int) var page_index : int = 0
var current_page

func _ready() -> void:
	# Add pages.
	for child in get_children():
		child.visible = false
		pages.append(child)
		n_pages += 1
	
	page_index = clamp(page_index, 0, n_pages)
	pages[page_index].visible = true
	current_page = pages[page_index]

func next_page() -> void:
	pages[page_index].visible = false
	page_index += 1
	if page_index >= n_pages:
		page_index = 0
	pages[page_index].visible = true
	current_page = pages[page_index]
