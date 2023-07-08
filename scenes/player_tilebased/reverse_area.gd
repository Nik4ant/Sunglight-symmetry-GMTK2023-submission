extends Area2D
class_name ReverseArea


const REVERSE_TABLE: Dictionary = {
	0: "spike",
	1: "wood_wall",
}

@export var is_active: bool = false


func _ready():
	set_active_state(is_active)


func set_active_state(state: bool) -> void:
	is_active = state
	if not is_active:
		self.visible = false
		self.monitoring = false
		self.monitorable = false
	else:
		self.visible = true
		self.monitoring = true
		self.monitorable = true


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int):
	if not is_active:
		return
	# TODO: HANDLE AREAS AS WELL
	print("REVERSING BODY: ", body)
	if body is TileMap:
		var tilemap = body as TileMap
		# 1) Check which tile was hit
		var tile_cords: Vector2i = tilemap.get_coords_for_body_rid(body_rid)
		# 2) Check all tiles with those coordinates on all layers
		for layer_index in tilemap.get_layers_count():
			# 3) Reversing any tiles that can be reversed
			var tile_data = tilemap.get_cell_tile_data(layer_index, tile_cords)
			if tile_data is TileData and tile_data.get_custom_data("is_enemy"):
				pass
