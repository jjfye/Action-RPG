extends Sprite2D

const GrassEffect = preload("res://Effects/grass_effect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffect.instantiate()
	var _world = get_tree().current_scene

	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
