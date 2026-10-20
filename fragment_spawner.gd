extends Node2D

@export var fragment_scene: PackedScene

const MAX_HISTORY_TIME = 20.0

const MAX_INTERVAL = 1.25
const MIN_INTERVAL = 0.65
const NORMAL_INTERVAL = 0.9

@onready var timer = $Timer

var fragment_history: Array[Dictionary] = []


func _ready():
	add_to_group("fragment_spawner")

	timer.wait_time = NORMAL_INTERVAL
	timer.start()

	spawn_fragment()


func spawn_fragment():
	var fragment = fragment_scene.instantiate()
	add_child(fragment)
	fragment.position = Vector2(randf_range(-550, 550), -800)


func fragment_caught():
	fragment_history.append({
		"time": Time.get_ticks_msec() / 1000.0,
		"result": 1
	})
	$"Fragment caught".play()

	update_spawn_rate()


func fragment_missed():
	fragment_history.append({
		"time": Time.get_ticks_msec() / 1000.0,
		"result": 0
	})
	$"Fragment missed".play()

	update_spawn_rate()


func update_spawn_rate():
	var current_time = Time.get_ticks_msec() / 1000.0

	# Remove results older than 20 seconds
	while fragment_history.size() > 0:
		if current_time - fragment_history[0]["time"] > MAX_HISTORY_TIME:
			fragment_history.remove_at(0)
		else:
			break

	if fragment_history.is_empty():
		return

	var caught = 0
	var total = fragment_history.size()

	for fragment in fragment_history:
		if fragment["result"] == 1:
			caught += 1

	var catch_rate = float(caught) / float(total)

	# Convert catch rate into spawn interval.
	# Higher catch rate = faster spawning.
	var new_interval = lerp(MAX_INTERVAL, MIN_INTERVAL, catch_rate)

	timer.wait_time = new_interval

func _on_timer_timeout():
	spawn_fragment()
