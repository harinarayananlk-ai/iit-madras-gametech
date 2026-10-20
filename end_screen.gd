extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://start_screen.tscn")

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://basegame.tscn")
