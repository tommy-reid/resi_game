extends CharacterBody3D

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

# --- ANIMATION SETTINGS ---
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree["parameters/playback"]

var current_aim_blend: float = 0.0
const AIM_BLEND_SPEED: float = 5.0 # How quickly the gun pitches up/down

func _physics_process(delta: float) -> void:
	# Check if the player is holding down the aim button
	var is_aiming := Input.is_action_pressed("aim")
	
	# 1. Quick Turn (Only allowed if NOT already quick turning AND NOT aiming)
	if Input.is_action_just_pressed("quick_turn") and not Input.is_action_pressed("move_forward") and not is_quick_turning and not is_aiming:
		print('turning ')
		_quick_turn()
	
	# 2. Turning (Allowed during regular idle/walk, or in place while aiming)
	if not is_quick_turning:
		_handle_turn(delta)
	
	# 3. Handle Movement & State Transitions
	if is_aiming:
		# If aiming, freeze walking velocity instantly
		_freeze_movement(delta)
		_handle_aim_animation(delta)
	else:
		# Process regular walking if not aiming
		_handle_walk(delta)
		_handle_movement_animations()
		
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
	
	# Reset multiplier to default 1.0 at start of calculations
	multiplier = 1.0
	
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


# Decelerates character back to zero seamlessly when aiming cuts in
func _freeze_movement(delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(Vector3.ZERO, deceleration * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z


# Handles the smoothed BlendSpace1D values when raising weapon
func _handle_aim_animation(delta: float) -> void:
	anim_state.travel("aim_direction")
	
	# Get vertical pitch adjustments from user input (-1 down, 1 up)
	var target_input := Input.get_axis("move_backward", "move_forward")
	
	# Linear interpolate to prevent the rapid/instant bone jittering
	current_aim_blend = move_toward(current_aim_blend, target_input, AIM_BLEND_SPEED * delta)
	
	# Update the value slider inside your BlendSpace1D node
	anim_tree.set("parameters/aim_direction/blend_position", current_aim_blend)


# Handles travel states between standing still and moving
func _handle_movement_animations() -> void:
	# Using horizontal velocity vector length to evaluate motion
	var horizontal_speed := Vector3(velocity.x, 0.0, velocity.z).length()
	
	if horizontal_speed > 0.1:
		anim_state.travel("walk")
	else:
		anim_state.travel("idle")
