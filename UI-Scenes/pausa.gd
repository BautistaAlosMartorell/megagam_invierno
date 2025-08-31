extends CanvasLayer


	
func _physics_process(_delta):
	if Input.is_action_just_pressed("Pausa"):
		get_tree().paused= not get_tree().paused
		show()
		
		
func _on_button_pressed() -> void:
	get_tree().paused = false
	hide()
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
