class_name Slime
extends CharacterBody2D

signal launched
signal stopped

enum State {
	IDLE,
	AIMING,
	MOVING
}

@export var click_radius := 48.0
@export var max_drag_distance := 140.0
@export var min_drag_distance := 12.0
@export var launch_force_multiplier := 8.0
@export var friction := 900.0
@export var min_stop_speed := 20.0
@export var max_speed := 900.0
@export var bounce_factor := 0.85

@onready var aim_line: Line2D = $Line2D

var state := State.IDLE
var drag_position := Vector2.ZERO
var control_enabled := true

func _ready() -> void:
	aim_line.visible = false
	aim_line.clear_points()

func _physics_process(delta: float) -> void:
	if state != State.MOVING:
		return

	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	velocity = velocity.limit_length(max_speed)
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * bounce_factor

	if velocity.length() <= min_stop_speed:
		velocity = Vector2.ZERO
		state = State.IDLE
		stopped.emit()

func _unhandled_input(event: InputEvent) -> void:
	if control_enabled == false:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_aim()
		else:
			_try_launch()
	
	if event is InputEventMouseMotion and state == State.AIMING:
		drag_position = get_global_mouse_position()
		_update_aim_line()

func _try_start_aim() -> void:
	if state != State.IDLE:
		return
	
	var mouse_position := get_global_mouse_position()
	var distance_to_slime := global_position.distance_to(mouse_position)
	
	if distance_to_slime > click_radius:
		return
	
	state = State.AIMING
	drag_position = mouse_position
	aim_line.visible = true
	_update_aim_line()

func _update_aim_line() -> void:
	var launch_vector := global_position - drag_position
	var clamped_vector := launch_vector.limit_length(max_drag_distance)
	
	aim_line.clear_points()
	aim_line.add_point(Vector2.ZERO)
	aim_line.add_point(clamped_vector)

func _try_launch() -> void:
	if state != State.AIMING:
		return
	
	var launch_vector := global_position - drag_position
	var force: float = min(launch_vector.length(), max_drag_distance)
	
	if force <= min_drag_distance:
		state = State.IDLE
		aim_line.visible = false
		aim_line.clear_points()
		return
	
	velocity = launch_vector.normalized() * force * launch_force_multiplier
	state = State.MOVING
	launched.emit()
	
	aim_line.visible = false
	aim_line.clear_points()

func set_control_enabled(is_enabled: bool) -> void:
	control_enabled = is_enabled
	
	if not control_enabled:
		velocity = Vector2.ZERO
		state = State.IDLE
		aim_line.visible = false
		aim_line.clear_points()
