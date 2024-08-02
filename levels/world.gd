class_name World extends Node2D

signal world_setup_complete

@onready var level0_entities : LDTKEntityLayer = $Level_0/Entities
@onready var level0_traps : LDTKEntityLayer = $Level_0/Traps
const DEATH_ZONE = preload("res://levels/environment/death_zone.tscn")
const SPIKE_TRAP = preload("res://levels/environment/spike_trap.tscn")

var player_spawn: Marker2D


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_current_world_node(self)
	setup_world()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func setup_world():
	print("Setting up the world")
	print("Checking for player spawn")
	for entity in level0_entities.entities:
		if entity.identifier == "Spawn":
			var marker = Marker2D.new()
			$Level_0.add_child(marker)
			marker.position = $Level_0/IntGrid.map_to_local($Level_0/IntGrid.local_to_map(entity.position)) 
			player_spawn = marker
			print("Player spawn point discovered")
			break
	print("Checking for killzones")		
	for entity in level0_entities.entities:
		if entity.identifier == "Death":
			var killzone = DEATH_ZONE.instantiate()
			killzone.collision_size = entity.size
			$Level_0.add_child(killzone)
			killzone.position = $Level_0/IntGrid.map_to_local($Level_0/IntGrid.local_to_map(entity.position)) 
			print("Killzone discovered")
	print("Checking for traps")		
	for entity in level0_traps.entities:
		if entity.identifier == "Spikes":
			var spike_trap = SPIKE_TRAP.instantiate()
			$Level_0.add_child(spike_trap)
			spike_trap.position = $Level_0/IntGrid.map_to_local($Level_0/IntGrid.local_to_map(entity.position)) 
			print("Trap discovered")
	print("World setup complete")
	world_setup_complete.emit()
