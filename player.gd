extends CharacterBody2D

# Normal functions
var SPEED = 600.0
const JUMP_FORCE = -800.0
const GRAVITY = 2200.0
const ACCELERATION = 1200.0

# Drop and Roll
const ROLL_SPEED_MULTIPLIER = 1.8
const ROLL_DURATION = 1.5
const DROP_SPEED = 1800.0
var is_rolling = false
var roll_timer = 0.0
var dropping = false

# Dashing
const dashdistance = 0.7
const GROUND_Y = 50.0

const charge_regentime = 10.0
var Max_charges = 2
var current_charges = 2
var charge_timer = 0.0

var is_dashing = false

# Time bubble
var time_bubble_scene = preload("res://time_bubble.tscn")
var Max_bubble = 0
var current_bubble = 0
var is_summoning = false

# Time tracking
var scoresheet

# Age / progression
var current_level = 0


func _ready():
	scoresheet = get_tree().get_first_node_in_group("scoresheet")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):

	 
	# AGE / LEVEL PROGRESSION
	 
	update_age()


	 
	# GRAVITY
	 
	if not is_on_floor():
		velocity.y += GRAVITY * delta


	 
	# WASD MOVEMENT
	 
	var direction = 0

	if Input.is_key_pressed(KEY_A):
		direction -= 1

	if Input.is_key_pressed(KEY_D):
		direction += 1

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * SPEED,
			ACCELERATION * delta
		)

		is_summoning = false
		$AnimatedSprite2D.flip_h = direction < 0

	else:
		if is_on_floor():
			velocity.x = 0


	 
	# TIME BUBBLE
	 
	if Input.is_action_just_pressed("time_bubble"):
		spawn_time_bubble()
		$"Audios/time bubble".play()

		if current_bubble < Max_bubble:
			is_summoning = true
			$AnimatedSprite2D.play("summon")


	 
	# JUMP
	 
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)) and is_on_floor():
		velocity.y = JUMP_FORCE


	 
	# DROP AND ROLL
	 
	if Input.is_key_pressed(KEY_S) and not is_on_floor() and not is_rolling:
		velocity.y = DROP_SPEED
		dropping = true


	 
	# DASH
	 
	if Input.is_action_just_pressed("timedash"):
		var dash_start = global_position
		time_dash()
		spawn_dash_afterimages(dash_start,global_position)
		is_dashing = true


	 
	# ANIMATION
	 
	if is_rolling:
		$AnimatedSprite2D.play("slide")

	elif is_summoning:
		$AnimatedSprite2D.play("summon")

	elif is_dashing:
		$AnimatedSprite2D.play("dash")

	elif not is_on_floor():
		$AnimatedSprite2D.play("jump")

	elif abs(velocity.x) > 10:
		$AnimatedSprite2D.play("walk")

	else:
		$AnimatedSprite2D.play("idle")


	move_and_slide()


	 
	# WALL JUMP
	 
	var wall_normal = get_wall_normal()

	if is_on_wall() and not is_on_floor() and (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)):
		velocity.x = wall_normal.x * SPEED
		velocity.y = JUMP_FORCE
		$"Audios/wall jump".play()


	 
	# ROLL TIMER
	 
	if roll_timer > 0:
		roll_timer -= delta


	 
	# STOPPING
	 
	if is_on_floor() and direction == 0:
		velocity.x = 0


	 
	# START ROLLING
	 
	if is_on_floor() and dropping:

		if Input.is_key_pressed(KEY_S):

			if velocity.y < 0:
				velocity.y = 0

			is_rolling = true
			velocity.x = velocity.x * ROLL_SPEED_MULTIPLIER
			roll_timer = ROLL_DURATION
			dropping = false


	 
	# STOP ROLLING
	 
	if is_rolling and roll_timer <= 0:

		velocity.x = velocity.x / ROLL_SPEED_MULTIPLIER
		is_rolling = false


	 
	# CHARGE REGENERATION
	 
	if current_charges < Max_charges:

		charge_timer += delta

		if charge_timer >= charge_regentime:

			charge_timer = 0.0
			current_charges += 1


  
# AGE SYSTEM
  

func update_age():

	var time = scoresheet.time_left

	# Level 1 - 400 seconds
	if time >= 400 and current_level < 1:
		current_level = 1
		SPEED = 550.0

	# Level 2 - 600 seconds
	elif time >= 600 and current_level < 2:
		current_level = 2
		SPEED = 500.0

		# Unlock time bubble
		Max_bubble = 2

		# Give one extra charge
		Max_charges = 3
		current_charges = min(current_charges + 1, Max_charges)

	# Level 3 - 800 seconds
	elif time >= 800 and current_level < 3:
		current_level = 3
		SPEED = 450.0

	# Level 4 - 1000 seconds
	elif time >= 1000 and current_level < 4:
		current_level = 4
		SPEED = 375.0

		# Give another charge
		Max_charges = 4
		current_charges = min(current_charges + 1, Max_charges)

	# Level 5 - 1200 seconds
	elif time >= 1200 and current_level < 5:
		current_level = 5
		SPEED = 300.0


  
# DASH
  

func time_dash():

	var fragments = get_tree().get_nodes_in_group("time fragments")

	if fragments.size() == 0:
		return

	if current_charges <= 0:
		return

	var target = fragments[0]

	for fragment in fragments:

		if fragment.global_position.y > target.global_position.y \
		and fragment.global_position.y < GROUND_Y:

			target = fragment


	var distance = dashdistance * (
		target.global_position.x - global_position.x
	)

	global_position.x += distance
	global_position.y = GROUND_Y

	scoresheet.time_left -= 10.0
	current_charges -= 1
	
	$Audios/dash.play()


  
# TIME BUBBLE
  

func spawn_time_bubble():

	if current_charges > 0 and current_bubble < Max_bubble:

		var bubble = time_bubble_scene.instantiate()

		get_parent().add_child(bubble)

		bubble.global_position = global_position + Vector2(0, -200)

		scoresheet.time_left -= 30

		current_charges -= 1
		current_bubble += 1


  
# ANIMATION FINISHED
  

func _on_animation_finished():

	if $AnimatedSprite2D.animation == "dash":
		is_dashing = false

	if $AnimatedSprite2D.animation == "summon":
		is_summoning = false

func spawn_dash_afterimages(start_pos:Vector2, end_pos:Vector2):
	var distance = start_pos.distance_to(end_pos)
	if distance <= 10.0:
		print("cancellign spawn cuz distance be too close")
		return
	
	var count = clampi(ceil(distance/500.0),2,3)
	
	var sprite = $AnimatedSprite2D
	var displacement = end_pos - start_pos
	var sprite_start = sprite.global_position - displacement
	
	print("Dash distance: ", distance, "\n Number of ghosts: ", count)
	
	for i in range(count):
		var ghost = Sprite2D.new()
		
		ghost.texture = sprite.sprite_frames.get_frame_texture("walk",i)
		
		if ghost.texture == null:
			print("no texture for da ghost: ", i)
			ghost.queue_free()
			continue
		
		ghost.flip_h = sprite.flip_h
		ghost.flip_v = sprite.flip_v
		ghost.rotation = sprite.rotation
		ghost.scale = sprite.global_scale
		ghost.z_index = 100
		
		var ghostcount = float(i+1)/float(count+1)
		
		ghost.global_position = sprite_start.lerp(sprite.global_position,ghostcount)
		ghost.modulate = Color(0.0, 0.906, 0.55, 1.0)
		
		get_tree().current_scene.add_child(ghost)
		var delay = (count - 1 - i) * 0.57
		var tween = ghost.create_tween()
		
		tween.tween_interval(delay)
		tween.tween_property(ghost,"modulate:a",0.0,0.7)
		tween.tween_callback(ghost.queue_free)
