extends Control

@onready var title_label = %TitleLabel as Label
@onready var menu_options = %MenuOptions
@onready var menu_cam = %MenuCam as Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in menu_options.get_children():
		child.visible = false
	menu_cam.zoom = Vector2(.01,.01)
	display_title()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func display_title():
	var tween = get_tree().create_tween()
	tween.tween_property(menu_cam, "zoom", Vector2(1,1), 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(display_menu_options)

func display_menu_options():
	for child in menu_options.get_children():
		child.visible = true
		await get_tree().create_timer(1).timeout
	pass
