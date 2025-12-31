extends Control
class_name PassButton

signal pass_pressed

@onready var button: Panel = $Button

var _pressed: bool = false
var _touch_index: int = -1
var _is_enabled: bool = false

func _input(event: InputEvent) -> void:
	if not _is_enabled:
		return
	
	if event is InputEventScreenTouch:
		_handle_touch(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_point_inside_button(event.position):
			_pressed = true
			_touch_index = event.index
			pass_pressed.emit()
	else:
		if event.index == _touch_index:
			_pressed = false
			_touch_index = -1

func _is_point_inside_button(point: Vector2) -> bool:
	var btn_rect = button.get_global_rect()
	return btn_rect.has_point(point)

func set_enabled(enabled: bool) -> void:
	_is_enabled = enabled
	_update_visual()

func _update_visual() -> void:
	if not button:
		return
	
	if _is_enabled:
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		button.modulate = Color(0.5, 0.5, 0.5, 0.4)
