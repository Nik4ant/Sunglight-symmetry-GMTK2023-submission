extends CharacterBody2D

@export_group("Movement params")
@export var MAX_SPEED: float = 200
@export var ACCELERATION_CURVE: Curve
var acceleration_curve_offset: float = 0.0
# Note: Thanks Pefeper for tutorial (https://youtu.be/IOe1aGY6hXA)
# (I used it as a base and made a jump with variable height better)
@export_group("Jump")
@export var jump_time_to_peak: float = 0.4
@export var jump_height: float = 55.0  ## Maximum jump height
@export var jump_time_to_descent: float = 0.25
## How many frames player has to adjust the jump height before it's too late
@export var frames_before_full_jump: int = 20
## Indicates how many frames player was in air before hitting the ground
var frames_in_air_counter: int = 0
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@export_subgroup("Assist")
## Lookup table to determine small "gravity" for player in mid air.
## Dictionary stucture: ([action_from_the_input_map]: [gravity_multiplier]
@export var gravity_assist: Dictionary = {
	"player_down": 1.4,
	"player_up": 0.9
}
## Allows player to press jump in mid air without touching the ground
@export var jump_buffer_frames: int = 4
var current_jump_buffer_frames: int = 0
## Allows player to jump a few frames after going off the ground
@export var coyote_frames: int = 6
var current_coyote_frames: int = 0

@onready var sprite: AnimatedSprite2D = %sprite


func _physics_process(delta):
	var input_x: int = int(Input.get_action_strength("player_right") - Input.get_action_strength("player_left"))
	#region Movement x
	if input_x != 0:
		# Curve acceleration
		acceleration_curve_offset = clampf(acceleration_curve_offset + delta, 0.0, 1.0)
		var acceleration: float = ACCELERATION_CURVE.sample_baked(acceleration_curve_offset)
		# Run animation
		sprite.play("run")
		# FIXME: Collider isn't flipped, but sprite is, but it doesn't seem like a major issue
		sprite.flip_h = input_x < 0
		# Update velocity
		velocity.x = lerpf(velocity.x, MAX_SPEED, snappedf(acceleration, 0.01)) * input_x
	else:
		# No deceleration for now (aka instant deceleration)
		acceleration_curve_offset = 0.0
		velocity.x = 0.0
		# Idle animation
		sprite.animation = "idle"
	
	# Limit player MOVEMENT speed
	velocity.x = clampf(velocity.x, -MAX_SPEED, MAX_SPEED)
	#endregion
	
	#region Jump
	var is_in_air: bool = not is_on_floor()
	# Player is allowed to jump either while on the ground
	# or while coyote effect is active
	var can_jump: bool = not is_in_air or current_coyote_frames != 0
	# Update coyote time, jump buffer and in_air_counter frames
	if is_in_air:
		frames_in_air_counter += 1
		current_jump_buffer_frames = clampi(current_jump_buffer_frames - 1, 0, jump_buffer_frames)
		current_coyote_frames = clampi(current_coyote_frames - 1, 0, coyote_frames)
	else:
		# as soon as ground was hit...
		current_coyote_frames = coyote_frames
		frames_in_air_counter = 0
	
	# Jump should be process either if it was pressed while on the ground
	# OR if it was pressed in mid air previously (aka jump buffering)
	var was_jump_activated: bool = current_jump_buffer_frames != 0
	if Input.is_action_just_pressed("player_jump"):
		was_jump_activated = true
		# Set jump buffer if ground wasn't reached yet
		if is_in_air:
			current_jump_buffer_frames = jump_buffer_frames
	
	if was_jump_activated and can_jump:  # self explanatory...
		velocity.y = jump_velocity
		current_coyote_frames = 0
	
	# NOTE: If there is gona be a dash than I'll have to make sure
	# that I'm reducing velocity from the jump and not from the dash
	
	# If player is_in_air, has vertical velocity and released jump recently
	# it means that player wants to do a smaller jump
	# NOTE: THERE IS BUG with 4 frames window: If player presses the jump while in air
	# --> releases it before hitting the ground and while jump buffer is still active,
	# character will jump with full jump velocity 
	# Quick fix --> (multiply end velocity.y in this case by 0.5)
	if Input.is_action_just_released("player_jump"):
		# Jump velocity will be lowered depending on 
		# how much time passed since player jumped
		if frames_in_air_counter != 0 and frames_in_air_counter < frames_before_full_jump:
			velocity.y *= clampf(float(frames_in_air_counter) / frames_before_full_jump, 0.5, 1.0)
		elif is_in_air and current_jump_buffer_frames != 0:
			velocity.y *= 0.5
	
	velocity.y += calculate_gravity(velocity.y) * delta  # gravity
	#endregion
	
	# Corner correction after jump (and dash?)
	apply_corner_correction(delta, 5)
	
	velocity *= delta * Globals.TARGET_FPS
	move_and_slide()


func calculate_gravity(current_y_velocity: float) -> float:
	var assist_multiplier: float = 1.0
	# Calculate assist
	if Input.is_action_pressed("player_down"):
		assist_multiplier = gravity_assist.get("player_down", 1.0)
	elif Input.is_action_pressed("player_up"):
		assist_multiplier = gravity_assist.get("player_up", 1.0)
	# Return actual gravity
	if current_y_velocity < 0:
		return jump_gravity * assist_multiplier
	return fall_gravity * assist_multiplier


func apply_corner_correction(physics_delta: float, pixels_amount: int) -> void:
	# Corner correction can be applied only if going upwards AND 
	# there is a collision (otherwise it's pointless)
	if not (velocity.y < 0 and test_move(global_transform, Vector2(0.0, velocity.y * physics_delta))):
		return
	
	# Account for right (positive) and left (negative) corners
	for direction in [Vector2i(1, 0), Vector2i(-1, 0)]:
		for i in range(1, pixels_amount + 1):
			# Adjust player position if there is no collision after 
			# offsetting player for a few pixels
			var pheoretical_position = global_transform.translated(direction * i)
			if not test_move(pheoretical_position, Vector2(0.0, velocity.y * physics_delta)):
				# Offset player exactly N pixels
				translate(direction * i)
				# FIXME: Making it pixel perfect doesn't really work :(
				# global_position.x = snappedf(global_position.x, 16) - 1.99 * direction.x
				
				# To avoid artifacts set horizontal velocity to zero 
				# unless it's going the other way
				if velocity.x * direction.x < 0:
					velocity.x = 0.0
				return
