extends Node2D

@onready var viewport: SubViewport = %SubViewport
@onready var starting_scene = preload("res://scenes/main/game/game.tscn")

#region Pause menu
var is_pause_menu_opened: bool = false
@onready var pause_button: TextureButton = %pause_button
@onready var pause_menu: PauseMenu = %pause_menu as PauseMenu
#endregion


func _ready():
	# Load the game scene
	viewport.add_child(starting_scene.instantiate())
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


func _process(_delta):
	if Input.is_action_just_pressed("player_menu"):
		togle_pause(not is_pause_menu_opened)


func togle_pause(value: bool) -> void:
	if value:
		is_pause_menu_opened = true
		pause_menu.visible = true
		pause_button.visible = false
		viewport.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		is_pause_menu_opened = false
		pause_menu.visible = false
		pause_button.visible = true
		viewport.process_mode = Node.PROCESS_MODE_INHERIT
