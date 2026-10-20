extends Area2D

const time_dilation = 0.3
const bad_time_dilation = 1.15
const ACTIVATION_DISTANCE = 100.0

var is_bad_bubble = false
var player
var scoresheet

var player_was_in_range = false


func _ready():
	player = get_tree().get_first_node_in_group("player")
	scoresheet = get_tree().get_first_node_in_group("scoresheet")

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	if randi_range(1, 20) == 1:
		is_bad_bubble = true
		$Polygon2D.modulate = $Polygon2D.modulate.darkened(0.3)


func _on_area_entered(area):
	if area.is_in_group("time fragments"):
		if not is_bad_bubble:
			area.time_scale = time_dilation
		else:
			area.time_scale = bad_time_dilation


func _on_area_exited(area):
	if area.is_in_group("time fragments"):
		area.time_scale = 1.0


func _process(delta):
	var x_distance = abs(player.global_position.x - global_position.x)

	if x_distance <= ACTIVATION_DISTANCE:
		if not player_was_in_range:
			activate_bubble()

		player_was_in_range = true

	else:
		player_was_in_range = false


func activate_bubble():
	var fragments = get_tree().get_nodes_in_group("time fragments")

	for fragment in fragments:
		var distance = global_position.distance_to(fragment.global_position)

		if distance <= $CollisionShape2D.shape.radius:
			scoresheet.time_left += 3.0
			fragment.queue_free()
