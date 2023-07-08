extends Node2D

@onready var current_level_container: Node2D = %current_level
var current_level: Level

@onready var player: Player = %player
var latest_spawnpoint: Vector2


func _ready():
	current_level = current_level_container.get_child(0) as Level
	latest_spawnpoint = player.global_position
	current_level.level_finished.connect(switch_level_to, CONNECT_ONE_SHOT)


func switch_level_to(new_level: Level, new_spawnpoint: Vector2) -> void:
	# Player pos
	latest_spawnpoint = new_spawnpoint
	player.global_position = new_spawnpoint
	
	player.set_physics_process(false)
	# Switch levels
	for child in current_level_container.get_children():
		child.queue_free()
	
	current_level = new_level
	current_level_container.call_deferred("add_child", new_level)
	
	player.set_physics_process(true)
