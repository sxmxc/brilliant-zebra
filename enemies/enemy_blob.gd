extends Enemy

var target : CharacterBody2D = null

func _physics_process(delta):
	if target:
		velocity.x = lerp(velocity.x, position.direction_to(target.position).x * SPEED, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	super._physics_process(delta)


func _on_visible_on_screen_notifier_2d_screen_exited():
	visible = false
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_entered():
	visible = true
	pass # Replace with function body.


func _on_view_area_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		target = body as CharacterBody2D
	pass # Replace with function body.


func _on_view_area_body_exited(body):
	if body in get_tree().get_nodes_in_group("Player"):
		target = null
	pass # Replace with function body.
