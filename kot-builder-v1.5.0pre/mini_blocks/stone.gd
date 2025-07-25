extends StaticBody2D

var quit := false

func entered() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.pickaxe_level > 0:
			if body.pickaxe_durability <= 0:
				body.pickaxe_level = 0
			else:
				body.pickaxe_durability -= 1
				position.y += 2000

func replay() -> void:
	if position.y > 2000:
		position.y -= 2000
