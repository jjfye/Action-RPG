extends BaseDialogueTestScene

@onready var player = $YSORT/Player

func _ready():
	var balloon = load("res://Dialogue Balloon/balloon.tscn").instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, title)
	player.set_physics_process(false)
	emit_signal("player")
