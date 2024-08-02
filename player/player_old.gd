extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_mode = animation_tree.get("parameters/playback")
@onready var right_ray = $RightWall
@onready var left_ray = $LeftWall
@onready var spark_particles = $Sparks
@onready var camera = $Camera2D as Camera2D

@export_range(0, 1.0) var friction : float = 0.1
@export_range(0, 1.0) var acceleration = 0.25
@export var SPEED = 150.0
@export var RUN_SPEED = 200.0
@export var JUMP_VELOCITY = -300.0
@export var JUMP_BOOST = -200
@export var MAX_JUMPS = 2
@export var MAX_HEALTH = 3
@export var MAX_FALL_VELOCITY = 200

var hit_the_ground = false
var velocity_previous = velocity
var facing = 1
var jumping = false
var can_jump = true
var jump_number = MAX_JUMPS
var jump_boost = 0
var max_health = 6
var current_health = 3
var running := false
var is_wallsliding := false

signal direction_changed(dir)
signal velocity_changed(vel)
signal state_changed(state)
signal damage_taken(amount)
signal player_died

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	#velocity_previous = velocity
	if Input.is_action_pressed("dash"):
		running = true
	else:
		running = false
	# Add the gravity.
	if  !is_on_floor():
		if !jumping:
			coyote_time()
		if velocity.y > 0:
			if nextToWall():
				if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
					is_wallsliding = true
					animation_mode.travel("WallSlide")
					spark_particles.emitting = true
					emit_signal("state_changed", "WallSlide")
				else:
					is_wallsliding = false
			else:
				animation_mode.travel("Falling")
				emit_signal("state_changed", "Falling")
		else:
			animation_mode.travel("Jumping")
			emit_signal("state_changed", "Jumping")
		hit_the_ground = false
		if is_wallsliding:
			velocity.y += (100) * delta
		else:
			velocity.y += gravity * delta
		

	if (is_on_floor() or is_wallsliding):
		can_jump = true
		if not hit_the_ground and is_on_floor():
			hit_the_ground = true
			jumping = false
			jump_number = MAX_JUMPS
			spark_particles.emitting = false
			velocity.y = 0
			jump_boost = 0
			is_wallsliding = false

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		if facing != direction:
			emit_signal("direction_changed", direction)
		facing = direction
		
		if !jumping and !nextToWall():
			animation_mode.travel("Walking")
			emit_signal("state_changed", "Walking")
		if running:
			velocity.x = lerp(velocity.x, direction * RUN_SPEED, acceleration)
		else:
			velocity.x = lerp(velocity.x, direction * SPEED, acceleration)
		animation_tree.set('parameters/Walking/blend_position', direction)
		animation_tree.set('parameters/Idle/blend_position', direction)
		animation_tree.set('parameters/Falling/blend_position', direction)
		animation_tree.set('parameters/Jumping/blend_position', direction)
		animation_tree.set('parameters/WallSlide/blend_position', direction)
	else:
		velocity.x = lerp(velocity.x, float(0), friction)
		if is_on_floor():
			animation_tree.set('parameters/Idle/blend_position', facing)
			animation_mode.travel("Idle")
			emit_signal("state_changed", "Idle")

	move_and_slide()
		# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if can_jump:
			if is_wallsliding:
				jump_boost = JUMP_BOOST
			else:
				jump_boost = 0
			jumping = true
			velocity.y = JUMP_VELOCITY + jump_boost
			jump_number -= 1
			if jump_number <= 0:
				can_jump = false
	emit_signal("velocity_changed", velocity)

func nextToWall():
	return nextToRightWall() or nextToLeftWall()

func nextToRightWall():
	return right_ray.is_colliding()

func nextToLeftWall():
	return left_ray.is_colliding()

func coyote_time():
	var timer = get_tree().create_timer(.2)
	timer.connect("timeout", func(): can_jump = false)

func die():
	emit_signal("player_died")
	GameManager.spawn_player()
	queue_free()

func take_damage():
	current_health -= 1
	emit_signal("damage_taken", 1)
	if current_health <= 0:
		die()
