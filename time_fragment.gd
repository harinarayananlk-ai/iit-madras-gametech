extends Area2D

const FALL_SPEED = 200.0
var scoresheet
var fragment_spawner
var time_scale = 1.0

var fragment_type = 0

func _ready():
	add_to_group("time fragments")
	scoresheet = get_tree().get_first_node_in_group("scoresheet")
	fragment_spawner = get_tree().get_first_node_in_group("fragment_spawner")
	
	var roll = randf()
	
	if roll < 0.05:
		fragment_type = 2
	elif roll < 0.15:
		fragment_type = 1
	
	if fragment_type == 1:
		$Polygon2D.modulate = Color("cab100ff")
	elif fragment_type == 2:
		$Polygon2D.modulate = Color("ffffff00")

func _process(delta):
	position.y += FALL_SPEED * delta * time_scale

	if position.y >= 50:
		if fragment_type != 2:
			scoresheet.time_left -= 30
		fragment_spawner.fragment_missed()
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		if fragment_type == 0:
			scoresheet.time_left += 5
		elif fragment_type == 1:
			scoresheet.time_left += 30
		$"Caught fragment".play()
		fragment_spawner.fragment_caught()
		queue_free()
