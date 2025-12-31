extends Control

func _ready() -> void:
	pass

func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_multiplayer_pressed() -> void:
	# Coming soon - disabled button
	pass
