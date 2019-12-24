extends Range

export(SpriteFrames) var cell_masks = null
export(SpriteFrames) var cell_palettes = null
var cell_texture	: Texture
var separation		: int
var size			: Vector2
var cell_size		: Vector2
var position		: Vector2

func init(cell_size, position, max_value, min_value = 0, value = max_value) -> void:
	
	self.cell_texture = global.create_empty_image(cell_size)
	self.position = position
	self.max_value = max_value
	self.min_value = min_value
	self.value = value
	
	# Color palette shader setup.
	material = material.duplicate(true)
	set_mask(0)
	set_palette(0)
	
	separation = 0 # Separation between cells.
	margin_top = 0
	margin_bottom = 0
	margin_left = 0
	margin_right = 0
	
	self.cell_size = cell_size
	calculate_size()


func _draw():
	for child in get_children():
		child.queue_free()
	# Draw full cells.
	set_mask(0)
	for i in range(value):
		create_cell(Vector2(position.x + margin_left, position.y + size.y - (cell_size.y + separation) * i - margin_bottom - separation))
	# Draw empty cells.
	set_mask(1)
	for i in range(value, max_value):
		create_cell(Vector2(position.x + margin_left, position.y + size.y - (cell_size.y + separation) * i - margin_bottom - separation))

func create_cell(position):
	var spr = Sprite.new()
	spr.material = material.duplicate(true)
	spr.texture = cell_texture
	spr.position = position
	add_child(spr)

func update_values(new_value, new_max_value):
	max_value = new_max_value
	value = new_value
	calculate_size()
	update()
	
func set_palette(new_palette) -> void:
	material.set_shader_param("palette", cell_palettes.get_frame("default", new_palette))
	update()
	
func set_mask(new_mask) -> void:
	material.set_shader_param("mask", cell_masks.get_frame("default", new_mask))
	
func calculate_size():
	size = Vector2(cell_size.x + margin_left + margin_right, (cell_size.y + separation) * max_value - separation + margin_top + margin_bottom)