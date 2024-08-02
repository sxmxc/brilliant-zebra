extends Area2D

@export var area_pcam: PhantomCamera2D

func _ready() -> void:
	connect("body_entered", _entered_area)
	connect("body_exited", _exited_area)

func _entered_area(body) -> void:
	if body is CharacterBody2D:
		area_pcam.set_priority(20)
		area_pcam.set_follow_target(body)

func _exited_area(body) -> void:
	if body is CharacterBody2D:
		area_pcam.set_priority(0)
		area_pcam.set_follow_target(null)
