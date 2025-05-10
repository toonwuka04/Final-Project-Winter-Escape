extends Area2D

const SCENE_PATH = "res://scenes/level"

func _input(event):
	# Only check for space press if we're past level 3
	print(get_current_level_number())
	if get_current_level_number() >= 3 and event.is_action_pressed("continue_chat"):
		
		advance_to_next_scene()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# For levels 1-3, auto-advance immediately
		if get_current_level_number() < 3:
			advance_to_next_scene()

func get_current_level_number() -> int:
	var current_scene_path = get_tree().current_scene.scene_file_path
	return current_scene_path.trim_prefix(SCENE_PATH).trim_suffix(".tscn").to_int()

func advance_to_next_scene():
	var next_level = get_current_level_number() + 1
	var next_scene = "%s%d.tscn" % [SCENE_PATH, next_level]
	
	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		# If no more levels exist, go to menu/credits
		get_tree().change_scene_to_file.call_deferred("res://scenes/menu.tscn")
