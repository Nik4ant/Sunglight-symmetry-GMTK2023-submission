extends Level


func _ready():
	super._ready()
	EventBus.late_game_activated.emit()
