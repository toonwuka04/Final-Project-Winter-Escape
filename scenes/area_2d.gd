extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Player died")
		timer.start()


func _on_timer_timeout() -> void:
	#Engine.time_scale = 1
	get_tree().reload_current_scene()
