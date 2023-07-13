extends Node

func _ready():
	EventBus.button_reverse_revealed.emit()
