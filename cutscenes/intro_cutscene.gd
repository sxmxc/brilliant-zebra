extends Control
@onready var scene_balloon
@onready var scene_action = $SceneAction
@onready var animation_player = $AnimationPlayer
const HALFSCREEN_BALLOON = preload("res://dialog/balloons/halfscreen_balloon.tscn")
const ANIMATED_BALLOON = preload("res://dialog/balloons/animated_balloon.tscn")
const MAIN = preload("res://dialog/main.dialogue")


var intro_markers := ["intro","scene_1","outro"]
var current_marker := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scene_balloon = ANIMATED_BALLOON.instantiate()
	add_child(scene_balloon)
	scene_balloon.start(MAIN, intro_markers[current_marker], [self])
	DialogueManager.dialogue_ended.connect(on_dialog_ended)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func action_fade_in():
	animation_player.play("action_fade_in")
	await animation_player.animation_finished
	return
	
func balloon_down():
	scene_balloon.balloon_down()
	return

func on_dialog_ended(dialog):
	current_marker += 1
	if current_marker >= intro_markers.size() - 1:
		return
	animation_player.play("fade_in")
	var balloon = HALFSCREEN_BALLOON.instantiate()
	add_child(balloon)
	balloon.start(MAIN, intro_markers[current_marker], [self])
	pass
