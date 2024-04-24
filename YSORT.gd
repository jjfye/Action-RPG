extends Node2D

func _process(delta):
	if State.item_found == true:
		%Item.visible = false
