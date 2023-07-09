extends Area2D
class_name ReverseArea


# NOTE: PROPER CODE IS FOR LOOSERS, JUST BELIVE!
const ATLAS_CORDS: Dictionary = {
	"spike": Vector2i(3, 1),
	"wood_wall": Vector2i(3, 0),
}
const REVERSE_TABLE: Dictionary = {
	"spike": "void",
	"wood_wall": "spike",
}
# Used for vice versa cycles to remember initial state of tiles (wood <--> spike)
# Vector2i: String
#var inital_tiles_state: Dictionary = {
#}

@export var is_active: bool = false
# Sfx
@onready var spikes_to_void: AudioStreamPlayer = %spikes_to_void
@onready var wood_to_spikes: AudioStreamPlayer = %wood_to_spikes

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
	if body is TileMap:
		var tilemap = body as TileMap
		# 1) Check which tile was hit
		var tile_cords: Vector2i = tilemap.get_coords_for_body_rid(body_rid)
		# 2) Check all tiles with those coordinates on all layers
		for layer_index in tilemap.get_layers_count():
			# 3) Reversing any tiles that can be reversed
			var tile_data = tilemap.get_cell_tile_data(layer_index, tile_cords)
			if tile_data is TileData:
				var initial_state = tile_data.get_custom_data("initial_state")
				if initial_state is String and REVERSE_TABLE.has(initial_state):
					# Backup state
					#var one_way_reverse: bool = tile_data.get_custom_data("one_way_reverse")
					#if not one_way_reverse:
					#	inital_tiles_state[tile_cords] = initial_state
					
					var new_state: String = REVERSE_TABLE[initial_state]
					var source_id: int = tilemap.get_cell_source_id(layer_index, tile_cords)
					# LET THE FUN BEGIN
					if new_state == "void":
						Globals.play_sound(spikes_to_void, 0.9, 1.1)
						tilemap.set_cell(layer_index, tile_cords, -1)
						# back to wood
						#if inital_tiles_state.has(tile_cords):
						#	tilemap.set_cell(layer_index, tile_cords, source_id, ATLAS_CORDS["wood_wall"])
						#else:
							# remove tile
						#	tilemap.set_cell(layer_index, tile_cords, -1)
					else:
						# replace with [whatever]
						Globals.play_sound(wood_to_spikes, 0.9, 1.1)
						tilemap.set_cell(layer_index, tile_cords, source_id, ATLAS_CORDS[new_state])


func _on_area_entered(area: Area2D) -> void:
	if area is PuzzleButton:
		(area as PuzzleButton).reverse()
