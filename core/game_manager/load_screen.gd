class_name LoadScreen extends Control



@onready var progress_bar = %ProgressBar
@onready var label = $Label

func _enter_tree():
	ready.connect(GameManager.on_load_screen_ready)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
