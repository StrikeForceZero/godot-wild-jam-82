extends Node2D

class_name TrackerScreen

@export var speed: float = 100.0
@export var max_radius: float = 300.0
var radius: float = 0.0



func _process(delta: float) -> void:	
	radius += speed * delta
	if radius > max_radius:
		radius = radius - max_radius
	queue_redraw()
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false, clamp(max_radius/radius, 0.001, 5.0))
