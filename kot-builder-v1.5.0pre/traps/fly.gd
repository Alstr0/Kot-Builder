extends RigidBody2D

var speed := 275
var max_speed := 275
var base_speed := 275
var close_area := 8
var base_close_area := 8
var target :Vector2
var force_velocity := Vector2(0,0)
var force_count := 0
@onready var start_pos := position
@onready var line: Line2D = $Line2D
@onready var sprite: Sprite2D = $Sprite2D
var merge = false


func _physics_process(delta: float) -> void:
	if get_parent().playing == false:
		position = start_pos
		max_speed = base_speed
		close_area = base_close_area
		visible = true
		sprite.rotation_degrees = 0
		sprite.self_modulate = Color(1, 1, 1)
		rotation_degrees = 0
		angular_velocity = 0
		linear_velocity = Vector2(0, 0)
		#line.points[1] = get_parent().door.position - position
	
	elif get_parent().player != null:
		if get_parent().player.fly_follow != Vector2(0, 0):
			target = get_parent().player.fly_follow
		else:
			target = get_parent().player.global_position
		
		if position.distance_to(target) > close_area and visible:
			speed = max_speed
		elif visible:
			speed = max_speed * (position.distance_to(target) / max_speed)
		
		linear_velocity = position.direction_to(target) * speed
		#line.points[1] = target - position
		linear_velocity += force_velocity
		sprite.rotation_degrees += rotation_degrees 
		rotation_degrees = 0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and visible:
		get_parent().kill()
	elif body.is_in_group("fly") and visible and body != self and merge:
		body.visible = false
		body.max_speed = 0
		body.position = Vector2(-100, -100)
		sprite.self_modulate += body.sprite.self_modulate / 2
		max_speed = base_speed + sprite.self_modulate.a * 60
		close_area = maxi(0, close_area - sprite.self_modulate.a * 4)
 
