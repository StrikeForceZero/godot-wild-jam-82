extends Node3D

class_name Tracker

signal on_hit(position)

@export var speed: float = 300.0
@export var max_radius: float = 300.0
@export var ears: AudioListener3D
var radius: float = 0.25

@onready var scan_area: Area3D = %ScanArea
@onready var tracker_screen: TrackerScreen = %TrackerScreen
@onready var bip_audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

const REFERENCE_DISTANCE = 10.0
const MIN_PITCH = 0.25
const MAX_PITCH = 1.5

const MAX_DISTANCE = 50.0
const MIN_VOLUME_DB = -25.0  # -40.0 Silence
const MAX_VOLUME_DB = -0.0    # Full volume

func _physics_process(delta: float) -> void:
	radius += speed * delta
	if radius > max_radius:
		radius = radius - max_radius
		bip_audio_player.play()
	tracker_screen.radius = radius
	scan_area.scale = Vector3.ONE * radius
	tracker_screen.tracker_sprite_rotation = global_rotation.y
	

func _on_scan_area_body_entered(body: Node3D) -> void:
	on_hit.emit(body.global_position)
	var audio := AudioStreamPlayer3D.new()
	var offset := body.global_position - global_position
	var ear_dir := (body.global_position - ears.global_position).normalized()
	var dir := offset.normalized()
	var distance := offset.length()
	
	# Map distance to volume
	var t = clamp(1.0 - (distance / MAX_DISTANCE), 0.0, 1.0)
	var volume_db: float = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, t)
	audio.volume_db = volume_db
	
	# Pan the audio
	#var listener_basis := global_transform.basis
	#var local: Vector3 = listener_basis.inverse() * dir
	#audio.panning_strength = clamp(local.x, -100.0, 100.0)  # Pan between -1 (left) and 1 (right)
	
	var pitch_scale = REFERENCE_DISTANCE / distance
	pitch_scale = clamp(pitch_scale, MIN_PITCH, MAX_PITCH)
	audio.pitch_scale = pitch_scale
	
	# place sound directionally away from ears
	audio.global_position = ears.global_position + ear_dir
	audio.unit_size = 1.0
	audio.max_distance = 2.0
	GlobalUtil.play_audio("res://assets/sounds/beep-313342.ogg", audio)
