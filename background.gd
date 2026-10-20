extends Sprite2D

var backgrounds = [preload("res://bg 5.png"),preload("res://bg 4.png"),preload("res://bg 3.png"),preload("res://bg 2.png"),preload("res://bg 1.png")]

var currentlevel = 0
var scoresheet
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scoresheet = get_tree().get_first_node_in_group("scoresheet")
	texture = backgrounds[currentlevel]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var score = scoresheet.time_left - 200
	var new_level = int(score/200)
	new_level = clamp(new_level, 0, 4)
	
	if new_level != currentlevel:
		currentlevel=new_level
		change_background()

func change_background():
	var tween = create_tween()
	
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():texture = backgrounds[currentlevel])
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
