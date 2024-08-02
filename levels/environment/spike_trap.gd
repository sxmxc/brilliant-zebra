extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_death_zone_body_entered(body):
	
	if body in get_tree().get_nodes_in_group("Player"):
		print("Player entered death zone")
		if body.dying:
			return
		body.die()
	pass # Replace with function body.
