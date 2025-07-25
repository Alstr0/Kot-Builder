extends Node2D

var og_jump_vel := -510.0
var count := 0
@onready var collision := $StaticBody2D/CollisionShape2D

func input() -> void:
	count += 1
	if count < 4:
		rotation_degrees = count * 90
	else:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if count %2 == 0:
			body.tramboline_h += 1
		else:
			body.tramboline_v += 1

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if count %2 == 0:
			body.tramboline_h -= 1
		else:
			body.tramboline_v -= 1
