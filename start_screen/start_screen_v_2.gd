extends Node2D

@onready var menu_options = %MenuOptions
@onready var menu_cam = %PhantomMenuCam
@onready var options_cam = %PhantomOptionsCam

var menu_shown := false

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in menu_options.get_children():
		child.visible = false
	#menu_cam.set_zoom(Vector2(.01,.01))
	display_title()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !menu_shown and Input.is_action_pressed("accept"):
		display_menu_options()
		%PressStartLabel.hide()
	if menu_shown and Input.is_action_just_pressed("ui_cancel"):
		hide_menu_options()
		%PressStartLabel.show()
	pass
	
func display_title():
	#var tween = get_tree().create_tween()
	#tween.tween_property(menu_cam, "zoom", Vector2(1,1), 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_callback(display_menu_options)
	menu_cam.set_zoom(Vector2.ONE)
	await menu_cam.tween_completed
	%PressStartLabel.show()
	

func display_menu_options():
	for child in menu_options.get_children():
		child.visible = true
		await get_tree().create_timer(.5).timeout
	menu_shown = true
	pass

func hide_menu_options():
	for child in menu_options.get_children():
		child.visible = false
	menu_shown = false


func _on_options_button_pressed():
	options_cam.set_priority(20)
	menu_cam.set_priority(0)
	pass # Replace with function body.


func _on_cancel_button_pressed():
	options_cam.set_priority(0)
	menu_cam.set_priority(20)
	pass # Replace with function body.


func _on_press_start_label_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			%PressStartLabel.hide()
			display_menu_options()
			
	pass # Replace with function body.


func _on_new_game_button_pressed():
	GameManager.load_scene("res://cutscenes/intro_cutscene.tscn")
	pass # Replace with function body.


func _on_load_test_pressed():
	GameManager.load_scene("res://test/chonky_test.tscn")
	pass # Replace with function body.
