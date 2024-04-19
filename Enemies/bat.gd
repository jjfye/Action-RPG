extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var FRICTION = 200
@export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

@onready var sprite = $AnimatedSprite
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var softCollision = $SoftCollision
@onready var wandererController = $WandererController
@onready var animationPlayer = $AnimationPlayer

var state = IDLE

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, 250 * delta)
	move_and_slide()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
			
			if wandererController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			seek_player()
			if wandererController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wandererController.target_position, delta)
			
			if global_position.distance_to(wandererController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
				
			sprite.flip_h = velocity.x < 0
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move_and_slide()

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wandererController.start_wanderer_timer(randi_range(1, 3))
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	velocity = area.knockback_vector * 120
	hurtbox.create_hitEffect()
	hurtbox.start_invincibility(0.4)


func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
