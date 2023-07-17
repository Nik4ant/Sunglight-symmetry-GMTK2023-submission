extends AnimatableBody2D
class_name Player

@export var movement_delay_ms: float = 170.0
var last_movement_time: float = 0.0
@export var tile_size: int = 16
@onready var sprite: AnimatedSprite2D = %sprite

@onready var reverse_area: ReverseArea = %reverse_area as ReverseArea
var reverses_left: int = 0
@export var reverse_area_duration: float = 0.3

@onready var reverse_bar: AnimatedSprite2D = get_tree().get_first_node_in_group("reverse_bar")
# SFX
var temp_fix_can_die: bool = true
var is_dead: bool = false
@onready var death_sounds: Array = %death_sfx_list.get_children()
@onready var death_by_arrow: AudioStreamPlayer = %death_by_arrow


func update_reverses(new_value: int, force: bool = false):
	if new_value != 0 or force:
		reverses_left = new_value
		reverse_bar.frame = mini(new_value, 5)

func _physics_process(_delta):
	if is_dead:
		return
	# Restart
	if Input.is_action_just_pressed("player_restrart") and temp_fix_can_die:
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
		int(Input.is_action_pressed("player_right")) - int(Input.is_action_pressed("player_left")),
		int(Input.is_action_pressed("player_down")) - int(Input.is_action_pressed("player_up")),
	)
	
	if input != Vector2.ZERO and not reverse_area.is_active:
		sprite.flip_h = input.x < 0 or (sprite.flip_h and input.x == 0)
		var offset: Vector2 = input * tile_size
		
		if not test_move(global_transform, offset):
			var current_time = Time.get_ticks_msec()
			if current_time - last_movement_time >= movement_delay_ms:
				last_movement_time = current_time
				global_position += offset


func move():
	pass


# Hopefully used by arrow shooter...
func die_by_arrow():
	_death(true)


func _death(killed_by_arrow: bool = false):
	if is_dead:
		return
	
	self.set_physics_process(false)
	is_dead = true
	
	if not killed_by_arrow:
		Globals.play_sound(death_sounds.pick_random(), 0.9, 1.1)
	else:
		Globals.play_sound(death_by_arrow, 0.9, 1.1)
	
	sprite.play("death")
	await sprite.animation_looped
	sprite.animation = "default"
	
	EventBus.player_died.emit()
	
	get_tree().create_timer(0.2).timeout.connect(func(): is_dead = false)


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
