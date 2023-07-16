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
	# Early game
	EventBus.reverse_mechanic_revealed.connect(
		func():
			Globals.fade_in([$ui/reverses_bar, $ui/reverse_table/spike_to_void, $ui/reverse_table/wood_to_spike])
	, CONNECT_ONE_SHOT)
	EventBus.button_reverse_revealed.connect(
		func():
			Globals.fade_in([$ui/reverse_table/green_to_blue])
	, CONNECT_ONE_SHOT)
	# Endgame
	EventBus.late_game_activated.connect(
		func():
			$late_game_transition.visible = true
			# Transition music as well
			var tween = create_tween()
			tween.tween_property($bg_music, "volume_db", -20.0, 1.0)
			tween.play()
			await tween.finished
			tween.stop()
			
			# Reverse table part
			Globals.fade_in([$ui/reverse_table/arrow_shooter, $ui/reverse_table/arrows_to_heart])
			
			var wtf_tween = create_tween()
			$bg_music.stop()
			$bg_music.stream = preload("res://scenes/main/game/assets/audio/music/Track_2.mp3")
			$bg_music.play()
			wtf_tween.tween_property($bg_music, "volume_db", 2.0, 1.5)
			wtf_tween.play()
	
	, CONNECT_ONE_SHOT)


func _process(_delta):
	if Input.is_action_just_pressed("player_menu"):
		togle_pause(not is_pause_menu_opened)


func reset_current_level():
	for button in current_level.exit_door.buttons_for_activation:
		var btn: PuzzleButton = button as PuzzleButton
		btn.monitorable = false
		btn.monitoring = false
	player.update_reverses(current_level.reverses_for_level)
	player.global_position = latest_spawnpoint
	# This is stupid but it works...
	if current_level_scene:
		# PLEASE WORK! PLEASE! AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		# YEEEEEEEEEEEEEEEEEEEEEES! IT WORKS! I CAN GO SLEEP NOW!
		var pseudo_new_level = current_level_scene.instantiate()
		switch_level_to(current_level_scene, pseudo_new_level, latest_spawnpoint)
		get_tree().create_timer(0.2).timeout.connect(
			func():
				# Reset all buttons to prevent any state getting carried over to 
				# the next level (silly, but should work)
				for button in current_level.exit_door.buttons_for_activation:
					var btn: PuzzleButton = button as PuzzleButton
					btn.is_activated = false
					btn.update_anim()
					btn.state_changed.emit(btn.is_reveresed)
		)
		
#		current_level_container.remove_child(current_level)
#		await get_tree().physics_frame
#		current_level.queue_free()
#		await get_tree().physics_frame
#		current_level = current_level_scene.instantiate()
#		await get_tree().physics_frame
#		current_level_container.call_deferred("add_child", current_level)
	player.call_deferred("set_physics_process", true)


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
	player.visible = true


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
