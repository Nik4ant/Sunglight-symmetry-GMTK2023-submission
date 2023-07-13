extends Area2D
class_name Arrow

@export var speed: float = 2
var is_dead: bool = false
var is_reversed: bool = false
@onready var on_heart_destroyed: AudioStreamPlayer = $heart_go_br


func reverse_state():
	is_reversed = not is_reversed
	if is_reversed:
		$sprite_reversed.visible = true
		$sprite_default.visible = false
	else:
		$sprite_reversed.visible = false
		$sprite_default.visible = true


func destroy_self():
	if not is_dead:
		self.queue_free()
		is_dead = true


func _physics_process(delta):
	global_position.y += speed * delta * Globals.TARGET_FPS


func _on_area_entered(area: Area2D):
	if area.is_in_group("player_hitbox"):
		if not self.is_reversed:
			area.get_parent().die_by_arrow()
		else:
			Globals.play_sound(on_heart_destroyed, 0.9, 1.1)
		destroy_self()
		

func _on_body_entered(body: Node2D):
	if body is TileMap and not body.is_in_group("PLEASE_HELP"):
		destroy_self()


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		var tile_cords: Vector2i = body.get_coords_for_body_rid(body_rid)
		var tile_data = body.get_cell_tile_data(0, tile_cords)
		if tile_data is TileData:
			if not tile_data.get_custom_data("is_enemy") and not body.is_in_group("PLEASE_HELP"):
				destroy_self()
		else:
			destroy_self()
