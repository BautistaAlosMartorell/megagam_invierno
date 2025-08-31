extends Control

@onready var options_menu = $OptionsMenu

func _ready():
	# Create options menu instance
	var options_scene = preload("res://UI-Scenes/SC_OptionsMenu.tscn")
	options_menu = options_scene.instantiate()
	add_child(options_menu)
	options_menu.hide()
	
	# Connect options back button
	options_menu.back_button.pressed.connect(_on_options_back_pressed)

func _on_bt_play_pressed() -> void:
	print("Game Started")
	#get_tree().change_scene_to_file("res://Scenas/main.tscn")


func _on_bt_options_pressed() -> void:
	options_menu.show()


func _on_bt_exit_pressed() -> void:
	get_tree().quit()

func _on_options_back_pressed():
	options_menu.hide()
