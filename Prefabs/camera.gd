extends Node3D

## The sensitivity/speed of mouse movement.
@export_range(0.0, 1.0) var MOUSE_SENSITIVITY := 0.01
## The sensitivity/speed of controller movement.
@export_range(0.0, 1.0) var CONTROLLER_SENSITIVITY := 0.05
## Limit how far the camera can tilt up/down.
@export_range(0.0, 90.0) var TILT_LIMIT := 80
## Controls how quickly the camera moves towards its target rotation.
@export_range(0.0, 1.0) var DAMPING := 0.25
## What object are we following, if any?
@export var following: Node3D = null

## We may need to add exclusions to our spring arm with add_excluded_object.
@onready var spring_arm := get_node("SpringArm3D")
## We update the camera's rotation towards this target according to DAMPING.
@onready var camera_rotation_target := Vector3(rotation)


## Update the camera's position and rotation.
func _physics_process(_delta: float) -> void:
	## If we are following an object, update our position to it.
	if following != null:
		global_position = following.global_position
	
	## Rotate the camera target according to controller movement, if any.
	var x = Input.get_axis("camera_right", "camera_left")
	var y = Input.get_axis("camera_up", "camera_down")
	rotate_camera_target(x, y, CONTROLLER_SENSITIVITY)
	
	## Update rotation towards goal.
	rotation.x = lerp_angle(rotation.x, camera_rotation_target.x, DAMPING)
	rotation.y = lerp_angle(rotation.y, camera_rotation_target.y, DAMPING)


## Rotate the camera target according to mouse movement, if any.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camera_target(event.relative.x, event.relative.y, MOUSE_SENSITIVITY)


## Rotates the camera target by a given x, y, and sensitivity.
func rotate_camera_target(x, y, sensitivity) -> void:
	camera_rotation_target.y -= x * sensitivity
	camera_rotation_target.x -= y * sensitivity
	
	## Prevent the camera from rotating too far up or down.
	var t = deg_to_rad(TILT_LIMIT)
	camera_rotation_target.x = clampf(camera_rotation_target.x, -t, t)


## Helper function for excluding an object from our spring arm's collision.
## This lets us avoid "bumping into" the object we follow.
func add_excluded_object(node) -> void:
	spring_arm.add_excluded_object(node)
