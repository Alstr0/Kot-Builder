extends Node2D

@export var speed := 2.2

@onready var line: Line2D = $Line2D
@onready var sphere: Sprite2D = $"End Point/Sphere"
@onready var start: Node2D = $"Start Point"
@onready var end: Node2D = $"End Point"
@onready var guard: Area2D = $Path2D/PathFollow2D/Guard
@onready var sprite: Sprite2D = $Path2D/PathFollow2D/Guard/Sprite2D
@onready var collision: CollisionShape2D = $Path2D/PathFollow2D/Guard/CollisionShape2D

var dir := true

func _ready() -> void:
	if position.x >= 255:
		end_point(global_position + (Vector2(-253.5, 0)))
	else:
		end_point(global_position + (Vector2(+253.5, 0)))


func _process(delta: float) -> void:
	if get_parent().playing:
		guard.rotation_degrees += speed * delta
		sprite.rotation_degrees -= speed * delta
		sphere.visible = false 
		line.visible = false
	else:
		guard.rotation_degrees = 0
		sprite.rotation_degrees = 0
		guard.rotation_degrees = 0
		sphere.visible = true 
		line.visible = true


func end_point(pos) -> void:
	end.global_position = pos
	guard.global_position = end.global_position
	sprite.global_position = start.global_position
	collision.global_position = start.global_position
	line.set_point_position(1, end.position)


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().kill()
