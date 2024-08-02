extends CharacterBody2D
class_name Enemy


const SPEED = 50
const JUMP_VELOCITY = -400.0

@export_range(0, 1.0) var friction : float = 0.1
@export_range(0, 1.0) var acceleration = 0.25

@onready var left_edge_ray = $LeftEdgeRay
@onready var right_edge_ray = $RightEdgeRay
@onready var left_wall_ray = $LeftWallRay
@onready var right_wall_ray = $RightWallRay

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
