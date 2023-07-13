extends Level


func _ready():
	super._ready()
	EventBus.reverse_mechanic_revealed.emit()
