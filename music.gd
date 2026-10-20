extends Node

var music_player: AudioStreamPlayer

var game_music = preload("res://moojic/bgmusic.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
