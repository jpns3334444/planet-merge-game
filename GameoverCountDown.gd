extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	Gamemaster.update_count_down.connect(update_count_down)

func update_count_down(time: float):
	text = str("%10.2f"%time)
