extends Camera2D

@export var target: Node2D
# NOTE: Lame, but will do...
@export var viewport_scaling_factor: int = 2
@onready var actual_screen_size: Vector2 = Globals.SCREEN_SIZE / viewport_scaling_factor

var current_offset: Vector2 = Vector2.ZERO
@onready var initial_offset: Vector2 = self.global_position

var is_transitioning: bool = false


func _process(_delta):
	var new_offset: Vector2 = _round_vector2(target.global_position / Globals.SCREEN_SIZE)
	if not current_offset.is_equal_approx(new_offset) and not is_transitioning:
		current_offset = new_offset
		transition_to(initial_offset + actual_screen_size * new_offset)


# Why...Why are you making me do this, Godot...WHY?!
func _round_vector2(source: Vector2) -> Vector2:
	var result: Vector2 = source.round()
	result.x -= 1 * int(source.x < 0)
	result.y -= 1 * int(source.y < 0)
	return result


func transition_to(destination: Vector2) -> void:
	is_transitioning = true
	# Disable target
	target.set_physics_process(false)
	# Transition
	var tween = create_tween()
	tween.tween_property(self, "global_position", destination, 0.4).set_trans(Tween.TRANS_LINEAR)
	tween.play()
	await tween.finished
	is_transitioning = false
	# Enable target
	target.set_physics_process(true)
