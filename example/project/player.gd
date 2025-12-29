extends CharacterBody3D
class_name Player

@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0

var joystick: VirtualJoystick = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Get joystick input
	var input_direction: Vector2 = Vector2.ZERO
	if joystick:
		input_direction = joystick.get_direction()
	
	# Convert 2D input to 3D movement (XZ plane)
	var direction: Vector3 = Vector3(input_direction.x, 0, -input_direction.y)
	
	if direction.length() > 0.1:
		# Move the player
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		# Rotate player to face movement direction
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
	else:
		# Stop horizontal movement
		velocity.x = move_toward(velocity.x, 0, move_speed * delta * 5)
		velocity.z = move_toward(velocity.z, 0, move_speed * delta * 5)
	
	move_and_slide()

func set_joystick(js: VirtualJoystick) -> void:
	joystick = js
