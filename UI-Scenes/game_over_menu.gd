extends CanvasLayer

@onready var restart_button = $VBoxContainer/VBoxContainer/RestartButton
@onready var main_menu_button = $VBoxContainer/VBoxContainer/MainMenuButton
@onready var exit_button = $VBoxContainer/VBoxContainer/ExitButton
@onready var result_label = $VBoxContainer/ResultLabel

var is_win: bool = false

func _ready():
	hide()

func show_game_over(win: bool):
	is_win = win
	get_tree().paused=true
	if win:
		result_label.text = "YOU WIN!"
		result_label.modulate = Color.GREEN
	else:
		result_label.text = "GAME OVER"
		result_label.modulate = Color.RED
	
	show()

func _on_restart_button_pressed():
	get_tree().paused=false
	# Hide the menu
	hide()
	# Restart the current scene
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	
	# Change to main menu scene
	get_tree().change_scene_to_file("res://UI-Scenes/SC_MainMenu.tscn")

func _on_exit_button_pressed():
	get_tree().paused=false
	# Quit the game
	get_tree().quit()
