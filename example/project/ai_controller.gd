extends Node
class_name AIController

@export var player: Player
@export var chase_speed_multiplier: float = 0.8
@export var flee_speed_multiplier: float = 1.0
@export var direction_change_interval: float = 0.5

var target_direction: Vector3 = Vector3.ZERO
var direction_timer: float = 0.0
var arena_bounds: Rect2 = Rect2(-9, -5, 18, 10)  # x, z bounds

func _ready() -> void:
	if not player:
		push_error("AIController: No player assigned!")
		return
	player.is_ai = true

func _physics_process(delta: float) -> void:
	if not player or player.is_stunned:
		return
	
	direction_timer -= delta
	if direction_timer <= 0:
		direction_timer = direction_change_interval
		_update_target_direction()
	
	_apply_movement(delta)

func _update_target_direction() -> void:
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		_random_wander()
		return
	
	if player.has_bomb:
		# Chase nearest player
		var nearest = _find_nearest_player()
		if nearest:
			var dir = (nearest.global_position - player.global_position).normalized()
			target_direction = Vector3(dir.x, 0, dir.z)
		else:
			_random_wander()
	else:
		# Flee from bomb holder
		var bomb_holder = _find_bomb_holder()
		if bomb_holder and bomb_holder != player:
			var away = (player.global_position - bomb_holder.global_position).normalized()
			target_direction = Vector3(away.x, 0, away.z)
			# Add some randomness to fleeing
			target_direction.x += randf_range(-0.3, 0.3)
			target_direction.z += randf_range(-0.3, 0.3)
			target_direction = target_direction.normalized()
		else:
			_random_wander()
	
	# Avoid arena edges
	_apply_edge_avoidance()

func _random_wander() -> void:
	target_direction = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	).normalized()

func _apply_edge_avoidance() -> void:
	var pos = player.global_position
	var avoid = Vector3.ZERO
	
	# Check x bounds
	if pos.x < arena_bounds.position.x + 2:
		avoid.x = 1.0
	elif pos.x > arena_bounds.end.x - 2:
		avoid.x = -1.0
	
	# Check z bounds
	if pos.z < arena_bounds.position.y + 2:
		avoid.z = 1.0
	elif pos.z > arena_bounds.end.y - 2:
		avoid.z = -1.0
	
	if avoid.length() > 0:
		target_direction = (target_direction + avoid).normalized()

func _apply_movement(delta: float) -> void:
	var speed_mult = chase_speed_multiplier if player.has_bomb else flee_speed_multiplier
	var speed = player.move_speed * speed_mult
	
	player.velocity.x = target_direction.x * speed
	player.velocity.z = target_direction.z * speed
	
	# Rotate to face direction
	if target_direction.length() > 0.1:
		var target_rot = atan2(target_direction.x, target_direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rot, player.rotation_speed * delta)
	
	# AI can also try to pass bomb if player nearby
	if player.has_bomb and player.can_pass_bomb():
		var target = player.get_nearest_player_in_range()
		if target:
			player.pass_bomb_to(target)

func _find_nearest_player() -> Player:
	var players = get_tree().get_nodes_in_group("players")
	var nearest: Player = null
	var nearest_dist: float = INF
	
	for p in players:
		if p == player:
			continue
		var dist = player.global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	
	return nearest

func _find_bomb_holder() -> Player:
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p.has_bomb:
			return p
	return null
