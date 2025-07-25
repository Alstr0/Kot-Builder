extends Area2D

var pickaxe_durability := 32000


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if (position == Vector2(42.25, 42.25) and (abs(position.x - body.position.x) < 42.5 and abs(position.y - body.position.y) < 42.5)) or position != Vector2(42.25, 42.25):
			if body.pickaxe_level == 0:
				body.pickaxe_level = 1
				body.pickaxe_durability = pickaxe_durability
				position.y += 2000


func replay() -> void:
	if position.y > 2000:
		position.y -= 2000


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.play("animation")
