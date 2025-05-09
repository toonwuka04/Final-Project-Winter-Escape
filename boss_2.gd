extends CharacterBody2D
var reloading = false

@export var speed: float = 100.0
@export var roam_change_interval: float = 2.0
@export var player_group_name: String = "Player"

# Define level bounds manually
const LEVEL_LEFT = -50.0
const LEVEL_TOP = -200.0
const LEVEL_RIGHT = 7100.0
const LEVEL_BOTTOM = -25.0

var player: Node2D = null
var is_chasing: bool = false
var roam_direction: Vector2 = Vector2.ZERO
var roam_timer: float = 0.0

func _ready() -> void:
	randomize()
	_choose_new_roam_direction()
	print("I am in the tree:", get_tree())

func _physics_process(delta: float) -> void:
	if is_chasing and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		# Random roaming behavior
		roam_timer += delta
		if roam_timer >= roam_change_interval:
			_choose_new_roam_direction()
			roam_timer = 0.0

		velocity = roam_direction * speed

	move_and_slide()

	# Clamp within level
	position.x = clamp(position.x, LEVEL_LEFT, LEVEL_RIGHT)
	position.y = clamp(position.y, LEVEL_TOP, LEVEL_BOTTOM)

	# Restart scene if boss collides with player (only once)
	if not reloading:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and collider.is_in_group(player_group_name):
				reloading = true
				get_tree().reload_current_scene()
				break

func _choose_new_roam_direction() -> void:
	# Choose a new random unit vector direction
	var angle = randf_range(0, TAU)  # TAU = 2π
	roam_direction = Vector2(cos(angle), sin(angle)).normalized()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(player_group_name):
		player = body
		is_chasing = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		is_chasing = false
		player = null
