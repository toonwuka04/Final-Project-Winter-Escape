extends Node

# Game state variables
var player_current_attack = false
var current_slimes = 0
var score_label: Label  # This will reference our UI label

func _ready():
	# Wait until the next frame to ensure all autoloads are ready
	await get_tree().process_frame
	
	# Try to find the score label in the GlobalUI
	if get_node_or_null("/root/Global/Label"):
		score_label = get_node("/root/Global/Label")
		update_score(0)  # Initialize display
	else:
		push_warning("ScoreLabel not found! Create a GlobalUI CanvasLayer with a ScoreLabel")

func update_score(points):
	current_slimes += points
	if score_label != null:
		score_label.text = "Souls Collected: %d" % current_slimes
	else:
		# Fallback if label reference is lost
		print("Souls Collected: ", current_slimes)

func reset():
	current_slimes = 0
	update_score(0)
