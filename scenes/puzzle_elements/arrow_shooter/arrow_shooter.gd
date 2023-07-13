extends Area2D
class_name ArrowShooter

@export var shooting_delay: float = 2.0
@export var initial_dealay: float = 0.0
var arrow_default: Arrow
var arrow_reversed: Arrow

@export var is_reversed: bool = false
@onready var shoot_sounds: Array = $shoot_sfx.get_children()
@onready var arrows_parent = get_tree().get_first_node_in_group("level_lord_and_savior")

func _ready():
	arrow_default = preload("res://scenes/puzzle_elements/arrow_shooter/arrow.tscn").instantiate()
	arrow_reversed = arrow_default.duplicate()
	arrow_reversed.reverse_state()
	
	if initial_dealay != 0.0:
		await get_tree().create_timer(initial_dealay).timeout
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = shooting_delay
	timer.timeout.connect(shoot)
	add_child(timer)

func reverse():
	is_reversed = not is_reversed

func shoot():
	Globals.play_sound(shoot_sounds.pick_random(), 0.9, 1.1)
	
	var bullet: Arrow
	if is_reversed:
		bullet = arrow_reversed.duplicate() as Arrow
		bullet.is_reversed = true
	else:
		bullet = arrow_default.duplicate() as Arrow
	
	bullet.global_position = $arrow_spawnpoint.global_position
	arrows_parent.call_deferred("add_child", bullet)
