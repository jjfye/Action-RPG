extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))
	play("Animate")

func _on_animated_sprite_2d_animation_finished():
	queue_free()
