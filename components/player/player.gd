extends CharacterBody3D

class_name Player

const SPEED = 5.0

var target_dir = Vector3.FORWARD

func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Vector3.FORWARD * Input.get_axis("move_backward", "move_forward")
	var direction := (transform.basis * input_dir).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
