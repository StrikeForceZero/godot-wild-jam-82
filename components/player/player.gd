extends CharacterBody3D

class_name Player

const SPEED = 5.0

var target_dir = Vector3.FORWARD

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_backward", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, -input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	handle_collide_effects()

var grunting = false
func handle_collide_effects():
	for idx in get_slide_collision_count():
		var col := get_slide_collision(idx)
		if col.get_collider() is Monster:
			continue
		if abs(get_wall_normal().x) == 1 or abs(get_wall_normal().z) == 1:
			grunt()

func grunt():
	if grunting:
		return
	grunting = true
	audio_player.autoplay = true
	audio_player.stream = AudioStreamOggVorbis.load_from_file("res://assets/sounds/grunt-106134.ogg")
	audio_player.finished.connect(grunt_done)
	audio_player.play(0.3)
	print("grunt")

func grunt_done():
	grunting = false
	
