extends AnimatableBody2D
class_name Player

@export var tile_size: int = 16

func _ready():
	pass

func _physics_process(_delta):
	var input: Vector2 = Vector2(
		int(Input.is_action_just_pressed("player_right")) - int(Input.is_action_just_pressed("player_left")),
		int(Input.is_action_just_pressed("player_down")) - int(Input.is_action_just_pressed("player_up")),
	)
	
	if input != Vector2.ZERO:
		var offset: Vector2 = input * tile_size
		if not test_move(global_transform, offset):
			global_position += offset
