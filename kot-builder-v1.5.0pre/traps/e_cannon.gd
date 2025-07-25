extends Area2D

var count := 0
@onready var timer := $Timer
@onready var anim := $AnimationPlayer
@onready var ray_cast: RayCast2D = $RayCast
@onready var collision_body: CollisionShape2D = $CollisionBody
@onready var collision_laser: CollisionPolygon2D = $CollisionLaser
@onready var sprite: Sprite2D = $Sprite
@onready var sprite_laser: Sprite2D = $SpriteLaser
@onready var line: Line2D = $Line2D

var is_first_attack_done := false
var playing := false
var bodies := []

func _process(delta: float) -> void:
	playing = get_parent().playing
	if anim.is_playing() and bodies.size() != 0:
		get_parent().kill()
	if playing and is_first_attack_done == false:
		is_first_attack_done = true
		await get_tree().create_timer(0.1).timeout
		anim.play("fire")
	elif playing == false:
		timer.stop()
		is_first_attack_done = false
		if ray_cast.is_colliding():
			line.points[1] = ray_cast.get_collision_point() - global_position
			if count%2 == 0:
				sprite_laser.scale.x = abs(ray_cast.get_collision_point() - global_position).x / 8
				sprite_laser.scale.x = abs(ray_cast.get_collision_point() - global_position).x / 8
				collision_laser.polygon[2].x = -abs(ray_cast.get_collision_point() - global_position).x
				collision_laser.polygon[3].x = -abs(ray_cast.get_collision_point() - global_position).x
			else:
				sprite_laser.scale.x = abs(ray_cast.get_collision_point() - global_position).y / 8
				sprite_laser.scale.x = abs(ray_cast.get_collision_point() - global_position).y / 8
				collision_laser.polygon[2].x = -abs(ray_cast.get_collision_point() - global_position).y
				collision_laser.polygon[3].x = -abs(ray_cast.get_collision_point() - global_position).y
		if timer.is_stopped() == false:
			timer.stop()

func rotating() -> void:
	count += 1
	if count < 4:
		rotation_degrees = count * 90
		line.rotation_degrees = count * -90
		#collision_laser.rotation_degrees = count * -90
	else:
		queue_free()


func _on_timer_timeout() -> void:
	anim.play("fire")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bodies.append(body)
		print("EC/P_Enter")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		bodies.erase(body)
		print("EC/P_Exit")

func fire() -> void:
	timer.start()
