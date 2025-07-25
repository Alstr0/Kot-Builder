extends Node2D


var move := 0
var range_l := 0
var range_r := 0
var count := 0

@onready var path: Path2D = $Path
@onready var path_follow: PathFollow2D = $Path/PathFollow

@onready var animation_player: AnimationPlayer = $Path/PathFollow/Body/AnimationPlayer
@onready var collision_check: CollisionPolygon2D = $ControlTransform/Area/CollisionCheck
@onready var collision_check_2: Polygon2D = $ControlTransform/Area/CollisionCheck2



@onready var ray_cast_lg: RayCast2D = $ControlTransform/RayCastLG
@onready var ray_cast_lw: RayCast2D = $ControlTransform/RayCastLW
@onready var ray_cast_rg: RayCast2D = $ControlTransform/RayCastRG
@onready var ray_cast_rw: RayCast2D = $ControlTransform/RayCastRW
	# R: Right, L: Left, G: Ground, W: Wall

var playing := false
var checked := false

func _process(delta: float) -> void:
	if get_parent().spawn == true:
		if checked == false:
			checked = true
			for i in range(20): 	# Left
				await get_tree().create_timer(0.5).timeout
				ray_cast_lg.global_position.x -= 84.5
				ray_cast_lw.global_position.x -= 84.5
				if ray_cast_lg.is_colliding() and ray_cast_lw.is_colliding() == false:
					range_l += 1
				else:
					break
			for i in range(20): 	# Right
				await get_tree().create_timer(0.5).timeout
				ray_cast_rg.global_position.x += 84.5
				ray_cast_rw.global_position.x += 84.5
				if ray_cast_rg.is_colliding() and ray_cast_rw.is_colliding() == false:
					range_r += 1
				else:
					break
			
			range_l = maxi(range_l - 1, 0)
			range_r = maxi(range_r - 1, 0)
			collision_check.polygon[1].x = 84.5 * -range_l - 42.25
			collision_check.polygon[2].x = 84.5 * -range_l - 42.25
			collision_check.polygon[0].x = 84.5 * +range_r + 42.25
			collision_check.polygon[3].x = 84.5 * +range_r + 42.25
			collision_check_2.polygon[1].x = (84.5 * -range_l * 2 - 42.25) * 0.9 	# FIXME
			collision_check_2.polygon[2].x = (84.5 * -range_l * 2 - 42.25) * 0.9
			collision_check_2.polygon[0].x = (84.5 * +range_r * 2 + 42.25) * 0.9
			collision_check_2.polygon[3].x = (84.5 * +range_r * 2 + 42.25) * 0.9
			path.curve.set_point_position(0, Vector2(84.5 * -range_r - 42.25, 0))
			path.curve.set_point_position(1, Vector2(84.5 * +range_r + 42.25, 0))
			path_follow.progress = (1 + range_l) * 84.5 + 42.25
		if move != 0:
			path_follow.progress += move * delta * 189
	else:
		checked = false
		path_follow.progress = range_l * 84.5
		range_l = 0
		range_r = 0
		ray_cast_lg.position.x = (range_l + 1) * -84.5
		ray_cast_lw.position.x = (range_l + 1) * -84.5 + 44.5
		ray_cast_rg.position.x = (range_r + 1) * +84.5
		ray_cast_rw.position.x = (range_r + 1) * +84.5 - 44.5
		collision_check.polygon[1].x = -42.25
		collision_check.polygon[2].x = -42.25
		collision_check.polygon[0].x = 42.25
		collision_check.polygon[3].x = 42.25


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
