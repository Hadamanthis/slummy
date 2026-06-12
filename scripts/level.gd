class_name Level
extends Node2D

@export var max_launches := 3

@onready var slime_start: Marker2D = $SlimeStart
@onready var fruits: Node2D = $Fruits
@onready var spikes: Node2D = $Spikes

var total_fruits_count := 0

func _ready() -> void:
	total_fruits_count = _count_total_fruits()

func get_slime_start_position() -> Vector2:
	return slime_start.global_position

func get_fruits() -> Array[Node]:
	return fruits.get_children()

func get_spikes() -> Array[Node]:
	return spikes.get_children()

func get_remaining_fruits_count() -> int:
	var count := 0
	
	for fruit in fruits.get_children():
		if not fruit.is_collected:
			count += 1
			
	return count

func get_total_fruits_count() -> int:
	return total_fruits_count

func _count_total_fruits() -> int:
	return fruits.get_child_count()
