extends CanvasLayer


func _ready():
	set_process_input(true)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Globals.play_sound($"../ui_click", 0.9, 1.1)
