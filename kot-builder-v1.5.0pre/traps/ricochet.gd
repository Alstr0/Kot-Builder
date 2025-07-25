extends Node2D

var direction := 0
var start_direction := 0
var bounce := 0
var max_bounce := 4
var speed := 210 # 500
var collided := false
var cross_colliding := false
var cross_collided := 0
var returning := false
@onready var start_point = position
@onready var sprite := $Sprite
@onready var ray_cast1 := $RayCasts1
@onready var ray_cast2 := $RayCasts2

#	2	  3
#	  Ric
#	1	  0


func rotating() -> void:
	start_direction += 1
	direction = start_direction
	if start_direction < 4:
		rotation_degrees = direction * 90
	else:
		queue_free()


func _process(delta: float) -> void:
	if get_parent().player == null:
		bounce = 0
		direction = start_direction
		position = start_point
		
		if direction == 0:
			sprite.rotation_degrees = 0
			sprite.flip_h = true
			sprite.flip_v = false
		elif direction == 1:
			sprite.rotation_degrees = 90
			sprite.flip_h = true
			sprite.flip_v = true
		elif direction == 2:
			sprite.rotation_degrees = 90
			sprite.flip_h = true
			sprite.flip_v = true
		elif direction == 3:
			sprite.rotation_degrees = 0
			sprite.flip_h = true
			sprite.flip_v = false
		
	else:
		direction = direction %4
		cross_colliding = false
		rotation_degrees = direction * 90
		ray_cast1.rotation_degrees = direction * -90
		ray_cast2.rotation_degrees = direction * -90
		
		if direction == 0:
			sprite.rotation_degrees = 0
			sprite.flip_h = true
			sprite.flip_v = false
		elif direction == 1:
			sprite.rotation_degrees = 180
			sprite.flip_h = true
			sprite.flip_v = true
		elif direction == 2:
			sprite.rotation_degrees = 90
			sprite.flip_h = false
			sprite.flip_v = false
		elif direction == 3:
			sprite.rotation_degrees = 0
			sprite.flip_h = true
			sprite.flip_v = false
		
		if $RayCasts1/RayCastUp.is_colliding():
			if direction == 3: direction = 0
			elif direction == 2: direction = 1
			collided = true
		elif $RayCasts1/RayCastRight.is_colliding():
			if direction == 3: direction = 2
			elif direction == 0: direction = 1
			collided = true
		elif $RayCasts1/RayCastLeft.is_colliding():
			if direction == 2: direction = 3
			elif direction == 1: direction = 0
			collided = true
		elif $RayCasts1/RayCastDown.is_colliding():
			if direction == 1: direction = 2
			elif direction == 0: direction = 3
			collided = true
		
		elif $RayCasts2/RayCast3.is_colliding(): cross_colliding = true
		elif $RayCasts2/RayCast0.is_colliding(): cross_colliding = true
		elif $RayCasts2/RayCast2.is_colliding(): cross_colliding = true
		elif $RayCasts2/RayCast1.is_colliding(): cross_colliding = true
		
		elif collided and not cross_colliding:
			bounce += 1
			collided = false
		
		if cross_colliding and cross_collided == 0:
			if direction == 0: direction = 2
			elif direction == 1: direction = 3
			elif direction == 2: direction = 0
			elif direction == 3: direction = 1
			cross_collided = 12
		elif cross_collided != 0:
			cross_collided -= 1 
		
		if bounce >= max_bounce:
			if direction == 0: direction = 2
			elif direction == 1: direction = 3
			elif direction == 2: direction = 0
			elif direction == 3: direction = 1
			returning = not returning
			bounce = -1
		#print(bounce, "/", max_bounce)
		#print("Direction: ", direction)
		
		
		if direction == 0:
			position.x += speed * delta
			position.y += speed * delta
		elif direction == 1:
			position.x -= speed * delta
			position.y += speed * delta
		elif direction == 2:
			position.x -= speed * delta
			position.y -= speed * delta
		elif direction == 3:
			position.x += speed * delta
			position.y -= speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().kill()
		direction = start_direction
		position = start_point
		rotation_degrees = direction * 90
