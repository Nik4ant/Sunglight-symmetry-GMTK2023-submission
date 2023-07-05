extends CharacterBody2D

@export var tile_size: int = 16

func _physics_process(_delta):
	var input: Vector2i = Vector2i(
		int(Input.is_action_just_pressed("player_right")) - int(Input.is_action_just_pressed("player_left")),
		int(Input.is_action_just_pressed("player_down")) - int(Input.is_action_just_pressed("player_up")),
	)
	# TODO: better grid based movement - this one gets stuck on the corners and
	# TODO: switch to animetable body and check collisions manually?
	velocity = tile_size * input
	move_and_slide()
	
