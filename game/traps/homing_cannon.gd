extends Node2D

var bullet := preload("res://traps/bullet.tscn")
var count := 0

@onready var marker: Marker2D = $Marker
@onready var timer := $Timer

var playing := false
var runned_once := false

func _process(delta: float) -> void:
	playing = get_parent().playing
	if get_parent().player != null:
		look_at(get_parent().player.position)
		rotation_degrees += 180

	if playing and runned_once == false:
		runned_once = true
		#await get_tree().create_timer(0.5).timeout
		#create()
	elif playing == false and runned_once:
		runned_once = false
		timer.stop()
		for i in range(2, get_child_count()):
			if get_child(i).is_in_group("projectile"):
				get_child(i).queue_free()


#func _on_timer_timeout() -> void:
	#create()
#
#func create() -> void:
	#timer.start()
	#var instance = bullet.instantiate()
	#add_child(instance)
	#instance.global_transform = marker.global_transform
	#instance.look_at(get_parent().player.position)
