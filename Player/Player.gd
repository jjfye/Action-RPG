extends CharacterBody2D

const PlayerHurtSound = preload("res://Player/player_hurt_sound.tscn")

@export var FRICTION = 500
@export var ACCELERATION = 1000
@export var ROLL_SPEED = 105
@export var MAX_SPEED = 100

enum {
	MOVE,
	ROLL,
	ATTACK,
	PAUSE
}

var state = MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var goodBat_in_range = false
var in_item_detection = false
var item_detected = false
var actionable = Actionable

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var swordHitbox = $HitboxPivot/SwordHitbox
@onready var hurtbox = $Hurtbox
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer
@onready var actionable_finder: Area2D = $ActionableFinder


func _ready():
	swordHitbox.knockback_vector = roll_vector
	self.stats.connect("no_health", queue_free)
	DialogueManager.connect("dialogue_ended", dialogue_exited)

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)
		PAUSE:
			pass
			
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move_and_slide()

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			if item_detected:
				State.item_found = true
			return

func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hitEffect()
	var playerHurtSound = PlayerHurtSound.instantiate()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")
	
func _on_hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
	
func dialogue_exited():
	state = MOVE

func _on_actionable_item_area_entered(area):
	item_detected = true

func _on_actionable_item_area_exited(area):
	item_detected = false
