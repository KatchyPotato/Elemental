extends CanvasLayer

@onready var crystal_label = $CrystalCount

func _process(delta):
	crystal_label.text = str(GameState.crystal_count)
