extends Area2D

@onready var sprite1: Sprite2D = $Sprite1
@onready var sprite2: Sprite2D = $Sprite2


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and sprite1.visible:
		body.switch_gravity()
		sprite1.visible = false
		sprite2.visible = true
		get_parent().rotate_gravity()
