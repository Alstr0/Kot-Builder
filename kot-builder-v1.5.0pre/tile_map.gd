extends TileMapLayer

var tile: Vector2i
var is_block_mode := true #just for delay
var block_mode := true
var big := false

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not is_block_mode:
		block_mode = false
	
	if Input.is_action_just_pressed("click") and block_mode:
		tile = Vector2i(get_global_mouse_position()/169)
		if big and tile.x < 9 and tile.y < 5 and get_global_mouse_position() > Vector2(42.125, 0):
			if get_cell_source_id(tile) == 1:
				set_cell(tile, 0, Vector2(tile.x%7, tile.y%4))
			else:
				set_cell(tile, 1, Vector2i(0, 0))
		elif not big and get_global_mouse_position() > Vector2(0, 0):
			if get_cell_source_id(tile) == 1:
				set_cell(tile, 0, tile)
			else:
				set_cell(tile, 1, Vector2i(0, 0))
	
	if is_block_mode:
		block_mode = true
		if big: 	# Setting up "Air"s
			for i in range(0, 4):
				set_cell(Vector2i(7, i), 1, Vector2i(0, 0))
				set_cell(Vector2i(8, i), 1, Vector2i(0, 0))
			for i in range(0, 9):
				set_cell(Vector2i(i, 4), 1, Vector2i(0, 0))
			set_cell(Vector2i(7, -1))
			set_cell(Vector2i(-1, 4))
			set_cell(Vector2i(9, -1), 1, Vector2i(0, 0))
			set_cell(Vector2i(-1, 5), 1, Vector2i(0, 0))
			set_cell(Vector2i(9, 5), 1, Vector2i(0, 0))
		else:
			for i in range(0, 4):
				set_cell(Vector2i(7, i))
				set_cell(Vector2i(8, i))
			for i in range(0, 9):
				set_cell(Vector2i(i, 4))
			set_cell(Vector2i(7, -1), 1, Vector2i(0, 0))
			set_cell(Vector2i(-1, 4), 1, Vector2i(0, 0))
			set_cell(Vector2i(7, 4), 1, Vector2i(0, 0))
			set_cell(Vector2i(9, -1))
			set_cell(Vector2i(-1, 5))
			set_cell(Vector2i(9, 5))
