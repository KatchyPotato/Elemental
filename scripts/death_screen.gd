extends Control

@onready var final_score = $FinalScore
@onready var header = $Header
var words = [
	"Terminated",
	"Overwhelmed",
	"Anhilated",
	"Skill Issue",
]
func _ready():
	header.text = words[randi_range(0, 3)]
	final_score.text = "Final Score: " + str(GameState.crystal_count)
