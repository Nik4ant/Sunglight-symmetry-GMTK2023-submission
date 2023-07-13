extends Area2D
class_name PuzzleButton

@export var is_reveresed: bool = false
@onready var sprite: AnimatedSprite2D = $sprite

var is_activated: bool = false
signal state_changed(reverse_state: bool)


func _ready():
	if is_reveresed:
		sprite.animation = "reversed"
	else:
		sprite.animation = "default"


func update_anim():
	var anim = "reversed" if is_reveresed else "default"
	if is_activated:
		anim = "pressed_" + anim
	sprite.animation = anim


func reverse():
	is_reveresed = not is_reveresed
	update_anim()
	if is_reveresed:
		state_changed.emit(true)
	else:
		state_changed.emit(false)


func _on_area_entered(area: Area2D):
	if area.is_in_group("player_hitbox") and not is_activated:
		# NOTE: DON'T FORGET!
		Globals.play_sound($activation_sound, 0.9, 1.2)
		is_activated = true # not is_activated
		update_anim()
		# I don't wana deal with this...
		state_changed.emit(is_reveresed)
