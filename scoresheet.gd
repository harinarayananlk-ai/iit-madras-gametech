extends Node2D

var time_left = 300.0

const win_time = 1250.0
var game_won = false

var backgrounds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backgrounds = [preload("res://bg 5.png")]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_left -= delta
	if time_left >= win_time:
		win_game()
	if time_left < 0:
		get_tree().change_scene_to_file("res://start_screen.tscn")
		
func win_game():
	game_won = true
	$scoredisplay/WinText.visible = true
	get_tree().paused = true
	
	await get_tree().create_timer(3.0, true).timeout
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://end_screen.tscn")
