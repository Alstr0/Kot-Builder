extends Area2D

# Light Force = 1.1
# Mega Force  = 2.0
var force := 1.1
var rotated := 0
var mega := false
var color1 := Color(0.40, 1, 1) 	# Casual Color
var color2 := Color(0.40, 0.42, 1)  # Mega Color
var fall_reduce := 0.9
var fly_push := 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if mega:
		sprite.self_modulate = color2
	else:
		sprite.self_modulate = color1


func swap_mod(swapped_force) -> void:
	force = swapped_force
	mega = not mega
	if mega:
		sprite.self_modulate = color2
	else:
		sprite.self_modulate = color1

func rotating() -> void:
	if rotated == 3:
		queue_free()
	rotated += 1
	rotation_degrees = rotated * 90


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.forces += 1
		body.update_force(force, rotated)
		if body.forces == 1 and force == 2.0: fall_reduce = 0.7
		elif body.forces == 1 and force == 2.5: fall_reduce = 0.625
		elif body.forces == 1 and force == 1.5: fall_reduce = 0.775
		if body.velocity.y > 0 and body.force_boost == 1.0: body.velocity.y *= fall_reduce
		if rotated == 0:
			if not mega: body.force1 += 1
			else: body.mega_force1 += 1
		elif rotated == 2:
			if not mega: body.force2 += 1
			else: body.mega_force2 += 1
	
	elif body.is_in_group("block") and ("interacted" in body):
		body.forces_v += 1
		if rotated == 1 and body.gravel_gravity < force:
			body.gravel_gravity = force * 2
		if rotated == 3:
			body.gravel_gravity = 0.2 / force
		
		if rotated == 0:
			body.forces_h += force * 100
		if rotated == 2:
			body.forces_h -= force * 100
	
	elif body.is_in_group("fly"): #elif "force_velocity" in body:
		if rotated == 0:   body.force_velocity.x += (fly_push / 2) * (force * 1)
		elif rotated == 1: body.force_velocity.y += (fly_push / 2) * (force * 1)
		elif rotated == 2: body.force_velocity.x -= (fly_push / 2) * (force * 1)
		elif rotated == 3: body.force_velocity.y -= (fly_push / 2) * (force * 1)
		body.force_count += 1

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.update_force(force, rotated + 4)
		body.velocity.y *= 0.9
		body.forces -= 1
		if rotated == 0:
			if not mega: body.force1 -= 1
			else: body.mega_force1 -= 1
		elif rotated == 2:
			if not mega: body.force2 -= 1
			else: body.mega_force2 -= 1
	
	elif body.is_in_group("block") and ("interacted" in body):
		body.forces_v -= 1
		if rotated == 1 and body.gravel_gravity < force and body.forces_v == 0:
			body.gravel_gravity = 1.0
		if rotated == 3 and body.forces_v == 0:
			body.gravel_gravity = 1.0
	elif body.is_in_group("fly"): #elif "force_velocity" in body:
		if rotated == 0:   body.force_velocity.x -= (fly_push / 2) * (force * 1)
		elif rotated == 1: body.force_velocity.y -= (fly_push / 2) * (force * 1)
		elif rotated == 2: body.force_velocity.x += (fly_push / 2) * (force * 1)
		elif rotated == 3: body.force_velocity.y += (fly_push / 2) * (force * 1)
		body.force_count -= 1
