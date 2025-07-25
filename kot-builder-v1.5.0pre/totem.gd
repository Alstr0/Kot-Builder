extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if visible == true and body.is_in_group("player"):
		body.no_collision()
		body.position = position
		body.particles.emitting = false
		body.SPEED = 0
		body.AIR_SPEED = 0
		body.boost = 0
		body.web_timer.stop()
		body.roaster_timer.stop()
		body.reached_chest = true
		if body.gravity_direction < 0:
			body.switch_gravity()
		body.gravity_direction = 0
		body.velocity = Vector2(0, 0)
		get_parent().playing = false
		#$Timer.start()
