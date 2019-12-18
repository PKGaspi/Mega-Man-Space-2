extends Range

var cell_texture	: Texture
var separation		: int
var size			: Vector2
var cell_size		: Vector2
var bar_rect		: Rect2
var position		: Vector2

var bg_color = Color("202020")

	
func init(cell_texture, position, max_value, min_value = 0, value = max_value) -> void:
	self.cell_texture = cell_texture
	self.position = position
	self.max_value = max_value
	self.min_value = min_value
	self.value = value
	
	separation = 1 # Separation between cells.
	margin_top = 1
	margin_bottom = 1
	margin_left = 1
	margin_right = 1
	
	cell_size = cell_texture.get_size()
	calculate_rect()


func _draw():
	draw_rect(bar_rect, bg_color)
	for i in range(value):
		draw_texture(cell_texture, Vector2(position.x + margin_left, position.y + size.y - (cell_size.y + separation) * i - margin_bottom - separation))
		
func update_values(new_value, new_max_value):
	value = new_value
	max_value = new_max_value
	calculate_rect()
	
	update()
	
func calculate_rect():
	size = Vector2(cell_size.x + margin_left + margin_right, (cell_size.y + separation) * max_value - separation + margin_top + margin_bottom)
	bar_rect = Rect2(position, size)