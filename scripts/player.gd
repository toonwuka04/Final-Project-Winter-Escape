extends CharacterBody2D

const SPEED = 230.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME_DURATION = 0.1
const JUMP_BUFFER_TIME = 0.1

@onready var animated_sprite = $AnimatedSprite2D

var coyote_time_timer := 0.0
var jump_buffer_timer := 0.0
var attack_cooldown := false  # New cooldown variable

func _physics_process(delta: float) -> void:
	# Update timers
	coyote_time_timer -= delta
	jump_buffer_timer -= delta
	
	# Handle coyote time
	if is_on_floor():
		coyote_time_timer = COYOTE_TIME_DURATION
	
	# Gravity
	if not is_on_floor() and coyote_time_timer <= 0:
		velocity += get_gravity() * delta

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	# Jump execution
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_time_timer > 0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_time_timer = 0

	# Movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Animation states
	if animated_sprite.animation == "attack" and animated_sprite.is_playing():
		pass  # Don't interrupt attack animation
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Movement application
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Attack handling (single press)
	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		attack_cooldown = true
		animated_sprite.play("attack")
		await animated_sprite.animation_finished
		attack_cooldown = false
