class_name Player
extends Character

@onready var _state_machine := $StateMachine

@onready var _controller := $PlayerController
@onready var _jump := $JumpComponent
@onready var _dash := $DashComponent


func _ready() -> void:
	var states: Dictionary = {
		"Idle": StateData.new($StateMachine/OnIdle, {
			"Fall": _is_falling,
			"Jump": _can_try_jump,
			"Dash": _can_try_dash,
			"Walk": func(): return _controller.direction.x != 0.0,
		}),
		"Walk": StateData.new($StateMachine/OnWalk, {
			"Fall": _is_falling,
			"Jump": _can_try_jump,
			"Dash": _can_try_dash,
			"Idle": func(): return _controller.direction.x == 0.0,
		}),
		"Fall": StateData.new($StateMachine/OnFall, {
			"Idle": is_on_floor,
			"Jump": _can_try_jump,
			"Dash": _can_try_dash,
		}),
		"Jump": StateData.new($StateMachine/OnJump, {
			"Dash": _can_try_dash,
			"Fall": func(): return velocity.y >= 0.0,
		}),
		"Dash": StateData.new($StateMachine/OnDash, {
			"Idle": func(): return velocity == Vector2.ZERO,
		}),
	}

	_state_machine.setup("Idle", states)


func _physics_process(_delta: float) -> void:
	move_and_slide()

	if is_on_floor():
		_jump.reset()
		_dash.reset()


func _can_try_jump() -> bool:
	var is_jumping: bool = _controller.was_jump_pressed()
	if is_jumping and not _jump.can_jump():
		_jump.buffer_jump() # We can't jump, so buffer it to try later
		return false

	return (is_jumping or _jump.is_buffered()) and _jump.can_jump()


func _can_try_dash() -> bool:
	var is_dashing: bool = _controller.has_dash_pressed()
	if is_dashing and _controller.dash_direction == Vector2.ZERO:
		return false

	return is_dashing and _dash.can_dash()


func _on_hit_box_area_entered(_area: Area2D) -> void:
	print("Enemy Was Hurt!")
