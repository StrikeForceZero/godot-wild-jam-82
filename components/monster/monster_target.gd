extends Node3D

class_name MonsterTarget

@export var monster: Monster

func _physics_process(delta: float) -> void:
	if monster == null:
		return
	monster.target_pos = global_position
