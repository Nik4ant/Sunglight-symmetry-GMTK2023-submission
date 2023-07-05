extends Node2D

@onready var viewport: SubViewport = %SubViewport
@onready var starting_scene = preload("res://scenes/main/game/game.tscn")

func _ready():
	# Load the game scene
	viewport.add_child(starting_scene.instantiate())
