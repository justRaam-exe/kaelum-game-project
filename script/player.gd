extends CharacterBody2D

const GRAVITY = 700.0
const JUMP_POWER = 350.0
const MAX_JUMP_CHARGE = 1.0
const SPEED = 150.0

const BOUNCE_FORCE = 0.6
const MIN_BOUNCE_SPEED = 80
const WALL_BOUNCE_Y = -70
const BOUNCE_LOCK = 0.12

var jump_charge = 0.0
var is_charging = false

var wall_bounced = false
var bounce_lock_timer = 0.0

@onready var animatedSpritee = $AnimatedSprite2D

func _physics_process(delta):
	var was_on_floor = is_on_floor()

	bounce_lock_timer = max(bounce_lock_timer - delta, 0)

	# GRAVITY
	if not was_on_floor:
		velocity.y += GRAVITY * delta

	# INPUT
	var direction := Input.get_axis("move_left", "move_right")

	# FLIP
	if direction > 0: animatedSpritee.flip_h = false
	elif direction < 0: animatedSpritee.flip_h = true

	# CHARGE SYSTEM
	if Input.is_action_pressed("jumping_move") and was_on_floor:
		is_charging = true
		jump_charge = clamp(jump_charge + delta, 0, MAX_JUMP_CHARGE)
		direction = 0

	elif Input.is_action_just_released("jumping_move") and was_on_floor and is_charging:
		_perform_jump()
		is_charging = false
		jump_charge = 0.0

	# MOVEMENT, kecuali saat bounce lock
	if bounce_lock_timer <= 0:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 10 * delta)

	# ===============================
	# 1) MOVE FIRST
	# ===============================
	

	# ===============================
	# 2) THEN CHECK COLLISION AFTER MOVING
	# ===============================
	var hit_wall = false

	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var normal = col.get_normal()

		# benar-benar dinding (normal.x != 0)
		if normal.x != 0 and not is_on_floor():
			hit_wall = true

			# bounce hanya sekali
			if not wall_bounced:

				# Bounce X
				velocity.x = -velocity.x * BOUNCE_FORCE

				if abs(velocity.x) < MIN_BOUNCE_SPEED:
					velocity.x = sign(velocity.x) * MIN_BOUNCE_SPEED

				# Bounce Y kecil
				velocity.y = WALL_BOUNCE_Y

				wall_bounced = true
				bounce_lock_timer = BOUNCE_LOCK

			break
	move_and_slide()
	
	if not hit_wall:
		wall_bounced = false
		
	
		
	# LANDING
	if not was_on_floor and is_on_floor():
		jump_charge = 0
		is_charging = false

	# ANIMATIONS
	if not is_on_floor():
		animatedSpritee.play("Jumping")
	elif is_charging:
		animatedSpritee.play("charge")
	elif direction == 0:
		animatedSpritee.play("idle")
	else:
		animatedSpritee.play("walk")


func _perform_jump():
	var power = lerp(200.0, JUMP_POWER, jump_charge / MAX_JUMP_CHARGE)
	velocity.y = -power

	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = dir * (power * 0.6)

#
#extends CharacterBody2D
#
#@export var move_speed: float = 1500
#@export var jump_power_initial: float = -100
#@export var jump_horizontal_power_initial: float = 10
#@export var jump_power: float = 0
#@export var is_jumping: bool = false
#
#@export var camera_height: int = 480
#@export var camera_limit_lower: int = 400
#@export var camera_limit_upper: int = 0
#@export var was_high_fall: bool = false
#
#var jump_held_time: float = 0.0 
#var last_direction: float
#
#signal change_camera_pos
#
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#
#func _ready() -> void:
	#floor_max_angle = deg_to_rad(20)
	#
#func _physics_process(delta: float) -> void:
	#get_animation()
	#if velocity.y > 1000:
		#was_high_fall = true
		#
	#if is_jumping:
		#if velocity.x == 0:
			#if last_direction < 0 :
				#last_direction = 5
			#elif last_direction > 0:
				#last_direction = -5
		#velocity.x = last_direction * move_speed * delta
	#else:
		#velocity.x = get_input_velocity() * move_speed * delta
		#
	#if not is_on_floor() && !stun:
		#velocity.y += (gravity * 3) * delta
		#if velocity.y > 0:
			#$AnimatedSprite2D.animation = "charge"
			#
	#if is_on_floor():
		#is_jumping = false
		#
		#if was_high_fall:
			#start_stun_phase()
#
	#if Input.is_action_pressed("jumping_move") and is_on_floor():
		#jump_held_time += .2
		#$AnimatedSprite2D.animation = "charge"
		#
		#if jump_held_time > 10:
			#start_jump()
			#
	#if Input.is_action_just_released("jumping_move") and is_on_floor():
		#start_jump()
	#
	#move_camera_to_match_player()
	#move_and_slide()
	#
#func move_camera_to_match_player():
	#if position.y < camera_limit_upper:
		#camera_limit_lower -= camera_height
		#camera_limit_upper -= camera_height
		#change_camera_pos.emit(camera_limit_upper)
		#
	#if position.y < camera_limit_lower:
		#camera_limit_lower += camera_height
		#camera_limit_upper += camera_height
		#change_camera_pos.emit(camera_limit_upper)
	#
#func start_jump():
	#last_direction = 0
	#if Input.is_action_just_released("move_right") || Input.is_action_pressed("move_right"):
		#last_direction = jump_horizontal_power_initial
	#if Input.is_action_just_released("move_left") || Input.is_action_pressed("move_left"):
		#last_direction = -jump_horizontal_power_initial
		#
	#$AnimatedSprite2D.flip_h = last_direction < 0
	#
	#is_jumping = true
	#velocity.y = jump_power_initial * jump_held_time
	#velocity.x = last_direction * (move_speed / 100)
	#
	#jump_power = jump_power_initial
	#jump_held_time = 0
#
#func get_animation():
	#if !jump_held_time:
		#var animation = "idle"
		#if is_on_floor() and velocity.x != 0:
			#animation = "walk"
			#$AnimatedSprite2D.flip_h = last_direction < 0
		#elif !is_on_floor():
			#animation = "Jumping_move"
			#
		#$AnimatedSprite2D.animation = animation
		#
#func get_input_velocity():
	#var horizontal := 0.0
	#if Input.is_action_pressed("move_left") && jump_held_time == 0 && !is_jumping && !stun:
		#horizontal = -8
		#last_direction = -jump_horizontal_power_initial
	#if Input.is_action_pressed("move_right") && jump_held_time == 0 && !is_jumping && !stun:
		#horizontal = 8
		#last_direction = jump_horizontal_power_initial
		#
	#return horizontal
	#
 #func start_stun_phase():
	#was_high_fall = false
	#stun = true
	#$AnimatedSprite2D.animation = "charge"
	#$TimerStun.start()
#
#
#func _on_timer_stun_timeout() -> void:
	#stun = false
	#$AnimatedSprite2D.animation = "idle"
