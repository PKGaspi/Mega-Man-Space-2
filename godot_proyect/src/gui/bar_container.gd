extends Control


const TILED_PROGRESS = preload("res://src/gui/tiled_progress.tscn")

var n_boss_bars = 0

func _ready() -> void:
	pass


func new_boss_bar(max_value: float, value: float, palette: int) -> TiledProgress:
	var bar = TILED_PROGRESS.instance()
	
	bar.anchor_left = 1.0
	bar.margin_left = -23 - (bar.cell_size.x * (n_boss_bars + 1))
	bar.margin_top = 24
	
	bar.max_value = max_value
	bar.value = value
	bar.palette = palette
	bar.cells_per_step = 4
	bar.name = "BossHpBar%d" % n_boss_bars
	
	bar.connect("tree_exited", self, "_on_boss_bar_tree_exited")
	add_child(bar)
	n_boss_bars += 1
	return bar


func _on_boss_bar_tree_exited() -> void:
	n_boss_bars -= 1
	# Reorganize all boss hp bars.
	var i := 0
	for child in get_children():
		if child is TiledProgress and child.name.substr(0, 4) != "Mega":
			child.margin_left = -23 - (child.cell_size.x * (i + 1))
			child.update_values()
			i += 1
			
