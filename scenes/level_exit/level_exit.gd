extends Area2D
class_name LevelExit

signal player_exited

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerPlatformer:
		player_exited.emit()
