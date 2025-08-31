extends CanvasLayer
#@onready var v_box_container: VBoxContainer = $VBoxContainer

func _ready():
	pass
	# Create options menu instance
	
	# Connect options back button


func _on_btn_options_pressed() -> void:
	$"MainMenuHolder".hide()
	$"../Opciones".show()


func _on_btn_play_pressed() -> void:
	self.hide()
	$"../Opciones".hide()


func _on_btn_exit_pressed() -> void:
	get_tree().quit()
