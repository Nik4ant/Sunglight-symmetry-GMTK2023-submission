extends Area2D
class_name Door

signal player_exited
signal buttons_updated(current_green: int, current_blue: int)
# signal door_opened

@onready var sprite: AnimatedSprite2D = %sprite
@export var is_open: bool = false
# Activation stuff...
@export var required_blue_buttons: int = 0
var current_blue_buttons: int = 0
@export var required_green_buttons: int = 0
var current_green_buttons: int = 0

@export var buttons_for_activation: Array[PuzzleButton]
# Sfx
@onready var open_sfx: AudioStreamPlayer = %open_sfx
@onready var close_sfx: AudioStreamPlayer = %close_sfx


func array_from_buttons() -> Array[bool]:
	var result: Array[bool] = []
	result.resize(len(buttons_for_activation))
	result.fill(false)
	return result


func _ready():
	if is_open:
		sprite.animation = "default_opened"
		$IsThisDefenitionOfInsanity.set_cell(0, Vector2i(0, -1), -1)
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
	current_blue_buttons = 0
	current_green_buttons = 0
	
	for button_inner in buttons_for_activation:
		if button_inner.is_activated:
			if button_inner.is_reveresed:
				current_blue_buttons += 1
			else:
				current_green_buttons += 1
	
	buttons_updated.emit(current_green_buttons, current_blue_buttons)
	if current_blue_buttons == required_blue_buttons and current_green_buttons == required_green_buttons:
		open()
	else:
		close()


func _on_sprite_animation_looped():
	if sprite.animation == "close_animation":
		sprite.animation = "default_closed"
	elif sprite.animation == "open_animation":
		sprite.animation = "default_opened"
		# door_opened.emit()


func _on_body_entered(body: Node2D):
	if is_open and body is Player:
		player_exited.emit()


func open() -> void:
	if not is_open:
		open_sfx.play()
		$IsThisDefenitionOfInsanity.set_cell(0, Vector2i(0, -1), -1)
		is_open = true
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(1, false)
		sprite.play("open_animation")


func close() -> void:
	if is_open:
		close_sfx.play()
		var source_id = $IsThisDefenitionOfInsanity.get_cell_source_id(0, Vector2i.ZERO)
		$IsThisDefenitionOfInsanity.set_cell(0, Vector2i(0, -1), source_id, Vector2i.ZERO)
		is_open = false
		self.set_collision_layer_value(1, true)
		self.set_collision_mask_value(1, true)
		sprite.play("close_animation")
