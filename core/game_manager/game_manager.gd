extends Node2D

@onready var animation_player = $AnimationPlayer

const LOAD_SCREEN = preload("res://core/game_manager/load_screen.tscn")

var _scene_to_load = ""
var _scene_loading := false
var _current_load_node : LoadScreen = null
var _load_progress : Array[float] = []

var prefab_dict = {
	"player": preload("res://player/player.tscn")
}

var world_dict = {
	"forest_osh": "res://levels/ldtk/forest_of_shining_hues/forest_of_shinning_hues.tscn"
}

var _current_world_node : World

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _scene_loading:
		update_loading_status()
	pass

func spawn_player():
	var new_player = prefab_dict.player.instantiate() as Player
	new_player.position = _current_world_node.player_spawn.position
	_current_world_node.call_deferred("add_child",new_player)
	await new_player.ready
	#_current_world_node.get_node("%DevVBox").set_player(new_player)
	new_player.name = "Player"
	#new_player.camera.make_current()
	pass

func set_current_world_node(node: World):
	_current_world_node = node
	#node.world_setup_complete.connect(spawn_player)

func get_current_world_node() -> World:
	return _current_world_node
	
func load_scene(scene: String):
	animation_player.play("fade_out")
	await animation_player.animation_finished
	_scene_to_load = scene
	get_tree().change_scene_to_packed(LOAD_SCREEN)

func on_load_screen_ready():
	_current_load_node = get_tree().current_scene
	animation_player.play("fade_in")
	start_loading()
	
func start_loading():
	_scene_loading = true
	ResourceLoader.load_threaded_request(_scene_to_load)

func update_loading_status():
	var load_status = ResourceLoader.load_threaded_get_status(_scene_to_load, _load_progress)
	print("Load status %s" % load_status)
	match load_status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("Error loading resource. Resource is invalid")
			_scene_loading = false
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			if _current_load_node != null:
				_current_load_node.progress_bar.value = _load_progress[0] * 100
				_current_load_node.label.text = "Loading: " + str(_load_progress[0] * 100) + "%"
			print("Load Progress: " , _load_progress[0]) 
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			print("Error loading resource. Something went terribly wrong")
			_scene_loading = false
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			print("Scene loaded succesfully: ", _load_progress[0])
			_scene_loading = false
			var packed_scene = ResourceLoader.load_threaded_get(_scene_to_load)
			get_tree().change_scene_to_packed(packed_scene)
