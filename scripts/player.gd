extends CharacterBody2D

const SPEED = 230.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME_DURATION = 0.1  # 100ms coyote time window
const JUMP_BUFFER_TIME = 0.1     # 100ms jump input buffer

@onready var animated_sprite = $AnimatedSprite2D

var coyote_time_timer := 0.0
var jump_buffer_timer := 0.0

func _physics_process(delta: float) -> void:
	# Update timers
	coyote_time_timer -= delta
	jump_buffer_timer -= delta
	
	# Handle coyote time - set timer when leaving the ground
	if is_on_floor():
		coyote_time_timer = COYOTE_TIME_DURATION
	
	# Add gravity if not on floor and not jumping with coyote time
	if not is_on_floor() and coyote_time_timer <= 0:
		velocity += get_gravity() * delta

	# Handle jump input buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	# Handle jump (with coyote time and jump buffer)
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_time_timer > 0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0  # Consume the buffered jump
		coyote_time_timer = 0  # Consume the coyote time

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# heading to right
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0: #heading to left
		animated_sprite.flip_h = true
		
	# play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
