class_name Player extends CharacterBody3D

@export_group("Movement Settings")
@export var turn_speed := 180.0
@export var quick_turn_speed := 0.3
@export var walk_speed := 80.0
@export var run_speed := 280.0

const GRAVITY = -9.81
var is_quick_turning := false

func handle_turn(delta):
	var turn_dir = Input.get_axis("turn_left", "turn_right")
	rotation_degrees.y -= turn_dir*turn_speed*delta
	
func handle_walk(delta):
	var input_dir = Input.get_axis("move_backward", "move_forward")
	var walk_velocity = -basis.z*input_dir*walk_speed*delta
	velocity.x = walk_velocity.x
	velocity.z = walk_velocity.z
	
func handle_run(delta):
	if Input.is_action_pressed("move_backward"):
		handle_walk(delta)
		return
	var input_strength = Input.get_axis("move_backward", "move_forward")
	var walk_velocity = -basis.z*input_strength*run_speed*delta
	velocity.x = walk_velocity.x
	velocity.z = walk_velocity.z
	
func handle_gravity(delta):
	if is_on_floor():
		velocity.y = -2
	else:
		velocity.y += GRAVITY*delta

func quick_turn():
	is_quick_turning = true
	var target_y_rotation = rotation_degrees.y+180
	var tween := create_tween() as Tween
	tween.tween_property(self, "rotation_degrees:y", target_y_rotation, quick_turn_speed)
	tween.finished.connect(func(): is_quick_turning = false)

func _physics_process(delta: float) -> void:
	if is_quick_turning:
		velocity.x = 0
		velocity.z = 0
	else:
		# Only handle normal movement and turning if NOT quick turning
		handle_turn(delta)
		if Input.is_action_pressed("run"):
			handle_run(delta)
		else:
			handle_walk(delta)
	
	handle_gravity(delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quick_turn") and not is_quick_turning:
		quick_turn()
