extends Node2D
class_name Level

signal level_finished(next_level: Level, next_spawnpoint: Vector2)

@export var level_exit: LevelExit
# For respawn
@export var spawnpoint_marker: Marker2D
# Either next level or end
## Path to the next scene
@export_file("*.tscn") var next_scene_path: String
## If true next_scene_path won't be treated as Level class
@export var is_last_level: bool = false

# TODO: try ResourceLoader later
@onready var next_scene: PackedScene = load(next_scene_path)


func _ready():
	assert(is_instance_valid(spawnpoint_marker), "ASSERT! Forgot spawnpoint")
	assert(is_instance_valid(level_exit), "ASSERT! Forgot level exit")
	level_exit.player_exited.connect(_switch, CONNECT_ONE_SHOT)

func _switch():
	if is_last_level:
		self.call_deferred("queue_free")
		# FIXME: wierd texture error
		get_tree().change_scene_to_packed(next_scene)
	else:
		var next_level: Level = next_scene.instantiate() as Level
		# For [whatever] reason global_position is just (0, 0) 
		# while position has the actual value
		level_finished.emit(next_level, next_level.spawnpoint_marker.position)
