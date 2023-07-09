extends Node2D

#region Pause menu
var is_pause_menu_opened: bool = false
@onready var pause_button: TextureButton = %pause_button
@onready var pause_menu: PauseMenu = %pause_menu as PauseMenu
#endregion

@onready var current_level_container: Node2D = %current_level
var current_level: Level
var current_level_scene: PackedScene

@onready var player: Player = %player
var latest_spawnpoint: Vector2
# Door info
@onready var green_buttons_info: Label = %green_buttons_info
@onready var blue_buttons_info: Label = %blue_buttons_info


func _ready():
	# Pause menu
	pause_button.pressed.connect(
		func():
			if not is_pause_menu_opened:
				togle_pause(true)
	)
	pause_menu.closed.connect(
		func():
			togle_pause(false)
	)
	# Level
	current_level = current_level_container.get_child(0) as Level
	current_level.level_finished.connect(switch_level_to, CONNECT_ONE_SHOT)
	# Respawn
	latest_spawnpoint = player.global_position
	EventBus.player_died.connect(reset_current_level)


func _process(_delta):
	if Input.is_action_just_pressed("player_menu"):
		togle_pause(not is_pause_menu_opened)

func reset_current_level():
	player.update_reverses(current_level.reverses_for_level)
	player.global_position = latest_spawnpoint
	# This is stupid but it works...
	if current_level_scene:
		# PLEASE WORK! PLEASE! AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		# YEEEEEEEEEEEEEEEEEEEEEES! IT WORKS! I CAN GO SLEEP NOW!
		switch_level_to(current_level_scene, current_level_scene.instantiate(), latest_spawnpoint)
#		current_level_container.remove_child(current_level)
#		await get_tree().physics_frame
#		current_level.queue_free()
#		await get_tree().physics_frame
#		current_level = current_level_scene.instantiate()
#		await get_tree().physics_frame
#		current_level_container.call_deferred("add_child", current_level)


func switch_level_to(source_scene: PackedScene, new_level: Level, new_spawnpoint: Vector2) -> void:
	current_level_scene = source_scene.duplicate()
	# Player pos
	latest_spawnpoint = new_spawnpoint
	player.global_position = new_spawnpoint
	player.update_reverses(new_level.reverses_for_level)
	
	player.set_physics_process(false)
	# Switch levels
	for child in current_level_container.get_children():
		child.queue_free()
	# Buttons
	green_buttons_info.text = "0/" + str(new_level.exit_door.required_green_buttons)
	blue_buttons_info.text = "0/" + str(new_level.exit_door.required_blue_buttons)
	
	new_level.exit_door.buttons_updated.connect(
		func(new_green: int, new_blue: int):
			green_buttons_info.text[0] = str(new_green)
			blue_buttons_info.text[0] = str(new_blue)
	)
	
	current_level = new_level
	current_level.level_finished.connect(switch_level_to, CONNECT_ONE_SHOT)
	current_level_container.call_deferred("add_child", new_level)
	
	player.set_physics_process(true)


func togle_pause(value: bool) -> void:
	if value:
		is_pause_menu_opened = true
		pause_menu.visible = true
		pause_button.visible = false
		$pausable.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		is_pause_menu_opened = false
		pause_menu.visible = false
		pause_button.visible = true
		$pausable.process_mode = Node.PROCESS_MODE_INHERIT
