extends Label

var current_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Gamemaster.block_removed.connect(update_score)

func update_score(size: int):
	current_score += size ** 2
	text = str(current_score)
