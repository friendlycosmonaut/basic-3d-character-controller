extends CharacterBody3D

## Export variables
@export var MOVE_SPEED := 2.5
@export var RUN_SPEED := 4.0
@export var ROLL_SPEED := 5.0
@export var JUMP_VELOCITY := 5.5
## Multiplier for the player's turn.
@export_range(0.0, 1.0, 0.01) var TURN_IMMEDIATE := 1.0
## Multiplier for the player's acceleration.
@export_range(0.0, 1.0, 0.01) var ACCELERATE_IMMEDIATE := 0.75
## Multiplier for the player's deceleration.
@export_range(0.0, 1.0, 0.01) var DECELERATE_IMMEDIATE := 0.75
## Multiplier for the player's jump input.
@export_range(0.0, 1.0, 0.01) var VARIABLE_JUMP := 0.13

## Important nodes.
@onready var camera := %Camera
@onready var model := $Model
@onready var animation_player := $Model/AnimationPlayer

## Instance shared variables.
var speed := 0.0
var direction := Vector2()
var input_dir := Vector2()

## State variables and enum.
enum State {
	IDLE,
	JUMP_START,
	JUMP,
	ROLL
}
var state : Callable
var state_id : State


## Set up our player.
func _ready() -> void: 
	## Ensures the camera doesn't "bump into" the player -- see camera.gd.
	camera.add_excluded_object(self)
	## Capture the mouse.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	## Set up our animation blend times and transitions to look better!
	initialise_animations()
	## Set our initial state as idle.
	change_state(State.IDLE)


## Call our state, update velocity and apply movement.
func _physics_process(delta: float) -> void:
	## Fast quit.
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
	
	## Run the state.
	state.call(delta)
	
	## Velocity calculations.
	velocity.x = direction.x * speed
	velocity.z = direction.y * speed
	
	## Gravity is always applied.
	velocity += get_gravity() * delta
	move_and_slide()


## Changes the current state to a given new state.
## We could also put state cleanup/initialisation here too...
func change_state(new_state):
	state_id = new_state
	match state_id:
		State.IDLE:
			state = _idle
		State.JUMP_START:
			state = _jump_start
		State.JUMP:
			state = _jump
		State.ROLL:
			state = _roll


## Shared player movement input and camera turn code.
## Returns whether or not there is currently ANY movement input.
func turn_with_input() -> bool:
	## Get input according to Project -> Project Settings -> Input Map.
	input_dir = Input.get_vector("left", "right", "up", "down")
	## If this vector is zero (or approximately), don't bother updating.
	var is_move_input = not input_dir.is_zero_approx()
	if is_move_input:
		## Transform our direction to be relative to the camera's y rotation.
		## For example, UP should always move us towards where the camera is pointing.
		var goal_direction = input_dir.rotated(-camera.rotation.y)
		## Because move_toward uses linear interpolation, we provide an eased delta.
		## Otherwise the turn_immediate value has too much weight at low values.
		direction = direction.move_toward(goal_direction, ease(TURN_IMMEDIATE, 4.0))
		
		## Turn to face our direction.
		var goal_position = global_position + Vector3(direction.x, 0.0, direction.y)
		if global_position != goal_position:
			global_rotation.y = lerp_angle(global_rotation.y, atan2(direction.x, direction.y), 0.2)
	
	## Return whether or not we have received movement input.
	return is_move_input


## Changes our speed depending on whether we are moving, running, or idle.
func update_move_speed(is_moving):
	if is_moving:
		if Input.is_action_pressed("run"):
			speed = move_toward(speed, RUN_SPEED, ease(ACCELERATE_IMMEDIATE, 4.0))
		else:
			speed = move_toward(speed, MOVE_SPEED, ease(ACCELERATE_IMMEDIATE, 4.0))
	else:
		speed = move_toward(speed, 0.0, ease(DECELERATE_IMMEDIATE, 4.0))


## Initialises animation speeds, transitions, and blend times.
func initialise_animations() -> void:
	## Necessary for our transitions from starting to jump/landing.
	animation_player.animation_set_next("Jump_Land", "Idle")
	animation_player.animation_set_next("Jump_Start", "Jump")
	
	## Not necessary for functionality, but makes the animations look nicer/smoother!
	animation_player.speed_scale = 1.4
	animation_player.set_default_blend_time(0.3)
	animation_player.set_blend_time("Jump_Land", "Idle", 0.5)
	animation_player.set_blend_time("Jump_Land", "Sprint", 0.5)
	animation_player.set_blend_time("Jump_Land", "Jog_Fwd", 0.5)


## State callable functions.
func _idle(_delta: float):
	var is_moving = turn_with_input()
	update_move_speed(is_moving)
	
	## Handle Idle/Move/Run animations.
	if(input_dir == Vector2.ZERO): # Are we moving?
		if animation_player.current_animation != "Idle" and animation_player.current_animation != "Jump_Land": 
			animation_player.play("Idle")
	else:
		if speed > MOVE_SPEED: # How fast?
			if animation_player.current_animation != "Sprint":
				animation_player.play("Sprint")
		elif animation_player.current_animation != "Jog_Fwd": 
			animation_player.play("Jog_Fwd")
	
	## Check for state change transitions.
	## Fall off an edge?
	if not is_on_floor():
		change_state(State.JUMP)
	## Roll?
	elif Input.is_action_pressed("roll"):
		change_state(State.ROLL)
	## Jump?
	elif Input.is_action_pressed("jump"):
		change_state(State.JUMP_START)


## An intentional jump from the player, unlike falling off an edge.
## Includes the jump start animation and then passes right on to the JUMP state.
func _jump_start(_delta: float):
	animation_player.play("Jump_Start")
	animation_player.advance(0.05) # Just looks a bit better.
	
	## Launch off the ground!
	velocity.y = JUMP_VELOCITY
	
	## Move right on to the JUMP state.
	change_state(State.JUMP)


## Jump until we hit the floor.
func _jump(_delta: float):
	var is_moving = turn_with_input()
	update_move_speed(is_moving)
	
	## Control for variable jump when player is not holding down jump button
	if not Input.is_action_pressed("jump") and velocity.y > 0.0:
		velocity.y = move_toward(velocity.y, 0.0, VARIABLE_JUMP)
	
	## Check for state change transitions.
	if is_on_floor():
		animation_player.play("Jump_Land")
		change_state(State.IDLE)
	elif animation_player.current_animation != "Jump_Start":
		animation_player.play("Jump")


## Roll forwards at a constant speed.
func _roll(_delta: float):
	turn_with_input()
	
	## Rolling has a constant speed.
	speed = ROLL_SPEED
	
	## Check for state change transitions.
	if is_on_floor(): 
		if animation_player.current_animation != "Roll":
			animation_player.play("Roll")
		elif animation_player.current_animation_position >= 1.28:
			change_state(State.IDLE)
	else:
		change_state(State.JUMP)
