extends Node2D

var bullet := preload("res://traps/bullet.tscn")
var count := 0
var speed := 84.5

@onready var line: Line2D = $Line2D
@onready var sphere: Sprite2D = $Sphere
@onready var timer := $Timer
@onready var sprite: Sprite2D = $Path2D/PathFollow2D/Sprite
@onready var marker: Node2D = $Path2D/PathFollow2D/Sprite/Marker2D
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D

var playing := false
var removed_once := true

func _ready() -> void:
	if position.x >= 1060:
		end_point(global_position + Vector2(-84.5, 0))
	else:
		end_point(global_position + Vector2(+84.5, 0))

func _process(delta: float) -> void:
	playing = get_parent().playing
	if playing == false and removed_once == false:
		timer.stop()
		removed_once = true
		line.visible = true
		sphere.visible = true
		path_follow.progress = 0
		for i in range(3, get_child_count()):
			if get_child(i).is_in_group("projectile"):
				get_child(i).queue_free()
	
	elif playing:
		if timer.is_stopped():
			timer.start()
			fire()
		removed_once = false
		line.visible = false
		sphere.visible = false
		path_follow.progress += speed * delta


func rotating() -> void:
	count += 1
	if count < 4:
		sprite.rotation_degrees = count * 90
	else:
		queue_free()

func end_point(pos) -> void:
	sphere.global_position = pos
	path.curve.set_point_position(1, sphere.position)
	line.set_point_position(1, sphere.position)


func _on_timer_timeout() -> void:
	fire()

func fire() -> void:
	if playing:
		timer.start()
		var instance = bullet.instantiate()
		add_child(instance)
		instance.position = path_follow.position
		instance.scale = Vector2(3, 3)
		instance.rotation_degrees = (count - 1) * 90  #BUG
		
	
