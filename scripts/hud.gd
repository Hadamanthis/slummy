class_name HUD
extends Control

@onready var score_value: Label = %ScoreValue
@onready var launches_left_value: Label = %LaunchesLeftValue
@onready var level_value: Label = %LevelValue
@onready var fruits_value: Label = %FruitsValue

@onready var result_container: CenterContainer = %ResultContainer
@onready var result_label: Label = %ResultLabel
@onready var summary_label: Label = %SummaryLabel
@onready var hint_label: Label = %HintLabel

@onready var star_1: TextureRect = %Star1
@onready var star_2: TextureRect = %Star2
@onready var star_3: TextureRect = %Star3

var stars: Array[TextureRect]

func _ready() -> void:
	stars = [star_1, star_2, star_3]

func set_score(value: int) -> void:
	score_value.text = str(value)

func set_launches_left(launches_left: int, total_launches: int) -> void:
	launches_left_value.text = "%s/%s" % [str(launches_left), str(total_launches)]

func set_level_number(value: int) -> void:
	level_value.text = str(value)

func set_fruits_number(remaining_fruits: int, total_fruits: int) -> void:
	fruits_value.text = "%s/%s" % [str(remaining_fruits), str(total_fruits)]

func set_stars(stars_count: int) -> void:
	for star_index in range(stars.size()):
		if star_index >= stars_count:
			stars[star_index].modulate = Color(0.25, 0.25, 0.25, 1) # vazia
		else:
			stars[star_index].modulate = Color(1, 1, 1, 1) # cheia

func show_result(result: String, summary: String) -> void:
	result_label.text = result
	summary_label.text = summary
	result_container.visible = true

func hide_result() -> void:
	result_label.text = ""
	summary_label.text = ""
	result_container.visible = false
