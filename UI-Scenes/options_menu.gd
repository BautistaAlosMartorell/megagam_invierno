extends CanvasLayer

@onready var volume_slider = $TabContainer/Sound/MarginContainer/VBoxContainer/VolumeSlider
@onready var volume_value = $TabContainer/Sound/MarginContainer/VBoxContainer/VolumeValue
@onready var back_button = $BackButton

func _ready():
	hide()
	# Load saved volume setting
	var config = ConfigFile.new()
	var saved_volume = 0.5  # Default volume
	
	if config.load("user://settings.cfg") == OK:
		saved_volume = config.get_value("Audio", "MasterVolume", 0.5)
	
	volume_slider.value = saved_volume
	volume_value.text = str(int(saved_volume * 100)) + "%"
	
	# Connect signals
	volume_slider.value_changed.connect(_on_volume_slider_changed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_volume_slider_changed(value: float):
	# Convert linear value to decibels and apply to master bus
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
	
	# Update volume value label
	volume_value.text = str(int(value * 100)) + "%"
	
	# Save volume setting
	var config = ConfigFile.new()
	config.set_value("Audio", "MasterVolume", value)
	config.save("user://settings.cfg")

func _on_back_button_pressed():
	# Hide this menu and return to previous menu
	hide()
	$"../Pausa".show()
	# If we came from pause menu, show it again
	# If we came from main menu, show it again
	# This will be handled by the calling menu
