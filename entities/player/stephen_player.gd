class_name Player extends CharacterBody3D

var walk_speed: float = 1.8
var run_speed: float = 3.5
var backpedal_multiplier: float = 0.5
var acceleration: float = 10.0
var deceleration: float = 50.0

var turn_speed_deg: float = 70.0
var multiplier: float = 1.0
var run_turn_multiplier: float = 0.7

var is_quick_turning: bool = false
var quick_turn_duration: float = 0.5 


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("quick_turn") and not Input.is_action_pressed("move_forward") and not is_quick_turning:
		print('turning ')
		_quick_turn()
	
	if not is_quick_turning:
		_handle_turn(delta)
	
	_handle_walk(delta)
	move_and_slide()


func _quick_turn():
	is_quick_turning = true
	var tween := create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "rotation:y", rotation.y + PI, quick_turn_duration)
	tween.tween_callback(func(): is_quick_turning = false)


# left positive | right negative
func _handle_turn(delta: float) -> void:
	var turn_input := Input.get_axis("turn_right", "turn_left")
	if Input.is_action_pressed("run"):
		multiplier = run_turn_multiplier 
	
	rotate_y(turn_input * deg_to_rad(turn_speed_deg) * multiplier * delta)


func _handle_walk(delta: float) -> void:
	var input_dir := Input.get_axis("move_backward", "move_forward")
	
	var speed := walk_speed
	if input_dir > 0.0 and Input.is_action_pressed("run"):
		speed = run_speed
	elif input_dir < 0.0:
		speed *= backpedal_multiplier
	
	var forward := -global_basis.z
	var target := forward * input_dir * speed
	target.y = 0.0
	
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var rate := acceleration if input_dir != 0.0 else deceleration
	horizontal = horizontal.move_toward(target, rate * delta)
	
	velocity.x = horizontal.x
	velocity.z = horizontal.z
