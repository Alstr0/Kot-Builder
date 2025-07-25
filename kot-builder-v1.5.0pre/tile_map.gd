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
			if get_cell_source_id(tile) == -1:
				set_cell(tile, 0, Vector2(tile.x%7, tile.y%4))
			else:
				set_cell(tile, -1)
		elif not big and get_global_mouse_position() > Vector2(8, 0):
			if get_cell_source_id(tile) == -1:
				set_cell(tile, 0, tile)
			else:
				set_cell(tile, -1)
	
	if is_block_mode:
		block_mode = true
