extends Area2D

@export var dialogue_resource : DialogueResource
@export var dialogue_start: String = "start"
@onready var player = $"../../Player"

signal player_movement

func action():
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
	player.state = "PAUSE"
	emit_signal("player_movement")
