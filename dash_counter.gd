extends HBoxContainer

var player

const BAR_WIDTH = 222.0
const BOX_HEIGHT = 10.0
const SEPARATION = 4.0

var chargecount


func _ready():
	player = get_tree().get_first_node_in_group("player")

	add_theme_constant_override("separation", SEPARATION)

	chargecount = player.Max_charges

	create_boxes()
	update_boxes()


func _process(delta):
	update_boxes()


func create_boxes():
	# Remove old boxes
	for child in get_children():
		child.queue_free()

	# Calculate width for each box
	var box_width = (
		BAR_WIDTH - SEPARATION * (chargecount - 1)
	) / chargecount

	# Create the required number of boxes
	for i in range(chargecount):
		var box = ColorRect.new()

		box.custom_minimum_size = Vector2(box_width, BOX_HEIGHT)

		add_child(box)


func update_boxes():
	# If maximum charges change, rebuild the bar
	if chargecount != player.Max_charges:
		chargecount = player.Max_charges
		create_boxes()

	# Update which boxes are filled
	for i in range(get_child_count()):
		var box = get_child(i)

		if i < player.current_charges:
			box.color = Color(0.2, 0.391, 0.25, 1.0)
		else:
			box.color = Color(0.2, 0.2, 0.2)
