extends AnimatableBody2D
class_name Player

@export var tile_size: int = 16
@onready var sprite: Sprite2D = %sprite

@onready var reverse_area: ReverseArea = %reverse_area as ReverseArea
var reverses_left: int = 0
@export var reverse_area_duration: float = 0.5

@onready var reverse_bar: AnimatedSprite2D = get_tree().get_first_node_in_group("reverse_bar")


func update_reverses(new_value: int, force: bool = false):
	if new_value != 0 or force:
		reverses_left = new_value
		reverse_bar.frame = mini(new_value, 5)

func _physics_process(_delta):
	# Restart
	if Input.is_action_just_pressed("player_restrart"):
		_death()
	# Reversing
	if Input.is_action_just_pressed("player_reverse") and reverses_left > 0:
		update_reverses(reverses_left - 1, reverses_left == 1)
		
		togle_reverse_area()
		get_tree().create_timer(reverse_area_duration).timeout.connect(
			func():
				# If area wasn't disabled, disable it manually after some time
				if reverse_area.is_active:
					reverse_area.set_active_state(false)
		)
	
	var input: Vector2 = Vector2(
		int(Input.is_action_just_pressed("player_right")) - int(Input.is_action_just_pressed("player_left")),
		int(Input.is_action_just_pressed("player_down")) - int(Input.is_action_just_pressed("player_up")),
	)
	
	if input != Vector2.ZERO:
		reverse_area.set_active_state(false)
		
		sprite.flip_h = input.x < 0 or (sprite.flip_h and input.x == 0)
		var offset: Vector2 = input * tile_size
		
		if not test_move(global_transform, offset):
			global_position += offset


func _death():
	# TODO: animation + sound
	EventBus.player_died.emit()


func _on_hitbox_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int):
	if body is TileMap:
		var tilemap = body as TileMap
		# 1) Check which tile was hit
		var tile_cords: Vector2i = tilemap.get_coords_for_body_rid(body_rid)
		# 2) Check all tiles with those coordinates on all layers
		for layer_index in tilemap.get_layers_count():
			# 3) If there is an enemy tile - death
			var tile_data = tilemap.get_cell_tile_data(layer_index, tile_cords)
			if tile_data is TileData and tile_data.get_custom_data("is_enemy"):
				_death()


func togle_reverse_area():
	reverse_area.set_active_state(not reverse_area.is_active)
