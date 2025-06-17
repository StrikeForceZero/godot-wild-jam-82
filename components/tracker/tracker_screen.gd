extends Node2D

class_name TrackerScreen

@export var speed: float = 100.0
@export var max_radius: float = 300.0
var radius: float = 0.0

@export var hits: Dictionary[Vector3, float] = {}
@export var tracker: Tracker
@export var marker_ttl: float = 4.0
@export var tracker_scale: float = 1.0
@export var tracker_sprite_rotation: float = 0.0
@onready var tracker_sprite: Sprite2D = %TrackerSprite

func _ready() -> void:
	tracker.on_hit.connect(on_hit)

func _process(delta: float) -> void:
	tracker_sprite.rotation = tracker_sprite_rotation
	radius += speed * delta
	if radius > max_radius:
		radius = radius - max_radius
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	process_hits(delta)
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false, clamp(max_radius/radius, 0.001, 5.0))
	for pos in hits.keys():
		var hit = hits[pos]
		var relative = pos - tracker.global_transform.origin
		var marker_pos3 = tracker.global_transform.basis.inverse() * relative
		var marker_pos2 = Vector2(marker_pos3.x, marker_pos3.z) * tracker_scale
		var color = Color.WHITE
		color.a = hit / marker_ttl
		draw_circle(marker_pos2 * tracker_scale, 10.0, color)

func on_hit(global_position: Vector3) -> void:
	hits[global_position] = marker_ttl
	pass

func process_hits(delta: float) -> void:
	for pos in hits.keys():
		hits[pos] -= delta
		if hits[pos] <= 0.0:
			hits.erase(pos)
	pass
