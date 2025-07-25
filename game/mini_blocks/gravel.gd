extends RigidBody2D

@export var gravel_push := true
@export var area := 20
var interacted := false
var pos :Vector2
var quit := true
var gravel_below :Array
var gravel_gravity := 1.0
var forces_v := 0
var forces_h := 0



func _ready() -> void:
	$Area2D/CollisionShape2D.shape.size = Vector2(area, area)
	pos = global_position

func _physics_process(delta: float) -> void:
	if interacted:
		gravity_scale = gravel_gravity
		sleeping = false
		freeze = false
		if linear_velocity.y != 0:
			linear_velocity.x = forces_h
			#if forces_h and forces_v == 0:
			#	position.x = pos.x
		else:
			forces_h = 0
	else:
		gravity_scale = 0
		angular_velocity = 0
		rotation_degrees = 0
		linear_velocity.x = 0.0
		sleeping = true
		freeze = true


func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		quit = false
	elif gravel_push and body.is_in_group("block") and quit and \
		abs(body.position.x - position.x) <= 60 and body.position.y + 60 > position.y:
		gravel_below.append(body)
	elif gravel_push and body.is_in_group("block") and body.interacted and not quit and abs(float(body.position.x - position.x <= 60)):
		interacted = true

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player") and not quit:
		interacted = true
		for i in range(gravel_below.size()):
			gravel_below[i].interacted = true


func replay() -> void:
	interacted = false
	gravity_scale = 0
	quit = true
	linear_velocity.x = 0.0
	position = pos
	sleeping = true
	freeze = true
