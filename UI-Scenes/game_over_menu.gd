extends Control

@onready var restart_button = $VBoxContainer/RestartButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var result_label = $VBoxContainer/ResultLabel

var is_win: bool = false

func _ready():
	# Connect button signals
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Hide the menu initially
	hide()

func show_game_over(win: bool):
	is_win = win
	
	if win:
		result_label.text = "YOU WIN!"
		result_label.modulate = Color.GREEN
	else:
		result_label.text = "GAME OVER"
		result_label.modulate = Color.RED
	
	show()

func _on_restart_button_pressed():
	# Hide the menu
	hide()
	
	# Restart the current scene
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	# Change to main menu scene
	get_tree().change_scene_to_file("res://UI-Scenes/SC_MainMenu.tscn")

func _on_exit_button_pressed():
	# Quit the game
	get_tree().quit()
