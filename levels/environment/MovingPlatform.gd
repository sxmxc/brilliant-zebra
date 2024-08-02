extends AnimatableBody2D

var at_top := false
@export var max_height := 128
@export var speed := 8
# Called when the node enters the scene tree for the first time.
func _ready():
	move_up()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func move_down():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, position.y + max_height), speed)
	tween.tween_callback(move_up)

func move_up():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, position.y - max_height), speed)
	tween.tween_callback(move_down)
