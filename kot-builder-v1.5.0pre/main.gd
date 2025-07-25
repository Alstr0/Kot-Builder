extends Node2D

var tool_mode:= false
var playing := false
var door_placed := false
var big := false
var tool:= 0

@onready var door := %Door
const srt = preload("res://simple_rotateable_trap.tscn")
const platform = preload("res://boards/platform.tscn")
const trampoline = preload("res://boards/trampoline.tscn")
const thief = preload("res://thief/thief.tscn")
const saw = preload("res://traps/saw.tscn")
const gravity = preload("res://gravity.tscn")
const cannon = preload("res://traps/cannon.tscn")
const yellow_orb = preload("res://orbs/yellow_orb.tscn")
const red_orb = preload("res://orbs/red_orb.tscn")
const blue_orb = preload("res://orbs/blue_orb.tscn")
const green_orb = preload("res://orbs/green_orb.tscn")
const stone = preload("res://mini_blocks/stone.tscn")
const cobblestone = preload("res://mini_blocks/cobblestone.tscn")
const gravel = preload("res://mini_blocks/gravel.tscn")
const pickaxe = preload("res://items/pickaxe.tscn")
const force = preload("res://mini_blocks/force.tscn")
const homing_cannon = preload("res://traps/homing_cannon.tscn")
const red_guard = preload("res://traps/red_guard.tscn")
const fly = preload("res://traps/fly.tscn")
const blue_guard = preload("res://traps/blue_guard.tscn")
const warder = preload("res://traps/warder.tscn")
const spider = preload("res://traps/spider.tscn")
const ricochet = preload("res://traps/ricochet.tscn")
const e_cannon = preload("res://traps/e_cannon.tscn")
const bloodhound = preload("res://traps/bloodhound.tscn")

var player
var small_grid := false
var is_deleted_tool := false
var spawn := false
var first_time := true
var spawn_offset := Vector2(6.0, -68.8)

var zoom := Vector2(0.7, 0.7)
var play_zoom := Vector2(0.9, 0.9)
var big_zoom := Vector2(0.625 ,0.625)
var big_play_zoom := Vector2(0.775 ,0.775)
var view_zoom := Vector2(1, 1)
var big_view_zoom := Vector2(0.825, 0.825)

var trail_lenght := 2
const child_count := 7
var cobblestone_durability := 2
var pickaxe_durability := 2
var sticking := 292.4828
var light_force := 1.1
var heavy_force := 2.0
var gravel_collision_area := 20
var can_gravel_push_gravel := true
var roaster
var roaster_speed := 1.8
var roaster_time_left := 1.8
var web := 0
var web_speed := 4.5 # 6
var show_web_bar := true
var merge_fly := true # Add to Options
var no_view := true
var change_view := true

var set_end_point := false
var get_end_point 

func _process(delta: float) -> void:
	var pos := get_global_mouse_position()
	var tpos := pos
	is_deleted_tool = false
	if Input.is_action_just_pressed("ui_cancel"):
		if playing:
			kill()
		elif spawn: end_test()
		else: get_tree().quit()
	
	
	if roaster:
		%LabelRoaster.get_child(0).value = roaster_time_left * 100
		%LabelRoaster.get_child(0).max_value = roaster_speed * 100
	
	if web:
		if show_web_bar:
			%LabelWeb.visible = true
		else:
			%LabelWeb.visible = false
		if player != null:
			%LabelWeb.get_child(0).value = player.web_timer.time_left * 100
			%LabelWeb.get_child(0).max_value = player.web_timer.wait_time * 100
	else:
		%LabelWeb.visible = false
	
	if Input.is_action_just_pressed("click") and not playing and spawn and not first_time:
		spawn_player()
	
	elif Input.is_action_just_released("click"):
		change_view = true
	elif Input.is_action_just_pressed("click") and not no_view and change_view:
		if Input.is_action_pressed("click") and not no_view:
			view()
	
	elif Input.is_action_just_pressed("click") and tool_mode:
		if big:
			if pos.x > 1520 or pos.y > 845:
				pos.x = -1000
			if tpos.x > 1552 or tpos.y > 915:
				tpos.x = -1000
		else:
			if pos.x > 1180 or pos.y > 715:
				pos.x = -1000
			if tpos.x > 1180 or tpos.y > 675:  # 750   #850-170 = 680 
				tpos.x = -1000
		if pos >= pos.abs() and tpos.x != -1000:
			if small_grid:
				pos = Vector2i((Vector2(pos)+Vector2(21.125,21.125))/42.25)*42.25
				tpos = Vector2i((Vector2(tpos)+Vector2(-21.125, 0))/42.25)*42.25
			else:
				pos = Vector2i((Vector2(pos)+Vector2(42.25,42.25))/84.5)*84.5
				tpos = Vector2i((Vector2(tpos)+Vector2(0, 0))/84.5)*84.5
			if set_end_point == true:
				if get_end_point != null:
					get_end_point.end_point(tpos + Vector2(42.25, 42.25))
					set_end_point = false
					%LabelEndPoint.visible = false
				else:
					set_end_point = false
					%LabelEndPoint.visible = false
			else:
				for i in range(child_count, get_child_count()):
					if "sphere" in get_child(i):
						if get_child(i).sphere.global_position == tpos + Vector2(42.25, 42.25):
							set_end_point = true
							get_end_point = get_child(i)
							%LabelEndPoint.visible = true
				if set_end_point == false:
					match tool:
						0:  		# Door
							if door.position == pos and door.visible == true:
								door.visible = false
								door_placed = false
								%Play.visible = false
								%View.visible = true
							else:
								door.position = pos
								door.visible = true
								door_placed = true
								%Play.visible = true
								%View.visible = false
						1:  		# Totem / Chest
							if %Totem.position == pos and %Totem.visible == true:
								%Totem.visible = false
							else:
								%Totem.position = pos
								%Totem.visible = true
						2:  		# Platform
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("platform") and get_child(i).position == pos:
									get_child(i).input()
									is_deleted_tool = true
								elif get_child(i).is_in_group("trampoline") and get_child(i).position == pos:
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool== false:
								var instance = platform.instantiate()
								instance.position = pos
								add_child(instance)
							else:
								is_deleted_tool= false
						3:  		# Trampoline
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("trampoline") and get_child(i).position == pos:
									get_child(i).input()
									is_deleted_tool = true
								elif get_child(i).is_in_group("platform") and get_child(i).position == pos:
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = trampoline.instantiate()
								instance.position = pos
								add_child(instance)
							else:
								is_deleted_tool= false
						4:  		# Gravity
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("gravity") and get_child(i).position == pos:
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = gravity.instantiate()
								instance.position = pos
								add_child(instance)
							else:
								is_deleted_tool = false
						5:  		# Saw
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("saw") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = saw.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
	
	
						8:  		# Cannon
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("cannon") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).rotating()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := cannon.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						9:  		# Homing Cannon
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("homing_cannon") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = homing_cannon.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						10: 		# Red Guard
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("red_guard") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = red_guard.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						11: 		# Blue Guard
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("blue_guard") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = blue_guard.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						12: 		# Fly
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("fly") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = fly.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.merge = merge_fly
								add_child(instance)
							else:
								is_deleted_tool= false
						13: 		# Dragon
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("dragon") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).rotating()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := srt.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.add_to_group("dragon")
								instance.texture = preload("res://traps/dragon.png")
								add_child(instance)
							else:
								is_deleted_tool= false
	
	
						16: 		# Electro Cannon
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("ecannon") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).rotating()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := e_cannon.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						17: 		# Ricochet
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("ricochet") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).rotating()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := ricochet.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						18: 		# Warder
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("warder") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).rotating()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = warder.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								add_child(instance)
							else:
								is_deleted_tool= false
						19: 		# Bloodhound
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("bloodhound") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).rotating()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := bloodhound.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.scale = Vector2(0.75, 0.75)
								add_child(instance)
							else:
								is_deleted_tool= false
						20: 		# Spider
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("spider") and get_child(i).position == pos:
									get_child(i).queue_free()
									is_deleted_tool = true
									web -= 1
									if web == 0:
										%LabelWeb.visible = true
							if is_deleted_tool == false:
								var instance := spider.instantiate()
								instance.position = pos
								add_child(instance)
								web += 1
							else:
								is_deleted_tool= false
						21: 		# Roaster
							if roaster != null:
								if roaster.position == tpos + Vector2(42.25, 42.25):
									roaster.queue_free()
									%LabelRoaster.visible = false
									is_deleted_tool = true
								else:
									roaster.position = tpos + Vector2(42.25, 42.25)
							else:
								var instance := srt.instantiate()
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.scale = Vector2(1.1, 1.1)
								instance.z_index = 1280
								instance.add_to_group("roaster")
								roaster = instance
								%LabelRoaster.visible = true
								instance.texture = preload("res://traps/roaster.png")
								add_child(instance)
								is_deleted_tool= false
	
	
						24: 		# Yellow Orb
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("orb") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = yellow_orb.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
						25: 		# Red Orb
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("orb") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = red_orb.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
						26: 		# Blue Orb
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("orb") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = blue_orb.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
						27: 		# Green Orb
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("orb") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = green_orb.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
						28: 		# Stone
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("block") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = stone.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
						29: 		# Cobblestone
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("block") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = cobblestone.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.change_durability(cobblestone_durability)
	
	
						32: 		# Gravel
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("block") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = gravel.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.pos = instance.position
						33: 		# Pickaxe
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("item") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									get_child(i).queue_free()
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance = pickaxe.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.pickaxe_durability = pickaxe_durability
						34: 		# Force Light
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("force") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									if not get_child(i).mega:
										get_child(i).rotating()
									else:
										get_child(i).swap_mod(light_force)
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := force.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.sprite.self_modulate = instance.color1
								instance.mega = false
								instance.force = light_force
								
								var current_frame
								var current_progress
								for j in range(child_count, get_child_count()):
									if get_child(j).is_in_group("force"):
										current_frame = get_child(j).sprite.get_frame()
										current_progress = get_child(j).sprite.get_frame_progress()
										break
								instance.sprite.set_frame_and_progress(current_frame, current_progress)
							else:
								is_deleted_tool= false
						35: 		# Force Heavy
							for i in range(child_count, get_child_count()):
								if get_child(i).is_in_group("force") and get_child(i).position == tpos + Vector2(42.25, 42.25):
									if get_child(i).mega:
										get_child(i).rotating()
									else:
										get_child(i).swap_mod(heavy_force)
									is_deleted_tool = true
							if is_deleted_tool == false:
								var instance := force.instantiate()
								add_child(instance)
								instance.position = tpos + Vector2(42.25, 42.25)
								instance.mega = true
								instance.sprite.self_modulate = instance.color2
								instance.force = heavy_force
								
								var current_frame
								var current_progress
								for j in range(child_count, get_child_count()):
									if get_child(j).is_in_group("force"):
										current_frame = get_child(j).sprite.get_frame()
										current_progress = get_child(j).sprite.get_frame_progress()
										break
								instance.sprite.set_frame_and_progress(current_frame, current_progress)
							else:
								is_deleted_tool= false
	
	if spawn:
		first_time = false



func _on_button_button_down() -> void:
	swap_mod()

func swap_mod() -> void:
	tool_mode = not tool_mode
	if tool_mode:
		%Button.text = "TOOL\nMODE"
		%TileMap.is_block_mode = false
		%Block.visible = false
		%Tool.visible = true
	else:
		%Button.text = "BLOCK\nMODE"
		%TileMap.is_block_mode = true
		%Block.visible = true
		%Tool.visible = false
		if door_placed:
			%Play.visible = true


func _on_tool_opinion_1_item_selected(index: int) -> void:
	tool = index
	if index == 6:
		%OpinionTool1.visible = false
		%OpinionExtra2.visible = true
	if index == 7:
		%OpinionTool1.visible = false
		%OpinionTool2.visible = true

func _on_tool_opinion_2_item_selected(index: int) -> void:
	tool = index + 8
	if index == 6:
		%OpinionTool2.visible = false
		%OpinionTool1.visible = true
	if index == 7:
		%OpinionTool2.visible = false
		%OpinionTool3.visible = true

func _on_opinion_tool_3_item_selected(index: int) -> void:
	tool = index + (8 * 2) 
	if index == 6:
		%OpinionTool3.visible = false
		%OpinionTool2.visible = true
	if index == 7:
		%OpinionTool3.visible = false
		%OpinionExtra1.visible = true

func _on_opinion_2_item_selected(index: int) -> void:  # EXTRA 1
	tool = index + (8 * 3)
	if index == 6:
		%OpinionExtra1.visible = false
		%OpinionTool3.visible = true
	if index == 7:
		%OpinionExtra1.visible = false
		%OpinionExtra2.visible = true

func _on_opinion_3_item_selected(index: int) -> void:  # EXTRA 2
	tool = index + (8 * 4)
	if index == 6:
		%OpinionExtra2.visible = false
		%OpinionExtra1.visible = true
	if index == 7:
		%OpinionExtra2.visible = false
		%OpinionTool1.visible = true



func _on_restart_button_down() -> void:
	get_tree().reload_current_scene()

func _on_play_button_down() -> void:
	play_mode()

func _on_stop_button_down() -> void:
	kill()



func play_mode() -> void:
	if player != null: player.queue_free()
	spawn = true
	%SpawnThief.visible = true
	first_time = true
	%TileMap.is_block_mode = false
	%Block.visible = false
	%Button.visible = false
	%Stop.visible = true
	roaster = null
	web = 0
	%LabelRoaster.visible = false
	%LabelWeb.visible = false
	for i in range(child_count, get_child_count()):
		if get_child(i).is_in_group("spider"):
			web += 1
			%LabelWeb.visible = true
		if get_child(i).is_in_group("roaster"):
			roaster = get_child(i)
			%LabelRoaster.visible = true
	if big:
		%Camera.zoom = big_play_zoom
	else:
		%Camera.zoom = play_zoom

func _on_view_button_down() -> void:
	view()

func view() -> void:
	no_view = not no_view
	change_view = false
	if no_view:
		%TileMap.is_block_mode = true
		%Block.visible = true
		%Button.visible = true
		if big:
			%Camera.zoom = big_zoom
			%Camera.position.x = 775
		else:
			%Camera.zoom = zoom
			%Camera.position.x = 620
	else:
		%TileMap.is_block_mode = false
		%Block.visible = false
		%Button.visible = false
		if big:
			%Camera.zoom = big_view_zoom
			%Camera.position.x = 770
		else:
			%Camera.zoom = view_zoom
			%Camera.position.x = 590

func kill() -> void:
	if player != null: player.queue_free()
	for i in range(child_count, get_child_count()):
		if get_child(i).is_in_group("gravity"):
			get_child(i).sprite1.visible = true
			get_child(i).sprite2.visible = false
			get_child(i).rotation_degrees = 0
		elif get_child(i).has_method("replay"):
			await get_child(i).replay()
			if get_child(i).is_in_group("gravel"):
				var instance = gravel.instantiate()
				add_child(instance)
				instance.position = get_child(i).pos
				instance.pos = get_child(i).pos
				get_child(i).queue_free()
			roaster = null
	if playing:
		playing = false
		first_time = true
		%SpawnThief.visible = true
	else:
		%SpawnThief.visible = false
		end_test()

func end_test() -> void:
	spawn = false
	%Camera.get_child(0).visible = false
	if tool_mode == false:
		%TileMap.is_block_mode = true
		%Stop.visible = false
		%Block.visible = true
		%Button.visible = true
		for i in range(child_count, get_child_count()):
			if get_child(i).is_in_group("gravity"):
				get_child(i).sprite1.visible = true
				get_child(i).sprite2.visible = false
				get_child(i).rotation_degrees = 0
	if big:
		%Camera.zoom = big_zoom
	else:
		%Camera.zoom = zoom


func _on_options_button_down() -> void:
	%TileMap.is_block_mode = false
	%Camera.get_child(0).visible = true
	%Block.visible = false
	%Other.visible = false


func _on_zoom_slider_value_changed(value: float) -> void:
	var zoom_value = lerpf(0.55, 0.85, value)
	zoom = Vector2(zoom_value, zoom_value)
	
	play_zoom = zoom + Vector2(0.2, 0.2)
	big_zoom = zoom * 0.8
	big_play_zoom = big_zoom + Vector2(0.15, 0.15)
	view_zoom = play_zoom + Vector2(0.1, 0.1)
	big_view_zoom = big_play_zoom + Vector2(0.05, 0.05)
	
	if big:
		%Camera.zoom = big_zoom
	else:
		%Camera.zoom = zoom

func _on_slider_trail_value_changed(value: int) -> void:
	trail_lenght = int(value)
	if trail_lenght != 0:
		%LabelTrail.text = str("Trail lenght is ", trail_lenght, " unit")
	else:
		%LabelTrail.text = str("Trail is OFF")

func _on_slider_cobblestone_value_changed(value: int) -> void:
	cobblestone_durability = value
	%LabelCobblestone.text = str("Cobblestone Dur ", cobblestone_durability, "")
	for i in range(child_count, get_child_count()):
		if get_child(i).is_in_group("block") and get_child(i).has_method("change_durability"):
			get_child(i).change_durability(cobblestone_durability)

func _on_slider_pickaxe_durability_value_changed(value: int) -> void:
	pickaxe_durability = value
	if value == 7:
		pickaxe_durability = 32000
	
	if value == 7:
		%LabelPickaxeDurability.text = "Infinite Pickaxe Dur"
	else:
		%LabelPickaxeDurability.text =  str("Pickaxe Durability ", pickaxe_durability, "")


func _on_gravel_button_down() -> void:
	gravel_collision_area += 4
	if gravel_collision_area == 36: gravel_collision_area = 20
	%ButtonGravel.text = str("Gravel Collision  = ", gravel_collision_area, "")

func _on_gravel_push_button_down() -> void:
	can_gravel_push_gravel = not can_gravel_push_gravel
	if can_gravel_push_gravel:
		%ButtonGravelPush.text = "Gravel CAN push Gravel"
	else:
		%ButtonGravelPush.text = "Gravel CAN'T push Gravel"

func _on_cobblestone_button_down() -> void:
	cobblestone_durability += 1
	if cobblestone_durability == 5: cobblestone_durability = 1
	%ButtonCobblestone.text = str("Cobblestone Dur ", cobblestone_durability, "")

func _on_sticking_button_down() -> void:
	if sticking == 292.4828:
		sticking = 270
	else:
		sticking = 292.4828
	%ButtonSticking.text = str("Velocity to Jump [", int(sticking), "]")

func _on_light_force_button_down() -> void:
	if light_force == 1.1:
		light_force = 1.2
	elif light_force == 1.2:
		light_force = 1.4
	#elif light_force == 1.3:
	#	light_force = 1.4
	elif light_force == 1.4:
		light_force = 1.1
	%ButtonLightForce.text = str("Light Force [", float(light_force), "]")

func _on_heavy_force_button_down() -> void:
	if heavy_force == 1.5:
		heavy_force = 2.0
		%ButtonHeavyForce.text = str("Heavy Force [2.0]")
	elif heavy_force == 2.0:
		heavy_force = 2.5
		%ButtonHeavyForce.text = str("Heavy Force [2.5]")
	elif heavy_force == 2.5:
		heavy_force = 1.5
		%ButtonHeavyForce.text = str("Heavy Force [1.5]")

func _on_roaster_button_down() -> void:
	if roaster_speed != 1.0:
		roaster_speed -= 0.5
	else:
		roaster_speed = 2.0
	
	roaster_time_left = roaster_speed
	
	if roaster_speed == 2.0: %ButtonRoaster.text = str("Roaster Speed [x1.0]")
	elif roaster_speed == 1.5: %ButtonRoaster.text = str("Roaster Speed [x1.5]")
	elif roaster_speed == 1.0: %ButtonRoaster.text = str("Roaster Speed [x2.0]")

func _on_button_web_button_down() -> void:
	if  web_speed == 4.5:
		web_speed = 3.0
	elif web_speed == 3.0:
		web_speed = 2.0
	elif web_speed == 2.0:
		web_speed = 4000000
		show_web_bar = false
	elif web_speed == 4000000:
		web_speed = 8.0
		show_web_bar = true
	elif web_speed == 8.0:
		web_speed = 6.0
	elif web_speed == 6.0:
		web_speed = 4.5
		
	if web_speed == 4.0: %ButtonWeb.text = str("Spider Speed [x1.0]")
	elif web_speed == 3.0: %ButtonWeb.text = str("Spider Speed [x1.5]")
	elif web_speed == 2.0: %ButtonWeb.text = str("Spider Speed [x2.0]")
	elif web_speed == 4000000: %ButtonWeb.text = str("Spider Speed [x0.0]")
	elif web_speed == 8.0: %ButtonWeb.text = str("Spider Speed [x0.5]")
	elif web_speed == 6.0: %ButtonWeb.text = str("Spider Speed [x0.75]")


func _on_save_options_button_down() -> void:
	%Camera.get_child(0).visible = false
	%Block.visible = true
	%Other.visible = true
	%TileMap.is_block_mode = true
	if door_placed:
		%Play.visible = true
	
	for i in range(child_count, get_child_count()): 	# Set Gravel 
		if get_child(i).is_in_group("block") and ("area" in get_child(i)):
			get_child(i).area = gravel_collision_area
	for i in range(child_count, get_child_count()): 	# Set Light Force
		if get_child(i).is_in_group("force"):
			if get_child(i).force <= 1.4:
				get_child(i).force = light_force
	for i in range(child_count, get_child_count()): 	# Set Heavy Force
		if get_child(i).is_in_group("force"):
			if get_child(i).force >= 1.5:
				get_child(i).force = heavy_force
	for i in range(child_count, get_child_count()): 	# Set Pickaxe Durability
		if get_child(i).is_in_group("item"):
			get_child(i).pickaxe_durability = pickaxe_durability
	for i in range(child_count, get_child_count()): 	# Set Cobblestone Durability
		if get_child(i).is_in_group("block") and get_child(i).has_method("change_durability"):
			get_child(i).change_durability(cobblestone_durability)

func _on_reset_options_button_down() -> void:
	%SliderPos.value = 0.5
	%SliderZoom.value = 0.5
	%SliderTrail.value = 2
	%SliderCobblestone.value = 2
	%SliderPickaxeDurability.value = 5
	light_force = 1.4
	%ButtonLightForce.emit_signal("button_down")
	heavy_force = 1.5
	%ButtonHeavyForce.emit_signal("button_down")
	can_gravel_push_gravel = false
	%ButtonGravelPush.emit_signal("button_down")
	roaster_speed = 1.0
	%ButtonRoaster.emit_signal("button_down")
	web_speed = 2.0
	%ButtonWeb.emit_signal("button_down")



func _on_grid_button_button_down() -> void:
	if small_grid:
		%GridButton.text = "SMALL\nGRID OFF"
		%GridButton.self_modulate = "ff0000"
		small_grid = false
	else:
		%GridButton.text = "SMALL\nGRID ON"
		%GridButton.self_modulate = "00ff00"
		small_grid = true


func _on_undo_button_down() -> void:
	if get_child_count() > child_count:
		get_child(get_child_count()-1).queue_free()

func _on_size_button_down() -> void:
	big = not big
	if big == true:
		%Size.text = "SWITCH\nTO MINI"
		%BG.scale = Vector2(0, 0)
		%BIG_BG.visible = true
		%TileMap.big = true
		%Camera.zoom = big_zoom
		%Camera.position = Vector2(775, 425)
		%Right.disabled = true
		%Bottom.disabled = true
		%OpinionTool1.position.x = 1850
		%OpinionTool2.position.x = 1850
		%OpinionTool3.position.x = 1850
		%OpinionExtra1.position.x = 1850
		%OpinionExtra2.position.x = 1850
	else:
		%Size.text = "SWITCH\nTO BIG"
		%BG.scale = Vector2(1, 1)
		%BIG_BG.visible = false
		%TileMap.big = false
		%Camera.zoom = zoom
		%Camera.position = Vector2(620, 340)
		%Bottom.disabled = false
		%Right.disabled = false
		%OpinionTool1.position.x = 1542
		%OpinionTool2.position.x = 1542
		%OpinionTool3.position.x = 1542
		%OpinionExtra1.position.x = 1542
		%OpinionExtra2.position.x = 1542


func rotate_gravity() -> void:
	for i in range(child_count, get_child_count()):
		if get_child(i).is_in_group("gravity") and get_child(i).sprite1.visible:
			get_child(i).rotation_degrees += 180

func spawn_player() -> void:
	if player != null: player.queue_free()
	player = thief.instantiate()
	player.is_first_time = false
	add_child(player)
	player.position = door.position - spawn_offset
	player.pickaxe_durability = pickaxe_durability
	player.wj_vel = -sticking
	playing = true
	
	for i in range(child_count, get_child_count()):
		if get_child(i).is_in_group("gravity"):
			get_child(i).sprite1.visible = true
			get_child(i).rotation_degrees = 0
			
	
	if web:
		player.web_timer.wait_time = web_speed
	if roaster != null:
		player.roaster = true
		player.roaster_timer.wait_time = roaster_speed
	elif roaster == null:
		player.roaster = false
	if trail_lenght != 0:
		player.particles.emitting = true
		player.particles.amount =  8 * trail_lenght
		player.particles.lifetime = 0.1 * trail_lenght
	else:
		player.particles.emitting = false
	first_time = false
	%SpawnThief.visible = false
