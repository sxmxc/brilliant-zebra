extends VBoxContainer

@onready var state_label = $StateLabel
@onready var double_jump_label = $DoubleJumpLabel
@onready var direction_label = $DirectionLabel
@onready var can_jump_label = $CanJumpLabel
@onready var on_ground_label = $OnGroundLabel
@onready var hit_ground_label = $HitGroundLabel

var player: Player
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().root.ready
	player = get_node("%Player")
	if !player:
		print_debug("No player found!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player:
		can_jump_label.set_text("Can jump: %s" % player.can_ground_jump())
		double_jump_label.set_text("Can double jump: %s" % player.can_double_jump())
		on_ground_label.set_text("On ground: %s" % player.is_on_floor())
		hit_ground_label.set_text("On wall: %s" % player.is_on_wall())
		direction_label.set_text("Player Direction: %s" % player.current_direction.x)
		state_label.set_text("Player State: %s" % player.PlayerState.keys()[player.current_state])
	pass

func set_player(new):
	player = new
