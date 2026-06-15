class_name Slime
extends CharacterBody2D

signal launched
signal stopped

enum State {
	IDLE,
	AIMING,
	MOVING
}

@export var click_radius := 32.0
@export var max_drag_distance := 140.0
@export var min_drag_distance := 24.0
@export var launch_force_multiplier := 8.0
@export var friction := 900.0
@export var min_stop_speed := 20.0
@export var max_speed := 900.0
@export var bounce_factor := 0.85

@onready var aim: Node2D = %Aim
@onready var aim_fill: Line2D = %AimFill
@onready var aim_rail_left: Line2D = %AimRailLeft
@onready var aim_rail_right: Line2D = %AimRailRight

@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var visual_root: Node2D = $VisualRoot

var state := State.IDLE
var drag_position := Vector2.ZERO
var control_enabled := true

var aim_weak_color := Color(0.3, 1.0, 0.9, 0.85)
var aim_strong_color := Color(1.0, 0.35, 0.15, 1.0)
var rail_offset := 16.0

var squash_tween: Tween
var collected_feedback_tween: Tween

func _ready() -> void:
	aim_fill.visible = false
	aim_fill.clear_points()

func _physics_process(delta: float) -> void:
	if state != State.MOVING:
		return

	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	velocity = velocity.limit_length(max_speed)
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * bounce_factor
		_play_squash(Vector2(1.35, 0.70))

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
	aim_fill.visible = true
	_update_aim_line()

func _update_aim_line() -> void:
	var launch_vector := global_position - drag_position
	var clamped_vector := launch_vector.limit_length(max_drag_distance)
	var direction := clamped_vector.normalized()
	var normal := direction.rotated(PI / 2.0)
	
	_clear_aim()
	
	
	aim_rail_left.add_point(normal * rail_offset)
	aim_rail_left.add_point(clamped_vector + normal * rail_offset)
	
	aim_rail_right.add_point(-normal * rail_offset)
	aim_rail_right.add_point(clamped_vector - normal * rail_offset)
	
	aim_fill.add_point(Vector2.ZERO)
	aim_fill.add_point(clamped_vector)
	
	aim.visible = true

func _try_launch() -> void:
	if state != State.AIMING:
		return
	
	var launch_vector := global_position - drag_position
	var force: float = min(launch_vector.length(), max_drag_distance)
	
	if force <= min_drag_distance:
		state = State.IDLE
		_clear_aim()
		return
	
	velocity = launch_vector.normalized() * force * launch_force_multiplier
	state = State.MOVING
	launched.emit()
	_play_squash(Vector2(1.45, 0.65))
	
	_clear_aim()

func set_control_enabled(is_enabled: bool) -> void:
	control_enabled = is_enabled
	
	if not control_enabled:
		state = State.IDLE
		_stop_motion()
		_clear_aim()

func set_active(is_active: bool) -> void:
	set_control_enabled(is_active)
	collision_shape.disabled = not is_active

	if not is_active:
		_stop_motion()

func reset_for_level(start_position: Vector2) -> void:
	set_active(false)
	global_position = start_position
	state = State.IDLE
	_clear_aim()

func can_hit_hazard() -> bool:
	return control_enabled and state == State.MOVING

func _clear_aim() -> void:
	aim.visible = false
	aim_fill.clear_points()
	aim_rail_left.clear_points()
	aim_rail_right.clear_points()

func _stop_motion() -> void:
	velocity = Vector2.ZERO

func _play_squash(target_scale: Vector2) -> void:
	if squash_tween:
		squash_tween.kill()
	
	squash_tween = create_tween()
	squash_tween.tween_property(visual_root, "scale", target_scale, 0.10)
	squash_tween.tween_property(visual_root, "scale", Vector2.ONE, 0.20)

func play_collect_feedback() -> void:
	if collected_feedback_tween:
		collected_feedback_tween.kill()

	_play_squash(Vector2(1.2, 1.2))

	# particula

	# leve brilho/flash
