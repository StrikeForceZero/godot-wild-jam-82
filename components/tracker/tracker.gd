extends Node3D

class_name Tracker

signal on_hit(position)

@export var speed: float = 100.0
@export var max_radius: float = 300.0
var radius: float = 0.25

@onready var scan_area: Area3D = %ScanArea
@onready var ray_cast: RayCast3D = %RayCast
@onready var tracker_screen: TrackerScreen = %TrackerScreen

func _physics_process(delta: float) -> void:
	radius += speed * delta
	if radius > max_radius:
		radius = radius - max_radius
	tracker_screen.radius = radius
	scan_area.scale = Vector3.ONE * radius
	tracker_screen.tracker_sprite_rotation = global_rotation.y
	

func _on_scan_area_body_entered(body: Node3D) -> void:
	var hit_location = body.global_position - ray_cast.global_position
	ray_cast.target_position = ray_cast.to_local(body.global_position)
	var offset = (ray_cast.target_position - ray_cast.position)
	ray_cast.target_position += offset
	var collider = ray_cast.get_collider()
	print(body, " hit_location: ", hit_location, " collider: ", collider)
	if collider == null:
		# return
		pass
	on_hit.emit(hit_location)
	var audio = AudioStreamPlayer3D.new()
	audio.global_position = body.global_position
	audio.unit_size = 25.0
	audio.autoplay = true
	audio.attenuation_model = AudioStreamPlayer3D.AttenuationModel.ATTENUATION_LOGARITHMIC
	audio.doppler_tracking = AudioStreamPlayer3D.DopplerTracking.DOPPLER_TRACKING_PHYSICS_STEP
	audio.stream = AudioStreamOggVorbis.load_from_file("res://assets/sounds/beep-313342.ogg")
	audio.finished.connect(despawn(audio))
	get_tree().get_root().add_child(audio)

func despawn(node: Node) -> Callable:
	return func ():
		node.queue_free()
