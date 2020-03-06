extends Control

export(Array, NodePath) var pages = []
export var page_index: int = 0 setget set_page
var current_page: Node

func _ready() -> void:
	set_page(page_index)

func set_page(value : int) -> void:
	get_node(pages[page_index]).visible = false
# warning-ignore:narrowing_conversion
	page_index = clamp(value, 0, len(pages) - 1)
	get_node(pages[page_index]).visible = true
	current_page = get_node(pages[page_index])

func next_page() -> void:
	set_page((page_index + 1) % len(pages))

func previous_page() -> void:
	set_page((page_index - 1) if page_index > 0 else len(pages) - 1)
