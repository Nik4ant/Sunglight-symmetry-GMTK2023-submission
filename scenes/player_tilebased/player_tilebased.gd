extends AnimatableBody2D
class_name Player

@export var tile_size: int = 16
@onready var sprite: Sprite2D = %sprite


func _ready():
	pass

func _physics_process(_delta):
	if Input.is_action_just_pressed("player_restrart"):
		_death()
	
	var input: Vector2 = Vector2(
		int(Input.is_action_just_pressed("player_right")) - int(Input.is_action_just_pressed("player_left")),
		int(Input.is_action_just_pressed("player_down")) - int(Input.is_action_just_pressed("player_up")),
	)
	
	if input != Vector2.ZERO:
		sprite.flip_h = input.x < 0 or (sprite.flip_h and input.x == 0)
		var offset: Vector2 = input * tile_size
		
		if not test_move(global_transform, offset):
			global_position += offset
		else:
			pass

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
