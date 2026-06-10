extends Node2D

enum State {
	PLAYING,
	GAME_OVER
}

@export var levels: Array[PackedScene] = []

@onready var slime: CharacterBody2D = $Slime
@onready var level: Node2D = $Level

var current_level_index := 0
var current_level: Node2D
var score := 0
var state := State.PLAYING

func _ready() -> void:
	_load_current_level()

func _load_current_level() -> void:
	if current_level:
		current_level.queue_free()
	
	current_level = levels[current_level_index].instantiate()
	level.add_child(current_level)
	
	var slime_start: Marker2D = current_level.get_node("SlimeStart")
	slime.global_position = slime_start.global_position
	slime.velocity = Vector2.ZERO
	slime.set_control_enabled(true)
	
	var fruits := current_level.get_node("Fruits")
	var spike: Area2D = current_level.get_node("Spike")
	
	for fruit in fruits.get_children():
		fruit.collected.connect(_on_fruit_collected)
	spike.player_hit.connect(_on_player_hit)

func _go_to_next_level() -> void:
	current_level_index += 1
	
	if current_level_index >= levels.size():
		current_level_index = 0
	
	_load_current_level()

func _on_fruit_collected() -> void:
	if state == State.GAME_OVER:
		return
	
	score += 1
	print("Score: ", score)
	
	await get_tree().process_frame # Espera passar um frame
	
	if _has_remaining_fruits():
		return
	
	_go_to_next_level()

func _has_remaining_fruits():
	var fruits: Node2D = current_level.get_node("Fruits")
	
	for fruit in fruits.get_children():
		if not fruit.is_queued_for_deletion():
			return true
	
	return false



func _on_player_hit() -> void:
	if state == State.GAME_OVER:
		return
	
	state = State.GAME_OVER
	slime.set_control_enabled(false)
	print("Game Over")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and state == State.GAME_OVER:
		get_tree().reload_current_scene()
