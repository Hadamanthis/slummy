class_name HUD
extends Control

@onready var score_value: Label = %ScoreValue
@onready var launches_left_value: Label = %LaunchesLeftValue
@onready var level_value: Label = %LevelValue
@onready var fruits_value: Label = %FruitsValue

@onready var result_container: CenterContainer = %ResultContainer
@onready var result_label: Label = %ResultLabel

func set_score(value: int) -> void:
	score_value.text = str(value)

func set_launches_left(launches_left: int, total_launches: int) -> void:
	launches_left_value.text = "%s/%s" % [str(launches_left), str(total_launches)]

func set_level_number(value: int) -> void:
	level_value.text = str(value)

func set_fruits_number(remaining_fruits: int, total_fruits: int) -> void:
	fruits_value.text = "%s/%s" % [str(remaining_fruits), str(total_fruits)]

func show_result(value: String) -> void:
	result_label.text = value
	result_container.visible = true

func hide_result() -> void:
	result_label.text = ""
	result_container.visible = false
