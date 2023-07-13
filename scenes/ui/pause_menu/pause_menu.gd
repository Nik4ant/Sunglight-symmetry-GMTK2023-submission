extends Control
class_name PauseMenu

signal closed


func _ready():
	# If you can't fix the problem just ignore it...
	# WHY window.document.fullscreenElement IS null? WTF?!?!?!?!?!?!?!?!?!?!?!?
	if OS.has_feature("web"):
		$exit_button.visible = false

func _on_play_button_pressed():
	closed.emit()

func _on_exit_button_pressed():
	if OS.has_feature("web"):
		# NOTE: WHY?! EVEN THE DisplayServer CAN'T DO THAT
		# UPD: Nope, screw this...
		JavaScriptBridge.eval(
			"""
				if (document.fullscreenElement) 
				{
					if (window.document.exitFullscreen) {
						setTimeout(() => window.document.exitFullscreen(), 1000);
					} else if (document.webkitExitFullscreen) {
						setTimeout(() => window.document.webkitExitFullscreen(), 1000);
					} else if (window.document.mozCancelFullScreen) {
						setTimeout(() => window.document.mozCancelFullScreen(), 1000);
					} else if (document.msExitFullscreen) {
						setTimeout(() => window.document.msExitFullscreen(), 1000);
					}
				}
			""", true
		)
		# get_tree().call_deferred("quit")
	else:
		get_tree().call_deferred("quit")

