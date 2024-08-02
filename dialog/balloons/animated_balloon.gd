extends BalloonCanvas


@onready var animation_player = $AnimationPlayer
	
func balloon_down():
	animation_player.play("balloon_down")
	await animation_player.animation_finished
	return
