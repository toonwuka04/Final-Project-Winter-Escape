extends CharacterBody2D

var speed = 100
var jump_velocity = -400  # Stronger jump for platform clearing
var player_chase = false
var player = null

var health = 100
var player_inattack_range = false
var damage
var dead = false
var can_take_damage = true


# Jump parameters
var can_jump = true
var jump_cooldown = 1.0
var jump_timer = 0.0

# Follow parameters
var max_follow_height = 150
var min_jump_distance = 80

func _ready() -> void:
	dead = false

func _physics_process(delta: float) -> void:
	deal_with_damage()
	if !dead: 
		$detection_area/detection_collision.disabled = false
		# Apply gravity
		if not is_on_floor():
			velocity.y += get_gravity().y * delta  # Only use vertical gravity
			$AnimatedSprite2D.play("jump")
		
		# Jump cooldown
		if not can_jump:
			jump_timer += delta
			if jump_timer >= jump_cooldown:
				can_jump = true
				jump_timer = 0.0
		
		if player_chase and player:
			var direction = (player.position - position).normalized()
			var horizontal_distance = abs(player.position.x - position.x)
			var vertical_distance = player.position.y - position.y
			
			# Horizontal movement
			velocity.x = direction.x * speed
			
			# Improved platform jumping
			if is_on_floor() and can_jump:
				# Jump up to reach player on higher platforms
				if vertical_distance < -50 and horizontal_distance < 200 and _is_platform_above():
					velocity.y = jump_velocity
					$AnimatedSprite2D.play("walk")
					can_jump = false
				# Drop down when player is below
				elif vertical_distance > 100 and _can_drop_down():
					velocity.y = jump_velocity * 0.3
					can_jump = false
			
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = direction.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			$AnimatedSprite2D.play("idle")
		
		move_and_slide()
	if dead:
		$detection_area/detection_collision.disabled = true

func _is_platform_above() -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		position,
		position + Vector2(0, -150),  # Check above for platforms
		collision_mask
	)
	return space.intersect_ray(query).is_empty() == false

func _can_drop_down() -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		position,
		position + Vector2(0, 20),  # Check below for platforms
		collision_mask
	)
	return space.intersect_ray(query).is_empty() == false

func _on_detection_area_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D):
	if body.is_in_group("Player"):
		player = null
		player_chase = false



func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inattack_range = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inattack_range = false

func deal_with_damage():
	if player_inattack_range and global.player_current_attack == true:
		if can_take_damage:
			health -= 20
			$take_damage_cooldown.start()
			can_take_damage = false
			print("enemy health: " + str(health))
			# deal with death
			if health <= 0:
				dead = true
				$AnimatedSprite2D.play("death")
				await get_tree().create_timer(1.0).timeout
				$AnimatedSprite2D.visible = false
				$enemy_hitbox/ehitbox_collision.disabled = true
				$detection_area/detection_collision.disabled = true
				
				#drop_soul()
				global.update_score(1)
				print(global.current_slimes)
				self.queue_free()
			

#func drop_soul():
	#soul.visible = true
	#soul_collect()
	#
#func soul_collect():
	#get_tree().create_timer(1.5).timeout
	#soul.visible = false
	#
	##player.collect()
	#queue_free()
	
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
