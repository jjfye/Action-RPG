extends Area2D


var entered = false



func _physics_process(delta):
	print(entered)
	if entered == true:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene_to_file("res://world_2.tscn")
			print("entered")


func _on_area_entered(area):
	entered = true

func _on_area_exited(area):
	entered = false
