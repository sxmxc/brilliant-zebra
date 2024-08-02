extends TextureRect

@onready var life_icon_container = $HudContainer/LifeContainer/LifeIconContainer

@export var life_container_full : Texture2D
@export var life_container_empty : Texture2D
var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().root.ready
	player = get_node("%Player")
	for child in life_icon_container.get_children():
		child.queue_free()
	if player:
		for life in player.MAX_HEALTH:
			var texture = TextureRect.new()
			if life < player.current_health:
				texture.set_texture(life_container_full)
			else:
				texture.set_texture(life_container_empty)
			life_icon_container.add_child(texture)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
