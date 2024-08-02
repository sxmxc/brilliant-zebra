class_name Trail2D extends Line2D

@export_category('Trail')
@export var length : = 1000
@export var show_on_top := false

@onready var parent : Node2D = get_parent()
var offset : = Vector2.ZERO
var active :bool = true


func _ready() -> void:
	offset = position
	top_level = show_on_top

func _physics_process(_delta: float) -> void:
	if active:
		global_position = Vector2.ZERO

		var point : = parent.global_position + offset
		add_point(point, 0)
		
		if get_point_count() > length:
			remove_point(get_point_count() - 1)

func set_expiration(time: int = 30):
	active = false
	get_tree().create_timer(time).timeout.connect(expire)
	pass

func expire():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 10)
	tween.finished.connect(func(): queue_free())
