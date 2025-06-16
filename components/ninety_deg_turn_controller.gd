extends Node

class_name NinetyDegTurnController

@export var target: Node3D

const TURN_TIME := 0.25    # how long each 90° takes

var turn_queue := []       # pending ±90° steps
var is_tweening := false
var pre_turn_yaw := 0.0    # yaw before the current tween
var current_delta := 0.0   # ±90 the tween is trying to do
var active_tween: Tween = null   # reference to the Tween so we can kill it

func _input(event):
	if event.is_action_pressed("turn_left"):
		_handle_turn_request(90)
	elif event.is_action_pressed("turn_right"):
		_handle_turn_request(-90)

func _handle_turn_request(degrees: float) -> void:
	# if we’re mid‐tween and the request is exactly opposite, cancel it
	if is_tweening and degrees == -current_delta:
		_cancel_current_turn()
		return
	# otherwise just enqueue the step
	turn_queue.append(degrees)
	_try_start_tween()

func _try_start_tween() -> void:
	if is_tweening or turn_queue.is_empty():
		return

	# dequeue next
	current_delta = turn_queue.pop_front()
	pre_turn_yaw   = target.rotation_degrees.y
	var end_y      = pre_turn_yaw + current_delta

	is_tweening = true
	# spawn and store the tween
	active_tween = create_tween()
	active_tween.tween_property(target, "rotation_degrees:y", end_y, TURN_TIME) \
				.set_trans(Tween.TRANS_SINE) \
				.set_ease (Tween.EASE_IN_OUT)
	active_tween.finished.connect(self._on_tween_finished)

func _on_tween_finished() -> void:
	# snap to perfect 90s
	target.rotation_degrees.y = round(target.rotation_degrees.y / 90.0) * 90.0
	is_tweening = false
	active_tween = null
	_try_start_tween()

func _cancel_current_turn() -> void:
	# kill the running tween
	if active_tween:
		active_tween.kill()
	# snap right back
	target.rotation_degrees.y = pre_turn_yaw
	# clear state
	is_tweening = false
	turn_queue.clear()
	active_tween = null
