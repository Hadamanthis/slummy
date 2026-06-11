extends Area2D

signal collected

var is_collected := false

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body is Slime:
		collected.emit()
		is_collected = true
		queue_free()
