extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.gravity_orb += 1
		body.jump_orb += 1

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.gravity_orb -= 1
		body.jump_orb -= 1
