extends Control

@onready var continue_button = $VBoxContainer/ContinueButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton

var options_menu_scene = preload("res://UI-Scenes/SC_OptionsMenu.tscn")
var options_menu_instance: Control

func _ready():
	# Connect button signals
	continue_button.pressed.connect(_on_continue_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Hide the menu initially
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		toggle_pause_menu()

func toggle_pause_menu():
	if visible:
		hide()
		get_tree().paused = false
	else:
		show()
		get_tree().paused = true

func _on_continue_button_pressed():
	toggle_pause_menu()

func _on_options_button_pressed():
	# Hide pause menu and show options menu
	hide()
	
	# Create options menu instance if it doesn't exist
	if not options_menu_instance:
		options_menu_instance = options_menu_scene.instantiate()
		add_child(options_menu_instance)
		options_menu_instance.back_button.pressed.connect(_on_options_back_pressed)
	
	options_menu_instance.show()

func _on_options_back_pressed():
	# Hide options menu and show pause menu again
	options_menu_instance.hide()
	show()

func _on_main_menu_button_pressed():
	# Unpause the game
	get_tree().paused = false
	
	# Change to main menu scene
	get_tree().change_scene_to_file("res://UI-Scenes/SC_MainMenu.tscn")
