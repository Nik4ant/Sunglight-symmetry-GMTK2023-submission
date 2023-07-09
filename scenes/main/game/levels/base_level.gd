extends Node2D
class_name Level

signal level_finished(next_level: Level, next_spawnpoint: Vector2)

@export var exit_door: Door
# For respawn
@export var spawnpoint_marker: Marker2D
@export var reverses_for_level: int = 0
# Either next level or end
## Path to the next scene
@export_file("*.tscn") var next_scene_path: String
## If true next_scene_path won't be treated as Level class
@export var is_last_level: bool = false

# TODO: try ResourceLoader later. 
# UPD: nope :)
@onready var next_scene: PackedScene = load(next_scene_path)


func _ready():
	assert(is_instance_valid(spawnpoint_marker), "ASSERT! Forgot spawnpoint")
	assert(is_instance_valid(exit_door), "ASSERT! Forgot exit door")
	
	exit_door.player_exited.connect(_switch)

func _switch():
	if is_last_level:
		self.call_deferred("queue_free")
		# FIXME: wierd texture error
		get_tree().change_scene_to_packed(next_scene)
	else:
		var next_level: Level = next_scene.instantiate() as Level
		# For [whatever] reason global_position is just (0, 0) 
		# while position has the actual value
		level_finished.emit(next_scene, next_level, next_level.spawnpoint_marker.position)
