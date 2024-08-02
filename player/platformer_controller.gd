extends CharacterBody2D

class_name PlatformerController2D

signal state_changed(state)
signal jumped(is_ground_jump: bool)
signal double_jumped
signal hit_ground()

@export var input_left: String = "move_left"
@export var input_right: String = "move_right"
@export var input_jump: String = "jump"

const DEFAULT_MAX_JUMP_HEIGHT = 48
const DEFAULT_MIN_JUMP_HEIGHT = 16
const DEFAULT_DOUBLE_JUMP_HEIGHT = 64
const DEFAULT_JUMP_DURATION = 0.5

@export var max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT: 
	set = set_max_jump_height
@export var min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT: 
	set = set_min_jump_height
@export var double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT: 
	set = set_double_jump_height
@export var jump_duration: float = DEFAULT_JUMP_DURATION:
	set = set_jump_duration

@export var falling_gravity_multiplier = 1.5
@export var max_jump_amount = 1
@export var max_acceleration = 5000
@export var friction = 20
@export var can_hold_jump: bool = false
@export var coyote_time: float = 0.1
@export var jump_buffer: float = 0.1

var default_gravity: float
var jump_velocity: float
var double_jump_velocity: float
var release_gravity_multiplier: float

var jumps_left: int
var holding_jump := false

enum JumpType { NONE, GROUND, AIR, WALL }
var current_jump_type: JumpType = JumpType.NONE

var _was_on_ground: bool
var acc = Vector2()

@onready var is_coyote_time_enabled = coyote_time > 0
@onready var is_jump_buffer_enabled = jump_buffer > 0
@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()

@export var wall_jump_force = 300
var _is_on_wall = false

enum Direction { LEFT = -1, RIGHT = 1 }
#var current_direction: Direction = Direction.RIGHT
var current_direction:= Vector2.RIGHT

enum PlayerState { IDLE, RUNNING, JUMPING, FALLING, WALL_JUMPING }
var current_state: PlayerState = PlayerState.IDLE

func _init():
	initialize_jump_parameters()

func _ready():
	if is_coyote_time_enabled:
		add_child(coyote_timer)
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true

	if is_jump_buffer_enabled:
		add_child(jump_buffer_timer)
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true

func _input(_event):
	acc.x = 0
	if Input.is_action_pressed(input_left):
		acc.x = -max_acceleration
		current_direction = Vector2.LEFT

	if Input.is_action_pressed(input_right):
		acc.x = max_acceleration
		current_direction = Vector2.RIGHT

	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		start_jump_buffer_timer()
		if (not can_hold_jump and can_ground_jump()) or can_double_jump() or _is_on_wall:
			jump()

	if Input.is_action_just_released(input_jump):
		holding_jump = false

func _physics_process(delta):
	_is_on_wall = is_on_wall()

	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()

	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		if is_jump_buffer_timer_running() and not can_hold_jump:
			jump()
		hit_ground.emit()

	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump:
			jump()

	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity

	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta

	_was_on_ground = is_feet_on_ground()
	move_and_slide()

	update_player_state()

func update_player_state():
	var prev_state = current_state
	if velocity.y < 0:
		if _is_on_wall:
			current_state = PlayerState.WALL_JUMPING
		else:
			current_state = PlayerState.JUMPING
	elif velocity.y > 0 and not is_feet_on_ground():
		current_state = PlayerState.FALLING
	elif velocity.x != 0:
		current_state = PlayerState.RUNNING
	else:
		current_state = PlayerState.IDLE
	
	if current_state != prev_state:
		state_changed.emit(current_state)

func set_max_jump_height(value):
	max_jump_height = value
	initialize_jump_parameters()

func set_min_jump_height(value):
	min_jump_height = value
	initialize_jump_parameters()

func set_double_jump_height(value):
	double_jump_height = value
	initialize_jump_parameters()

func set_jump_duration(value):
	jump_duration = value
	initialize_jump_parameters()

func initialize_jump_parameters():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(jump_velocity, min_jump_height, default_gravity)

func start_coyote_timer():
	if is_coyote_time_enabled:
		coyote_timer.start()

func start_jump_buffer_timer():
	if is_jump_buffer_enabled:
		jump_buffer_timer.start()

func is_coyote_timer_running() -> bool:
	return is_coyote_time_enabled and not coyote_timer.is_stopped()

func is_jump_buffer_timer_running() -> bool:
	return is_jump_buffer_enabled and not jump_buffer_timer.is_stopped()

func can_ground_jump() -> bool:
	return jumps_left > 0 and current_jump_type == JumpType.NONE or is_coyote_timer_running()

func can_double_jump() -> bool:
	return jumps_left > 0 and not is_feet_on_ground() and coyote_timer.is_stopped()

func is_feet_on_ground() -> bool:
	return is_on_floor() and default_gravity >= 0 or is_on_ceiling() and default_gravity <= 0

func jump():
	if can_double_jump():
		double_jump()
	elif _is_on_wall:
		wall_jump()
	else:
		ground_jump()

func double_jump():
	if jumps_left == max_jump_amount:
		jumps_left -= 1

	velocity.y = -double_jump_velocity
	current_jump_type = JumpType.AIR
	jumps_left -= 1
	jumped.emit(false)
	double_jumped.emit()

func ground_jump():
	velocity.y = -jump_velocity
	current_jump_type = JumpType.GROUND
	jumps_left -= 1
	coyote_timer.stop()
	jumped.emit(true)

func wall_jump():
	velocity = Vector2(wall_jump_force * -current_direction.x, -jump_velocity)
	current_jump_type = JumpType.AIR
	jumped.emit(true)

func apply_gravity_multipliers_to(gravity) -> float:
	if velocity.y * sign(default_gravity) > 0:
		gravity *= falling_gravity_multiplier
	elif velocity.y * sign(default_gravity) < 0:
		if not holding_jump and not current_jump_type == JumpType.AIR:
			gravity *= release_gravity_multiplier
	return gravity

func calculate_gravity(p_max_jump_height, p_jump_duration) -> float:
	return (2 * p_max_jump_height) / pow(p_jump_duration, 2)

func calculate_jump_velocity(p_max_jump_height, p_jump_duration) -> float:
	return (2 * p_max_jump_height) / p_jump_duration

func calculate_jump_velocity2(p_max_jump_height, p_gravity) -> float:
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)

func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity) -> float:
	var release_gravity = pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity

func calculate_friction(time_to_max) -> float:
	return 1 - (2.30259 / time_to_max)

func calculate_speed(p_max_speed, p_friction) -> float:
	return (p_max_speed / p_friction) - p_max_speed
