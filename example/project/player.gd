extends CharacterBody3D
class_name Player

signal bomb_passed(from_player: Player, to_player: Player)
signal player_exploded(player: Player)

@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var jump_force: float = 6.0
@export var player_id: int = 0
@export var is_ai: bool = false

var joystick: VirtualJoystick = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Bomb system
var has_bomb: bool = false
var is_stunned: bool = false
var stun_timer: float = 0.0
const STUN_DURATION: float = 1.0

# Proximity detection
var players_in_range: Array[Player] = []

# Visual references (set in _ready or from scene)
var bomb_visual: Node3D = null
var original_material: Material = null

func _ready() -> void:
	# Get bomb visual if it exists
	if has_node("BombVisual"):
		bomb_visual = $BombVisual
		bomb_visual.visible = false
	
	# Store original material for stun effect
	if has_node("MeshInstance3D"):
		var mesh: MeshInstance3D = $MeshInstance3D
		if mesh.mesh and mesh.mesh.surface_get_material(0):
			original_material = mesh.mesh.surface_get_material(0)

func _physics_process(delta: float) -> void:
	# Update stun timer
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
			_update_stun_visual(false)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Skip movement if stunned or AI (AI uses ai_controller)
	if is_stunned or is_ai:
		if is_stunned:
			velocity.x = 0
			velocity.z = 0
		move_and_slide()
		return
	
	# Get joystick input (human player only)
	var input_direction: Vector2 = Vector2.ZERO
	if joystick:
		input_direction = joystick.get_direction()
	
	# Convert 2D input to 3D movement (XZ plane)
	var direction: Vector3 = Vector3(input_direction.x, 0, input_direction.y)
	
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

func jump() -> void:
	if is_on_floor() and not is_stunned:
		velocity.y = jump_force

# ===== BOMB SYSTEM =====

func give_bomb(apply_stun: bool = true) -> void:
	has_bomb = true
	_update_bomb_visual(true)
	if apply_stun:
		stun(STUN_DURATION)

func remove_bomb() -> void:
	has_bomb = false
	_update_bomb_visual(false)

func stun(duration: float) -> void:
	is_stunned = true
	stun_timer = duration
	_update_stun_visual(true)

func pass_bomb_to(target: Player) -> bool:
	if not has_bomb or target == self:
		return false
	
	if not target in players_in_range:
		return false
	
	remove_bomb()
	target.give_bomb(true)
	bomb_passed.emit(self, target)
	return true

func get_nearest_player_in_range() -> Player:
	if players_in_range.is_empty():
		return null
	
	var nearest: Player = null
	var nearest_dist: float = INF
	
	for p in players_in_range:
		var dist = global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	
	return nearest

func can_pass_bomb() -> bool:
	return has_bomb and not players_in_range.is_empty()

# ===== VISUAL UPDATES =====

func _update_bomb_visual(show: bool) -> void:
	if bomb_visual:
		bomb_visual.visible = show

func _update_stun_visual(stunned: bool) -> void:
	# Visual feedback for stun (could be shader or color change)
	if has_node("MeshInstance3D"):
		var mesh: MeshInstance3D = $MeshInstance3D
		if stunned:
			# Yellow tint when stunned
			var stun_mat = StandardMaterial3D.new()
			stun_mat.albedo_color = Color(1.0, 1.0, 0.3, 1.0)
			mesh.material_override = stun_mat
		else:
			mesh.material_override = null

# ===== PROXIMITY DETECTION =====

func _on_proximity_area_body_entered(body: Node3D) -> void:
	if body is Player and body != self:
		if not body in players_in_range:
			players_in_range.append(body)

func _on_proximity_area_body_exited(body: Node3D) -> void:
	if body is Player:
		players_in_range.erase(body)

