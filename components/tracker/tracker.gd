extends Node3D

class_name Tracker

signal on_hit(position)

@export var speed: float = 300.0
@export var max_radius: float = 300.0
var radius: float = 0.25

@onready var scan_area: Area3D = %ScanArea
@onready var ray_cast: RayCast3D = %RayCast
@onready var tracker_screen: TrackerScreen = %TrackerScreen

const REFERENCE_DISTANCE = 10.0
const MIN_PITCH = 0.25
const MAX_PITCH = 1.5

const MAX_DISTANCE = 50.0
const MIN_VOLUME_DB = -40.0  # Silence
const MAX_VOLUME_DB = -25.0    # Full volume

func _physics_process(delta: float) -> void:
	radius += speed * delta
	if radius > max_radius:
		radius = radius - max_radius
		GlobalUtil.play_audio("res://assets/sounds/water-drop-3-84577.ogg")
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
	var audio := AudioStreamPlayer3D.new()
	var dir := body.global_position - global_position
	var distance := dir.length()
	
	# Map distance to volume
	var t = clamp(1.0 - (distance / MAX_DISTANCE), 0.0, 1.0)
	var volume_db: float = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, t)
	audio.volume_db = volume_db
	
	# Pan the audio
	var relative := dir.normalized()
	var listener_basis := global_transform.basis
	var local: Vector3 = listener_basis.inverse() * relative
	audio.panning_strength = clamp(local.x, -1.0, 1.0)  # Pan between -1 (left) and 1 (right)
	
	var pitch_scale = REFERENCE_DISTANCE / distance
	pitch_scale = clamp(pitch_scale, MIN_PITCH, MAX_PITCH)
	audio.pitch_scale = pitch_scale
	
	audio.global_position = global_position
	#audio.global_position = body.global_position
	#audio.unit_size = 5.0
	#audio.max_distance = 500.0
	#audio.attenuation_model = AudioStreamPlayer3D.AttenuationModel.ATTENUATION_LOGARITHMIC
	# audio.doppler_tracking = AudioStreamPlayer3D.DopplerTracking.DOPPLER_TRACKING_PHYSICS_STEP
	GlobalUtil.play_audio("res://assets/sounds/beep-313342.ogg", audio)
