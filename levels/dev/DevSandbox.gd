extends Node2D

@onready var player_spawn = $PlayerSpawn

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().root.ready
	GameManager.set_current_level_scene(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
