class_name Player extends PlatformerController2D

#signal direction_changed(dir)
#signal velocity_changed(vel)
signal damage_taken(amount)
signal player_died

@onready var sprite = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_mode = animation_tree.get("parameters/playback")
@onready var spark_particles = $Sparks
@onready var camera = $Camera2D as Camera2D
@onready var jump_cloud = $JumpCloud
@onready var trail = $Trail

var dying : bool = false


@export var MAX_HEALTH = 3
var current_health = 3

func _ready():
	super._ready()
	state_changed.connect(update_animation)
	jumped.connect(_on_jump)

func die():
	if dying:
		return
	dying = true
	player_died.emit()
	trail.set_expiration(30)
	trail.reparent(get_parent())
	trail.show_behind_parent = false
	trail.show_on_top = true

	queue_free()
	GameManager.spawn_player()

func take_damage():
	current_health -= 1
	damage_taken.emit(1)
	if current_health <= 0:
		die()

func _physics_process(delta):
	super._physics_process(delta)
	animation_tree.set('parameters/Walking/blend_position', current_direction.x)
	animation_tree.set('parameters/Idle/blend_position', current_direction.x)
	animation_tree.set('parameters/Falling/blend_position', current_direction.x)
	animation_tree.set('parameters/Jumping/blend_position', current_direction.x)
	animation_tree.set('parameters/WallSlide/blend_position', current_direction.x)

func update_animation(state: PlayerState):
	match state:
		PlayerState.IDLE:
			animation_mode.travel("Idle")
			pass
		PlayerState.RUNNING:
			animation_mode.travel("Walking")
			pass
		PlayerState.JUMPING:
			animation_mode.travel("Jumping")
			pass
		PlayerState.FALLING:
			animation_mode.travel("Falling")
			pass
		PlayerState.WALL_JUMPING:
			animation_mode.travel("WallSlide")
			pass

func _on_jump(on_ground):
	if !on_ground:
		jump_cloud.emitting = true
