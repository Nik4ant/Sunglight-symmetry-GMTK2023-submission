extends Area2D
class_name Door

signal player_exited
signal door_opened

@onready var sprite: AnimatedSprite2D = %sprite
@export var is_open: bool = false
# Activation stuff...
@export var buttons_for_activation: Array[PuzzleButton]
var currently_active_buttons: int = 0


func array_from_buttons() -> Array[bool]:
	var result: Array[bool] = []
	result.resize(len(buttons_for_activation))
	result.fill(false)
	return result


func _ready():
	if is_open:
		sprite.animation = "default_opened"
	else:
		sprite.animation = "default_closed"
	# Activation stuff
	for button in buttons_for_activation:
		button.state_changed.connect(
			func(is_reversed: bool):
				button_changed_state(button, is_reversed)
		)
	
	if len(buttons_for_activation) == 0 and not is_open:
		open()


func button_changed_state(button: PuzzleButton, is_reversed: bool):
	var can_open_self: bool = not is_reversed
	currently_active_buttons = 0
	
	for button_inner in buttons_for_activation:
		if button_inner.is_activated:
			currently_active_buttons += 1
			if button_inner.is_reveresed:
				can_open_self = false
		else:
			can_open_self = false
	
	if can_open_self:
		open()
	else:
		close()


func _on_sprite_animation_looped():
	if sprite.animation == "close_animation":
		sprite.animation = "default_closed"
	elif sprite.animation == "open_animation":
		sprite.animation = "default_opened"
		door_opened.emit()


func _on_body_entered(body: Node2D):
	print(is_open, " - ", body, "\n")
	if is_open and body is Player:
		player_exited.emit()


func open() -> void:
	if not is_open:
		is_open = true
		sprite.play("open_animation")


func close() -> void:
	if is_open:
		is_open = false
		sprite.play("close_animation")
