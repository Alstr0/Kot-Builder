extends Node2D




func _process(delta: float) -> void:
	if get_parent().spawn == true:
		$Web/Sprite.visible = true
	else:
		$Web/Sprite.visible = false

func _on_spider_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().kill()

func _on_web_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.web += 1
		body.velocity.y *= 0.5

func _on_web_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.web -= 1
		print(body.velocity.y)
		if body.velocity.y * body.gravity_direction >= 0 * body.gravity_direction:
			body.velocity.y *= 2.0
		elif body.velocity.y * body.gravity_direction < -750 * body.gravity_direction:
			body.velocity.y *= 0.75
		elif body.velocity.y * body.gravity_direction > -400 * body.gravity_direction:
			body.velocity.y *= 1.88
