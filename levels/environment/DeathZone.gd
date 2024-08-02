extends Area2D

@export var collision_size := Vector2i(16,16)


# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape.size = collision_size
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_death_zone_body_entered(body):
	
	if body in get_tree().get_nodes_in_group("Player"):
		print("Player entered death zone")
		body.die()
	pass # Replace with function body.
