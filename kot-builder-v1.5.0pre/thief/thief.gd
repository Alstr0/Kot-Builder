extends CharacterBody2D


@export var mode := 0
enum modes{DEFAULT = 0, FROG = 1, JUMPER = 2, CLIMBER = 3, CLOUDY = 4, SPEEDY = 5, GRAVITY = 6}

var jm :float = 2.125   	#Jump Multipler
var sp :float = 123.25  	#Speed Multipler
var SPEED := 2.2 * sp  							#2.2
var AIR_SPEED := 2.036 * sp  					#2
var JUMP_VELOCITY := -313.0 * jm * 1.026
var WALL_JUMP_VELOCITY := -334.0 * jm * 0.978	#-341.74 * jm
var TRAMBOLINE_JUMP_VELOCITY := -486.96 * jm
var TRAMBOLINE_BOOST_VELOCITY := 300
var max_fall_speed := 160.0  					#1
var max_wall_speed := 1002.1
const jump_boost :float = 10
const wall_boost :float = 25  					#2
const ceiling_boost :float = 16 # It was 18
const tramboline_boost :float = 15
const gravity := 2.0  							#15
@onready var current_gravity := gravity
var reached_chest := false
var gravity_direction := 1
var direction := 1
var clicked := false 
var is_first_time := 4  	# TODO
var boost := 0.0
var wj_vel := -292.4828  # -270 	#Least y velocity required to perform wall jump
var on_air := false
var tramboline_h := 0  #How many Horizontal trambolines thief currently colliding with   #Flipped
var tramboline_v := 0  #Vertical #Rotated
var jump_orb := 0
var tramboline_orb := 0
var gravity_orb:= 0
var jumped := false
var pickaxe_level := 0     #Gold - Diamond
var pickaxe_durability := 0
var force_boost := 1.0
var forces_h := Array() 	#  -
var forces_v := Array() 	#  |
var roaster := false
var web := 0
var current_web_boost := 1.0
var current_web_jump_boost := 1.0
const web_boost := 0.5
const web_jump_boost := 1.02
@onready var fly_follow := self.global_position
var fly_delay := 0.1
var prev_velocity := Vector2(0, 0)

var forces := 0
var force1 := 0
var mega_force1 := 0
var force2 := 0
var mega_force2 := 0
var heavy_boost := 8.0
var light_boost := 4.0
var force_multipler := 4.0
var negative_boost := 1.075
var mega_negative_boost := 1.75
@export var change_dir_on_floor := false

@onready var collisionz := $CollZ
@onready var collisionx := $CollX
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sprite1: Sprite2D = $Sprite1
@onready var sprite2: Sprite2D = $Sprite2
@onready var sprite3: Sprite2D = $Sprite3
@onready var roaster_timer: Timer = $Roaster
@onready var web_timer: Timer = $Web


func _ready() -> void:
	var light_force = get_parent().light_force
	var heavy_force = get_parent().heavy_force
	
	match mode:
		0:
			pass
		1:
			SPEED = 0
			max_fall_speed *= 0.75
		2:
			JUMP_VELOCITY *= 1.2
			WALL_JUMP_VELOCITY *= 1.2
		3:
			max_fall_speed *= -0.75
		4:
			current_gravity *= 0.25
			JUMP_VELOCITY *= 0.5
			WALL_JUMP_VELOCITY *= 0.5
			max_fall_speed *= 0.5
			TRAMBOLINE_JUMP_VELOCITY *= 0.5
			TRAMBOLINE_BOOST_VELOCITY *= 0.5
		5:
			JUMP_VELOCITY *= 0.85
			WALL_JUMP_VELOCITY *= 0.85
			max_fall_speed *= 2
			TRAMBOLINE_JUMP_VELOCITY *= 0.85
			TRAMBOLINE_BOOST_VELOCITY *= 0.85
			SPEED *= 1.5
			AIR_SPEED *= 1.5
			
		6:
			pass
	
	
	
	
	if light_force == 1.1:
		light_boost = 6.0
	elif light_force == 1.2:
		light_boost = 6.66
	elif light_force == 1.4:
		light_boost = 8.0
	
	if heavy_force == 2.0:
		heavy_boost = 10.0
	elif heavy_force == 2.5:
		heavy_boost = 12.0
	elif heavy_force == 1.5:
		heavy_boost = 8.0

func change_direction():
	direction *= -1
	collisionz.scale.x *= -1
	collisionx.scale.x *= -1
	if direction  == 1:
		sprite1.flip_h = false
		sprite2.flip_h = true
		sprite3.flip_h = true
	else:
		sprite1.flip_h = true
		sprite2.flip_h = false
		sprite3.flip_h = false

func update_force(force:float, force_direction:int):
	force = force * force_multipler
	
	if force_direction == 0 or force_direction == 2:
		forces_h.append(force)
	elif force_direction == 1 or force_direction == 3:
		forces_v.append(force)
	elif force_direction == 4 or force_direction == 6:
		forces_h.erase(force)
		if forces_h.size() == 0:
			force_boost = 1.0
	elif force_direction == 5 or force_direction == 7:
		forces_v.erase(force)
		if forces_v.size() == 0:
			current_gravity = gravity
	
	var find_the_force_h := 1.0
	for i in range(forces_h.size()):
		if find_the_force_h < forces_h[i]:
			find_the_force_h = forces_h[i]
	
	var find_the_force_v := 1.0
	for i in range(forces_v.size()):
		if find_the_force_v < forces_v[i]:
			find_the_force_v = forces_v[i]
	
	if find_the_force_h < force_boost:
		if (direction == 1 and force_direction == 0) or (direction == -1 and force_direction == 3):
			force_boost = force
		elif (direction == -1 and force_direction == 0) or (direction == 1 and force_direction == 3):
			force_boost = force
	
	
	var up := 6
	var down := 2.5
	
	if force < 1.5 * 4:
		if force_direction == 1:
			if gravity_direction == -1:
				current_gravity = 1 / (gravity + force) * up * 1.25
			else: 
				current_gravity = (gravity + force) / down
		elif force_direction == 3:
			if gravity_direction == -1:
				current_gravity = (gravity + force) / down
			else: 
				current_gravity = 1 / (gravity + force) * up * 1.25
	else:
		if force_direction == 1:
			if gravity_direction == -1:
				current_gravity = 1 / (gravity + force) * up / 1.75
			else:
				current_gravity = (gravity + force) / down
		elif force_direction == 3:
			if gravity_direction == -1:
				current_gravity = (gravity + force) / down
			else:
				current_gravity = 1 / (gravity + force) * up / 1.75


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if web:
			velocity += get_gravity() * delta * current_gravity * gravity_direction * current_web_boost / 2.1
		else:
			velocity += get_gravity() * delta * current_gravity * gravity_direction
	else:
		on_air = false
		jumped = false
		boost = 0
	
	if (is_on_floor() or is_on_wall() or is_on_ceiling()) and direction * velocity.x != abs(direction) * abs(velocity.x):
		change_direction()
	
	sprite1.visible = true
	sprite2.visible = false
	sprite3.visible = false
	if not reached_chest and roaster and roaster_timer.is_stopped(): roaster_timer.start()
	
	if is_on_wall_only() and velocity.y > max_fall_speed and gravity_direction > 0:
		velocity.y = max_fall_speed
		on_air = false
		boost = 0
	
	elif is_on_wall_only() and velocity.y < -max_fall_speed and gravity_direction < 0:
		velocity.y = -max_fall_speed
		on_air = false
		boost = 0
	
	
	elif is_on_wall_only() and velocity.y < -max_wall_speed and gravity_direction > 0:
		velocity.y += 100
		on_air = false
		boost = 0
		
	elif is_on_wall_only() and velocity.y > max_wall_speed and gravity_direction < 0:
		velocity.y -= 100
		on_air = false
		boost = 0
	
	if is_on_ceiling_only() and not web:
		on_air = false
		boost = ceiling_boost
	
	if is_on_wall():
		sprite1.visible = false
		if abs(velocity.y) >= 2:
			sprite2.visible = true
			sprite3.visible = false
		else:
			sprite2.visible = false
			sprite3.visible = true
	
	if Input.is_action_just_pressed("click") and not is_first_time:
		$Timer.start()
		clicked = true
	
	if clicked == true: #Wall Jump / Corner Jump / Normal Jump
		if gravity_orb:
			switch_gravity()
			if jump_orb == 0:
				velocity.y = 0
			is_first_time = false
			clicked = false
		if is_on_wall_only() and velocity.x == 0 and ((velocity.y > wj_vel and gravity_direction > 0) or (velocity.y < 150 and gravity_direction < 0)):
			clicked = false
			boost = wall_boost
			on_air = true
			change_direction()
			velocity.y = WALL_JUMP_VELOCITY * gravity_direction * current_web_boost #* current_web_jump_boost
			if tramboline_v:
				boost = TRAMBOLINE_BOOST_VELOCITY
		elif is_on_floor() and is_on_wall() and (prev_velocity.y != 0 or velocity.y != 0):
			print("Perfect Corner Jump!")
			on_air = false
			boost = wall_boost
			change_direction()
			velocity.y = WALL_JUMP_VELOCITY * gravity_direction * current_web_boost * current_web_jump_boost * 1.05
			sprite1.visible = true
			sprite2.visible = false
			sprite3.visible = false
			clicked = false
		elif is_on_floor() or jump_orb or tramboline_orb: # NORMAL JUMP
			if tramboline_h or tramboline_orb:
				velocity.y = TRAMBOLINE_JUMP_VELOCITY * gravity_direction #* current_web_boost * current_web_jump_boost
				boost = tramboline_boost
				on_air = true
				jumped = true
			else:
				if mode == 6:
					switch_gravity()
				velocity.y = JUMP_VELOCITY * gravity_direction * current_web_boost * current_web_jump_boost
				boost = jump_boost
				on_air = true
				jumped = true
			is_first_time = false
			clicked = false
	
	if not is_on_floor() and not is_on_wall() and not is_on_ceiling(): 
		if roaster: roaster_timer.stop()
	
	var boost_dec := delta * 12 #Boost Decrement
	if (boost < 0.25) and (boost > -	0.25):
		boost = 0
	if boost > 0:
		boost -= boost_dec
	elif boost < 0:
		boost += boost_dec
	
	if is_on_ceiling_only():
		boost += ceiling_boost
		on_air = false
		if roaster and roaster_timer.is_stopped(): roaster_timer.start()
	
	if mega_force1 and not mega_force2:
		if direction == 1:
			force_boost = get_parent().heavy_force
			boost += heavy_boost
		else:
			force_boost = 1 / get_parent().heavy_force
			boost -= heavy_boost * mega_negative_boost
	elif not mega_force1 and mega_force2:
		if direction == -1:
			force_boost = get_parent().heavy_force
			boost += heavy_boost
		else:
			force_boost = 1 / get_parent().heavy_force
			boost -= heavy_boost * mega_negative_boost
	elif not mega_force1 and not mega_force2 and force1 and not force2:
		if direction == 1:
			boost += light_boost
		else:
			boost -= light_boost * negative_boost
	elif not mega_force1 and not mega_force2 and not force1 and force2:
		if direction == 1:
			boost -= light_boost * negative_boost
		else:
			boost += light_boost
	if not mega_force1 and not mega_force2:
		force_boost = 1.0
	else:
		force_boost /= 1.5
	
	
	if on_air:
		velocity.x = (AIR_SPEED + boost) * direction * current_web_boost * force_boost  	#* delta * 60
	else:
		velocity.x = (SPEED + boost) * direction * current_web_boost * force_boost  		#* delta * 60
	get_parent().roaster_time_left = roaster_timer.time_left
	
	if web:
		if web_timer.is_stopped() and not reached_chest:
			web_timer.start()
			current_web_boost = web_boost
			current_web_jump_boost = web_jump_boost
			wj_vel = -800
			max_fall_speed = 80
			max_wall_speed = 242.3083496092
			#print(current_web_jump_boost)
	else:   	# Go Back to Normal
		if not web_timer.is_stopped():
			web_timer.stop()
			current_web_boost = 1.0
			current_web_jump_boost = 1.0
			wj_vel = -292.4828
			max_fall_speed = 160
			max_wall_speed = 600
	
	move_and_slide()
	
	if is_first_time:
		$Timer.stop()
		is_first_time -= 1
	prev_velocity = velocity
	var old_pos = global_position
	await get_tree().create_timer(fly_delay).timeout
	fly_follow = old_pos

func switch_gravity() -> void:
	gravity_direction *= -1
	on_air = false
	up_direction = Vector2(0, gravity_direction * -1)
	velocity.y *= 0.9
	velocity.x *= 0.9
	velocity.y += 80 * gravity_direction 
	sprite1.flip_v = not sprite1.flip_v
	sprite2.flip_v = not sprite2.flip_v
	sprite3.flip_v = not sprite3.flip_v
	collisionz.scale *= -1
	collisionx.scale *= -1
	particles.position.y *= -1
	if gravity_direction == 1:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("animation")
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("animation_2")


func _on_timer_timeout() -> void:
	clicked = false

func no_collision() -> void:   # BUG
	collisionz.disabled = true
	collisionx.disabled = true

func _on_roaster_timeout() -> void:
	roaster_timer.stop()
	get_parent().kill()

func _on_web_timeout() -> void:
	get_parent().kill()

func _on_animation_finished(anim_name: StringName) -> void:
	if gravity_direction == 1:
		$AnimationPlayer.play("animation")
	else:
		$AnimationPlayer.play("animation_2")
