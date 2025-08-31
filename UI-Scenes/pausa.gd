extends CanvasLayer


func _physics_process(_delta):
	if Input.is_action_just_pressed("Pausa"):
		get_tree().paused= not get_tree().paused
		$ColorRect.visible = not $ColorRect.visible 
		
		
func _on_button_pressed() -> void:
	get_tree().paused = false
	$ColorRect.visible = false
	pass # Replace with function body.
