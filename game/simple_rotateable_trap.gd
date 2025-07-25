extends Sprite2D

var count := 0

func rotating() -> void:
	count += 1
	if count < 4:
		rotation_degrees = count * 90
	else:
		queue_free()
