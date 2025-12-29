extends Control
class_name VirtualJoystick

@export var dead_zone: float = 0.2
@export var clamp_zone: float = 1.0

@onready var base: Panel = $Base
@onready var stick: Panel = $Base/Stick

var _pressed: bool = false
var _touch_index: int = -1
var _direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	stick.pivot_offset = stick.size / 2

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_point_inside_base(event.position):
			_pressed = true
			_touch_index = event.index
			_update_stick_position(event.position)
	else:
		if event.index == _touch_index:
			_reset()

func _handle_drag(event: InputEventScreenDrag) -> void:
	if _pressed and event.index == _touch_index:
		_update_stick_position(event.position)

func _is_point_inside_base(point: Vector2) -> bool:
	var base_center: Vector2 = base.global_position + base.size / 2
	var distance: float = point.distance_to(base_center)
	return distance <= base.size.x / 2

func _update_stick_position(touch_pos: Vector2) -> void:
	var base_center: Vector2 = base.global_position + base.size / 2
	var offset: Vector2 = touch_pos - base_center
	var max_distance: float = base.size.x / 2 * clamp_zone
	
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance
	
	stick.global_position = base_center + offset - stick.size / 2
	
	# Calculate normalized direction
	var normalized_offset: Vector2 = offset / max_distance
	if normalized_offset.length() < dead_zone:
		_direction = Vector2.ZERO
	else:
		_direction = normalized_offset

func _reset() -> void:
	_pressed = false
	_touch_index = -1
	_direction = Vector2.ZERO
	# Reset stick to center
	var base_center: Vector2 = base.size / 2
	stick.position = base_center - stick.size / 2

func get_direction() -> Vector2:
	return _direction

func is_pressed() -> bool:
	return _pressed
