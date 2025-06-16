extends Node3D

class_name Tracker

signal on_hit(position)

@export var speed: float = 100.0
@export var max_radius: float = 300.0
var radius: float = 1.0

@onready var scan_area: Area3D = %ScanArea
@onready var ray_cast: RayCast3D = %RayCast


func _process(delta: float) -> void:
	radius += speed * delta
	if radius > max_radius:
		radius = radius - max_radius
	scan_area.scale = Vector3.ONE * radius
	

func _on_scan_area_body_entered(body: Node3D) -> void:
	var hit_location = body.global_position - ray_cast.global_position
	ray_cast.target_position = hit_location
	var collider = ray_cast.get_collider()
	if collider == null:
		return
	on_hit.emit(hit_location)
