extends Control


func _on_bt_play_pressed() -> void:
	print("Game Started")
	#get_tree().change_scene_to_file()


func _on_bt_options_pressed() -> void:
	print("Options Enabled")


func _on_bt_exit_pressed() -> void:
	get_tree().quit()
