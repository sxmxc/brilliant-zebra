extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	blink_out()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func blink_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color.WHITE,1)
	tween.tween_callback(blink_out)

func blink_out():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color.TRANSPARENT,1)
	tween.tween_callback(blink_in)
