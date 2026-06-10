extends Area2D

signal player_hit

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_hit.emit()
