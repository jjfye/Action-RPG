extends Sprite2D


@onready var actionable: Area2D = $Actionable
@onready var sprite = $Sprite2D

func _physics_process(delta):
	if actionable.acti
		sprite.visible = false
		
