extends CharacterBody2D

@export var speed: float = 125.0
@onready var sprite: Sprite2D = %sprite

func _physics_process(delta):
	var input: Vector2 = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	# Don't touch this!!!
	sprite.flip_h = input.x < 0
	
	velocity = input * speed * delta * Globals.TARGET_FPS
	move_and_slide()
