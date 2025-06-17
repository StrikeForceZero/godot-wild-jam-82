extends CharacterBody3D

class_name Monster

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var target_pos := Vector3.ZERO
@export var speed: float = 100.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	nav_agent.target_position = target_pos
	var next_pos = nav_agent.get_next_path_position()
	if next_pos == null:
		return
	look_at(Vector3(next_pos.x, position.y, next_pos.z))
	var dir = (next_pos - global_position).normalized()
	velocity.x = dir.x * speed * delta
	velocity.z = dir.z * speed * delta
	move_and_slide()
