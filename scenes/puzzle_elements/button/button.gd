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


func reverse():
	is_reveresed = not is_reveresed
	if is_reveresed:
		sprite.animation = "reversed_default"
		state_changed.emit(true)
	else:
		sprite.animation = "default"
		state_changed.emit(false)


func _on_area_entered(area: Area2D):
	if area.is_in_group("player_hitbox"):
		# NOTE: DON'T FORGET!
		is_activated = true # not is_activated
		# I don't wana deal with this...
		state_changed.emit(is_reveresed)
