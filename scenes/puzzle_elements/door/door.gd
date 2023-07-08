extends Area2D
class_name Door

signal player_exited

@onready var sprite: AnimatedSprite2D = %sprite


func _on_sprite_animation_looped():
	if sprite.animation == "close_animation":
		sprite.animation = "default_closed"
	elif sprite.animation == "open_animation":
		sprite.animation = "default_opened"

func _on_body_entered(body: Node2D):
	if body is Player:
		player_exited.emit()


func open() -> void:
	sprite.play("open_animation")


func close() -> void:
	sprite.play("close_animation")
