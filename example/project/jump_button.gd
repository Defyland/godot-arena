extends Control
class_name JumpButton

signal jump_pressed

@onready var button: Panel = $Button

var _pressed: bool = false
var _touch_index: int = -1

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_point_inside_button(event.position):
			_pressed = true
			_touch_index = event.index
			_on_press()
	else:
		if event.index == _touch_index:
			_reset()

func _is_point_inside_button(point: Vector2) -> bool:
	var button_center: Vector2 = button.global_position + button.size / 2
	var distance: float = point.distance_to(button_center)
	return distance <= button.size.x / 2

func _on_press() -> void:
	jump_pressed.emit()
	# Visual feedback
	button.modulate = Color(0.7, 0.7, 0.7, 1.0)

func _reset() -> void:
	_pressed = false
	_touch_index = -1
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func is_pressed() -> bool:
	return _pressed
