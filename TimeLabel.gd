extends Label

@onready var scoresheet = get_tree().get_first_node_in_group("scoresheet")

func _process(delta):
	text = "TIME: " + str(round(scoresheet.time_left))
