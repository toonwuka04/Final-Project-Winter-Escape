extends CharacterBody2D

# Movement Parameters
var speed = 100
var detection_radius = 300  # Distance at which the enemy starts chasing the player
var attack_radius = 50      # Distance at which the enemy attacks the player

var player = null
var player_chase = false
var attack_timer = 0.0  # Timer for controlling attack cooldown
var attack_cooldown = 1.0  # Time between attacks

# States
var is_attacking = false

# Called every frame
func _physics_process(delta: float) -> void:
	# If the player is within detection range, start chasing
	if player_chase and player:
		var direction = (player.position - position).normalized()
		var distance_to_player = position.distance_to(player.position)
		
		# Move towards the player if it's in detection range
		if distance_to_player > attack_radius:
			velocity.x = direction.x * speed
			velocity.y = direction.y * speed
			$AnimatedSprite2D.play("walk")  # Play walking animation
		else:
			# If within attack range, attack the player
			if not is_attacking and attack_timer <= 0:
				# Use await directly when calling the async function
				await attack_player()  # Correct usage of await
		
		# Flip the enemy sprite based on direction
		$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		$AnimatedSprite2D.play("idle")  # Play idle animation
	
	move_and_slide()

	# Cooldown management for attacking
	if attack_timer > 0:
		attack_timer -= delta

# Attack the player
func attack_player() -> void:
	is_attacking = true
	$AnimatedSprite2D.play("attack")  # Play attack animation
	
	# Example: Deal damage to player here, or any attack logic
	if player and player.is_in_group("Player"):
		print("Attacking Player!")
		# Deal damage to player (You can implement damage logic in the player script)
		#player.take_damage(10)  # This is an example. Make sure your player script has a `take_damage` method.

	# Wait until the attack animation finishes
	await $AnimatedSprite2D.animation_finished  # Wait until the attack animation finishes
	is_attacking = false
	attack_timer = attack_cooldown  # Reset attack cooldown

# Detect when player enters the area
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_chase = true

# Detect when player exits the area
func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		player_chase = false
