extends Area2D

signal collected

const FRUIT_COLLECTED_EFFECT := preload("res://scenes/fruit_collected_effect.tscn")

var is_collected := false

var collected_pop_tween: Tween

@onready var visual_root: Node2D = $VisualRoot
@onready var collision_shape: CollisionShape2D = $CollisionShape

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body is Slime:
		is_collected = true
		_spawn_collected_effect()
		collision_shape.set_deferred("disabled", true)
		collected.emit()
		await _play_collected_pop()
		queue_free()

func _play_collected_pop() -> void:
	if collected_pop_tween:
		collected_pop_tween.kill()
	
	collected_pop_tween = create_tween()
	collected_pop_tween.set_parallel(true)
	collected_pop_tween.tween_property(visual_root, "scale", Vector2(1.35, 1.35), 0.2)
	collected_pop_tween.tween_property(visual_root, "modulate:a", 0.0, 0.2)
	await collected_pop_tween.finished

func _spawn_collected_effect() -> void:
	var effect := FRUIT_COLLECTED_EFFECT.instantiate()
	var level := get_parent().get_parent()
	level.add_child(effect)
	effect.global_position = global_position
	effect.play()
