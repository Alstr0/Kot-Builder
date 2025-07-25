extends StaticBody2D

var durability = 2
var current_dur = 2
var quit := false


func entered() -> void:
	quit = false

func change_durability(value:int) -> void:
	durability = value
	current_dur = value

func _on_area_2d_body_entered(body: Node) -> void:
	quit = false
	$AnimationPlayer.play("animation")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not quit:
		if current_dur > 1:
			current_dur -= 1
			#$AnimationPlayer.play("animation")
		else:
			position.y += 2000

func replay() -> void:
	quit = true
	current_dur = durability
	if position.y > 2000:
		position.y -= 2000
