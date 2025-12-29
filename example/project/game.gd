extends Node3D

@onready var player: Player = $Player
@onready var joystick: VirtualJoystick = $CanvasLayer/VirtualJoystick

func _ready() -> void:
	# Connect joystick to player
	player.set_joystick(joystick)
