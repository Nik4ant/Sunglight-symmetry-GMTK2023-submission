extends Area2D
class_name PuzzleButton

@export var is_reveresed: bool = false
@onready var sprite: AnimatedSprite2D = $sprite

var is_activated: bool = false
signal state_changed(reverse_state: bool)


func _ready():
	if is_reveresed:
		sprite.animation = "reversed_default"
	else:
		sprite.animation = "default"


func _on_area_entered(area: Area2D):
	if area.is_in_group("player_hitbox"):
		if is_reveresed:
			is_activated = true
			sprite.animation = "reversed_default"
			state_changed.emit(true)
		else:
			is_activated = true
			sprite.animation = "default"
			state_changed.emit(false)
