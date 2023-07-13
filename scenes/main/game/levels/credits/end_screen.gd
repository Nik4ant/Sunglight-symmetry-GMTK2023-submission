extends Control

var can_return_the_orb: bool = false
var has_returned: bool = false

func _ready():
	$the_orb.modulate.a = 0.0
	$was_returned.modulate.a = 0.0
	$player_tilebased.set_physics_process(false)
	
	
	self.modulate = Color.BLACK
	var super_tween = create_tween()
	super_tween.tween_property(self, "modulate", Color.WHITE, 3.0)
	
	super_tween.play()
	
	await get_tree().create_timer(1.5).timeout
	
	
	
	$the_orb.visible = true
	$was_returned.visible = true
	
	var tween = create_tween()
	$holy.volume_db = -10.0
	$holy.play()
	tween.tween_property($the_orb, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.5)
	tween.tween_property($holy, "volume_db", -1.0, 2.0)
	tween.play()
	await tween.finished
	
	var tween2 = create_tween()
	tween2.tween_property($was_returned, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.5)
	tween2.play()
	await tween2.finished
	
	var tween3 = create_tween()
	tween3.tween_property($the_orb, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.5)
	tween3.tween_property($was_returned, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.5)
	tween3.play()
	
	await tween3.finished
	$player_tilebased.set_physics_process(true)


func _process(delta):
	if can_return_the_orb and Input.is_action_just_pressed("player_reverse"):
		# TODO: remove invisible wall
		# (15; 0) and (16; 0)
		$pls_work.set_cell(0, Vector2i(16, 0), -1)
		$pls_work.set_cell(0, Vector2i(15, 0), -1)
		$Ball.visible = true
		$ui_hint.visible = false
		$sfx_stuff.play()
		has_returned = true

func _on_door_player_exited():
	if OS.has_feature("web"):
		$player_tilebased.visible = false
	var tween = create_tween()
	tween.tween_property($CanvasModulate, "color", Color.BLACK, 5.0)
	tween.play()
	await tween.finished
	
	get_tree().quit(0)


func _on_hint_area_body_entered(body):
	if body is Player and not has_returned:
		can_return_the_orb = true
		var tween = create_tween()
		$ui_hint.visible = true
		$ui_hint.modulate.a = 0.0
		tween.tween_property($ui_hint, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)


func _on_hint_area_body_exited(body):
	if body is Player and not has_returned:
		can_return_the_orb = false
		var tween = create_tween()
		tween.tween_property($ui_hint, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)

