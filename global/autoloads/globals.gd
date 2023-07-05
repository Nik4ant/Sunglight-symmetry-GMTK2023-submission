extends Node

const TARGET_FPS: int = 60
"""
css stuff to fix the #canvas:
image-rendering: pixelated;
"""
@onready var SCREEN_SIZE: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)
