extends Node2D

var main := Main

var move := 0
var range_l := 0
var range_r := 0
var count := 0

@onready var path: Path2D = $Path
@onready var path_follow: PathFollow2D = $Path/PathFollow

@onready var animation_player: AnimationPlayer = $Path/PathFollow/Body/AnimationPlayer
@onready var collision_check: CollisionPolygon2D = $ControlTransform/Area/CollisionCheck
@onready var collision_check_2: Polygon2D = $ControlTransform/Area/CollisionCheck2


@onready var ray_cast_left: RayCast2D = $ControlTransform/RayCastLeft   	#Those for detecting the air below
@onready var ray_cast_right: RayCast2D = $ControlTransform/RayCastRight
@onready var ray_cast_l: RayCast2D = $ControlTransform/RayCastL2 	# Those for detecting the walls beside
@onready var ray_cast_r: RayCast2D = $ControlTransform/RayCastR2

@onready var sprite_left: Sprite2D = $ControlTransform/RayCastLeft/RayCastLeftSprite
@onready var sprite_right: Sprite2D = $ControlTransform/RayCastRight/RayCastRightSprite


var playing := false
var checked := false

@warning_ignore("integer_division")
func _process(delta: float) -> void:
	#if Main.playing == true:
		#checked = true
		if ray_cast_left.is_colliding():
			if count%2 == 0 and abs(position.x - ray_cast_left.get_collision_point().x) < abs(position.x - ray_cast_l.get_collision_point().x):
				sprite_left.global_position = ray_cast_left.get_collision_point()
			elif count%2 == 1 and abs(position.y - ray_cast_left.get_collision_point().y) < abs(position.y - ray_cast_l.get_collision_point().y):
				sprite_left.global_position = ray_cast_left.get_collision_point()
			else:
				sprite_left.global_position = ray_cast_l.get_collision_point()
		else:
			if count%2 == 0:
				sprite_left.global_position.x = ray_cast_l.get_collision_point().x
			else:
				sprite_left.global_position.y = ray_cast_l.get_collision_point().y
		if ray_cast_right.is_colliding():
			if count%2 == 0 and abs(position.x - ray_cast_right.get_collision_point().x) < abs(position.x - ray_cast_r.get_collision_point().x):
				sprite_right.global_position = ray_cast_right.get_collision_point()
			elif count%2 == 1 and abs(position.y - ray_cast_right.get_collision_point().y) < abs(position.y - ray_cast_r.get_collision_point().y):
				sprite_right.global_position = ray_cast_right.get_collision_point()
			else:
				sprite_right.global_position = ray_cast_r.get_collision_point()
		else:
			if count%2 == 0:
				sprite_right.global_position.x = ray_cast_r.get_collision_point().x
			else:
				sprite_right.global_position.y = ray_cast_r.get_collision_point().y
		
		range_l = int(abs(sprite_left.position.x - 21) / 84.5)
		range_r = int(abs(sprite_right.position.x - 21) / 84.5)
		print(range_l)
		print(range_r)
		
		path.curve.set_point_position(0, sprite_left.position)
		path.curve.set_point_position(1, sprite_right.position)
		path_follow.progress_ratio = sprite_left.position.x / (sprite_left.position.x + sprite_right.position.x)
		
		if Main.playing == true:
			path_follow.progress += 169
	#else:
		#checked = false
		#path_follow.progress += 169 * delta



func rotating() -> void:
	count += 1
	if count < 4:
		rotation_degrees = count * 90
	else:
		queue_free()


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player detected")
		match count:
			0:
				if body.global_position.x > global_position.x: move = 1
				else: move = -1
			1:
				if body.global_position.y > global_position.y: move = 1
				else: move = -1
			2:
				if body.global_position.x < global_position.x: move = 1
				else: move = -1
			3:
				if body.global_position.y < global_position.y: move = 1
				else: move = -1
