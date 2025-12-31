extends Node3D

@export var match_duration: float = 80.0
@export var bomb_time_min: float = 20.0
@export var bomb_time_max: float = 25.0
@export var max_explosions: int = 3

@onready var player: Player = $Player
@onready var bot: Player = $Bot
@onready var joystick: VirtualJoystick = $CanvasLayer/VirtualJoystick
@onready var jump_button: JumpButton = $CanvasLayer/JumpButton
@onready var pass_button: PassButton = $CanvasLayer/PassButton
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel
@onready var ai_controller: AIController = $Bot/AIController

enum GameState { PLAYING, GAME_OVER }
var state: GameState = GameState.PLAYING
var bomb_timer: float = 0.0
var match_timer: float = 0.0
var explosion_count: int = 0
var player_score: int = 0
var bot_score: int = 0
var all_players: Array[Player] = []

func _ready() -> void:
	add_to_group("game")
	
	# Setup players
	player.player_id = 0
	player.is_ai = false
	player.add_to_group("players")
	
	bot.player_id = 1
	bot.is_ai = true
	bot.add_to_group("players")
	
	all_players = [player, bot]
	
	# Connect joystick to human player
	player.set_joystick(joystick)
	
	# Connect buttons
	jump_button.jump_pressed.connect(_on_jump_pressed)
	pass_button.pass_pressed.connect(_on_pass_pressed)
	
	# Connect bomb signals
	player.bomb_passed.connect(_on_bomb_passed)
	bot.bomb_passed.connect(_on_bomb_passed)
	
	# Setup AI controller
	ai_controller.player = bot
	
	# Hide game over panel
	if game_over_panel:
		game_over_panel.visible = false
	
	# Start game
	_start_match()

func _start_match() -> void:
	state = GameState.PLAYING
	match_timer = match_duration
	explosion_count = 0
	player_score = 0
	bot_score = 0
	
	if game_over_panel:
		game_over_panel.visible = false
	
	_start_round()

func _start_round() -> void:
	# Random bomb timer between min and max
	bomb_timer = randf_range(bomb_time_min, bomb_time_max)
	
	# Reset players
	for p in all_players:
		p.remove_bomb()
		p.is_stunned = false
	
	# Random bomb assignment
	var random_player = all_players[randi() % all_players.size()]
	random_player.give_bomb(false)  # No stun on initial assignment

func _process(delta: float) -> void:
	if state != GameState.PLAYING:
		return
	
	# Update timers
	bomb_timer -= delta
	match_timer -= delta
	
	# Update HUD
	_update_hud()
	
	# Update pass button state
	pass_button.set_enabled(player.can_pass_bomb())
	
	# Check bomb explosion
	if bomb_timer <= 0:
		_explode_bomb()
	
	# Check match end
	if match_timer <= 0 or explosion_count >= max_explosions:
		_end_match()

func _update_hud() -> void:
	if timer_label:
		var bomb_seconds = max(0, ceil(bomb_timer))
		var match_seconds = max(0, ceil(match_timer))
		
		# Show bomb timer (big) and match timer (small)
		timer_label.text = str(int(bomb_seconds)) + "\n[" + str(int(match_seconds)) + "s]"
		
		# Color based on bomb time remaining
		if bomb_timer <= 5:
			timer_label.modulate = Color(1, 0, 0)  # Red
		elif bomb_timer <= 10:
			timer_label.modulate = Color(1, 0.5, 0)  # Orange
		else:
			timer_label.modulate = Color(1, 1, 1)  # White

func _explode_bomb() -> void:
	explosion_count += 1
	
	# Find who had the bomb and update score
	var loser: Player = null
	for p in all_players:
		if p.has_bomb:
			loser = p
			break
	
	if loser == player:
		bot_score += 1
	else:
		player_score += 1
	
	print("BOOM! Explosion #", explosion_count, " - Score: Player ", player_score, " | Bot ", bot_score)
	
	# Check if match should end
	if explosion_count >= max_explosions or match_timer <= 0:
		_end_match()
	else:
		# Start next round after short delay
		_start_round()

func _end_match() -> void:
	state = GameState.GAME_OVER
	
	# Show game over
	if game_over_panel:
		game_over_panel.visible = true
		var result_label = game_over_panel.get_node_or_null("ResultLabel")
		if result_label:
			var result_text = "FINAL SCORE\n\nYOU: " + str(player_score) + "\nBOT: " + str(bot_score) + "\n\n"
			if player_score > bot_score:
				result_text += "YOU WIN! 🎉"
			elif bot_score > player_score:
				result_text += "YOU LOSE! 💥"
			else:
				result_text += "TIE GAME! 🤝"
			result_label.text = result_text

func _on_jump_pressed() -> void:
	player.jump()

func _on_pass_pressed() -> void:
	if player.can_pass_bomb():
		var target = player.get_nearest_player_in_range()
		if target:
			player.pass_bomb_to(target)

func _on_bomb_passed(from: Player, to: Player) -> void:
	print("Bomb passed from Player ", from.player_id, " to Player ", to.player_id)

func restart_game() -> void:
	_start_match()

func exit_to_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
