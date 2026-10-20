extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://basegame.tscn")


func _on_rules_button_pressed() -> void:
	$"How to play".visible = true
	await get_tree().create_timer(10.0, true).timeout
	$"How to play".visible = false
