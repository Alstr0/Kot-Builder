extends Node2D


@onready var line: Line2D = $Line2D
@onready var sphere: Sprite2D = $"Sphere"
@onready var guard: Area2D = $Path2D/PathFollow2D/Guard
@onready var sprite: Sprite2D = $Path2D/PathFollow2D/Guard/Sprite2D
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D

var dir := 1 	# Direction (1 Right, -1 Left
var start_dir := 1
#var speed_mult := 3.5
#var speed_raw := 0.197
var speed_mult := 3.4
var speed_raw := 0.18


func _ready() -> void:
	if position.x >= 255:
		end_point(global_position + (Vector2(-253.5, 0)))
	else:
		end_point(global_position + (Vector2(+253.5, 0)))


func _process(delta: float) -> void:
	if get_parent().playing:
		sphere.visible = false
		line.visible = false
		
		if path_follow.progress_ratio > 0.5:
			if path_follow.progress_ratio < 0.75:
				path_follow.progress += (abs(0.5 - path_follow.progress_ratio) * speed_mult + speed_raw) * delta * 520
			else:
				path_follow.progress += (abs(1 - path_follow.progress_ratio) * speed_mult + speed_raw) * delta * 520
			if dir == 1: sprite.flip_h = false
			else: sprite.flip_h = true
		
		else:
			if path_follow.progress_ratio < 0.25:
				path_follow.progress += (path_follow.progress_ratio * speed_mult + speed_raw) * delta * 520
			else:
				path_follow.progress += (abs(0.5 - path_follow.progress_ratio) * speed_mult + speed_raw) * delta * 520
			if dir == 1: sprite.flip_h = true
			else: sprite.flip_h = false
	
	else:
		path_follow.progress_ratio = 0.0
		guard.position = Vector2(0, 0)
		sphere.visible = true 
		line.visible = true


func end_point(pos) -> void:
	sphere.global_position = pos
	path.curve.set_point_position(1, sphere.position)
	line.set_point_position(1, sphere.position)
	
	if sphere.position.x < 0:
		start_dir = -1
		dir = -1
		sprite.flip_h = false
	else:
		start_dir = 1
		dir = 1
		sprite.flip_h = true


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().kill()
