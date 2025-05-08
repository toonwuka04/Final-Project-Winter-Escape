extends CharacterBody2D


#const SPEED = 300.0

var is_chatting = false
var player
var player_is_in_chat = false


func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	$AnimatedSprite2D.play("idle")
	
	if Input.is_action_just_pressed("chat") and player_is_in_chat:
		$Dialogue.start()
		is_chatting = true


func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_is_in_chat = true
		


func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_is_in_chat = false


func _on_dialogue_dialogue_finished() -> void:
	is_chatting = false
	
