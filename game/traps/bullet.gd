extends Area2D

var speed := 400
@onready var start_pos := position
var colliding := false


func _process(delta: float) -> void:
	position.x -= delta * speed
	if colliding and abs(start_pos.x - position.x) + abs(start_pos.y - position.y) >= 80: # Handles first invisible frames
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().get_parent().kill()
	if body.is_in_group("block") or body.is_in_group("board") or body.is_in_group("projectile") or body.is_in_group("base"):
		colliding = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("block") or body.is_in_group("board") or body.is_in_group("projectile") or body.is_in_group("base"):
		colliding = false
