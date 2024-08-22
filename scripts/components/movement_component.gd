class_name MovementComponent
extends Node

@export_group("Data")
@export var max_speed := 300.0
@export_range(0.001, 1.0) var accel_time := 0.6
@export_range(0.001, 1.0) var decel_time := 0.75

@onready var _friction := (max_speed * 2.0) / (decel_time ** 2.0)
@onready var _acceleration := (max_speed * 2.0) / (accel_time ** 2.0)


func _ready() -> void:
	if owner is not CharacterBody2D:
		push_error("Component owner is not a CharacterBody2D")


func apply_acceleration(delta: float, dir: float, can_slip: bool = false) -> void:
	var accel := _acceleration
	if not can_slip and dir != signf(owner.get_last_motion().x):
		accel *= 2.0 # Prevent slipping behavior

	owner.velocity.x = move_toward(owner.velocity.x, max_speed * dir, accel * delta)


func apply_friction(delta: float) -> void:
	owner.velocity.x = move_toward(owner.velocity.x, 0.0, _friction * delta)
