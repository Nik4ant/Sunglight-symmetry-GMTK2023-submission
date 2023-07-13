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


func play_sound(player: AudioStreamPlayer, min_pitch: float, max_pitch: float) -> void:
	var initial_pitch = player.pitch_scale
	
	player.pitch_scale = randf_range(min_pitch, max_pitch)
	player.play()
	# Reset back
	player.set_deferred("pitch_scale", initial_pitch)


func fade_in(items: Array[CanvasItem], duration: float = 1.0) -> void:
	var tween = create_tween()
	for item in items:
		item.visible = true
		item.modulate.a = 0.0
		
		tween.tween_property(item, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
	tween.play()
