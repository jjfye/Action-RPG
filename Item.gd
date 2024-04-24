extends Node

func _process(delta):
	if State.item_found == true:
		queue_free()
