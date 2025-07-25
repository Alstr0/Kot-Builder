extends Sprite2D

var bullet := preload("res://traps/bullet.tscn")
var count := 0
@onready var marker := $Marker2D
@onready var timer := $Timer
@onready var anim := $AnimationPlayer
var playing := false
var runned_once := false

func _process(delta: float) -> void:
	playing = get_parent().playing
	if playing and runned_once == false:
		self_modulate = "ffffff00"
		runned_once = true
		anim.play("fire")
	if playing == false and runned_once:
		runned_once = false
		self_modulate = "ffffff"
		timer.stop()
		for i in range(get_child_count()):
			if get_child(i).is_in_group("projectile"):
				get_child(i).queue_free()

func rotating() -> void:
	count += 1
	if count < 8:
		rotation_degrees = count * 45
	else:
		queue_free()


func _on_timer_timeout() -> void:
	anim.play("fire")

func fire() -> void:
	if playing:
		timer.start()
		var instance = bullet.instantiate()
		instance.transform = marker.transform
		add_child(instance)
