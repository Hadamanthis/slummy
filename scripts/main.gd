extends Node2D

enum State {
	PLAYING,
	STAGE_CLEARED,
	STAGE_FAILED
}

@export var levels: Array[PackedScene] = []

@onready var slime: Slime = $Slime
@onready var level: Node2D = $Level
@onready var hud: HUD = %HUD

var state := State.PLAYING

var current_level_index := 0
var current_level: Level
var current_level_score := 0
var current_level_number: int
var launches_left := 0
var fruits_collected_this_launch := 0

func _ready() -> void:
	slime.launched.connect(_on_slime_launched)
	slime.stopped.connect(_on_slime_stopped)
	_load_current_level()

func _load_current_level() -> void:
	slime.set_active(false)
	
	_remove_current_level()
	
	current_level = levels[current_level_index].instantiate()
	level.add_child(current_level)
	
	slime.reset_for_level(current_level.get_slime_start_position())

	# Atualizando informações sobre o level
	_init_current_level_info()
	hud.hide_result()
	_update_hud()
	
	slime.set_active(true)
	
	_connect_current_level_signals()

func _remove_current_level() -> void:
	if not current_level:
		return
	
	level.remove_child(current_level)
	current_level.queue_free()
	current_level = null

func _restart_current_level() -> void:
	_load_current_level()

func _go_to_next_level() -> void:
	current_level_index += 1
	
	if current_level_index >= levels.size():
		current_level_index = 0
	
	_load_current_level()

func _on_fruit_collected(source_level: Level) -> void:
	if source_level != current_level:
		return
	
	if state != State.PLAYING:
		return
	
	fruits_collected_this_launch += 1

func _init_current_level_info() -> void:
	current_level_score = 0
	launches_left = current_level.max_launches
	current_level_number = current_level_index + 1 # Mudar posteriormente para uma info no level
	state = State.PLAYING

func add_score(amount: int) -> void:
	current_level_score += amount

func spend_launch() -> void:
	launches_left -= 1

func stage_failed() -> void:
	if state == State.STAGE_FAILED:
		return
	
	state = State.STAGE_FAILED
	slime.set_active(false)
	var result = "Fase %s Falhou" % current_level_number
	var summary = "Score: %s" % current_level_score
	hud.set_stars(0)
	hud.show_result(result, summary)
	_update_hud()

func stage_cleared() -> void:
	if state == State.STAGE_CLEARED:
		return
	
	state = State.STAGE_CLEARED
	slime.set_active(false)
	var result = "Fase %s Completa" % current_level_number
	var summary = "Score: %s" % current_level_score
	hud.set_stars(3)
	hud.show_result(result, summary)
	_update_hud()

func _update_hud() -> void:
	hud.set_score(current_level_score)
	hud.set_launches_left(launches_left, current_level.max_launches)
	hud.set_level_number(current_level_number)
	hud.set_fruits_number(
		current_level.get_remaining_fruits_count(),
		current_level.get_total_fruits_count()
	)

func _has_remaining_fruits() -> bool:
	return current_level.get_remaining_fruits_count() > 0

func _on_player_hit(source_level: Level) -> void:
	if source_level != current_level:
		return
	
	if state != State.PLAYING:
		return
	
	if not slime.can_hit_hazard():
		return

	stage_failed()

func _connect_current_level_signals() -> void:
	for fruit in current_level.get_fruits():
		fruit.collected.connect(_on_fruit_collected.bind(current_level))
	
	for spike in current_level.get_spikes():
		spike.player_hit.connect(_on_player_hit.bind(current_level))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		match state:
			State.STAGE_FAILED:
				_restart_current_level()
			State.STAGE_CLEARED:
				_go_to_next_level()

func _on_slime_launched() -> void:
	fruits_collected_this_launch = 0

func _on_slime_stopped() -> void:
	if state != State.PLAYING:
		return
	
	add_score(fruits_collected_this_launch ** 2)
	spend_launch()

	# Condição de derrota: Ainda há frutas mas não tem mais lançamentos
	if not _has_remaining_fruits():
		stage_cleared()
		return

	if launches_left <= 0:
		stage_failed()
		return
	
	_update_hud()
