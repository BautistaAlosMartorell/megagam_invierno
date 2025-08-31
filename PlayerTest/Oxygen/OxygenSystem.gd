extends Node

@export var oxygen := 100.0
@export var max_Oxygen := 100.0
@export var oxygen_Bar : OxygenBar

func Add_Oxygen(amount: float) -> void:
	oxygen = clamp(oxygen + amount, 0.0, max_Oxygen)
	Check_Oxygen()
	if has_node("OxygenTimer"):
		$OxygenTimer.start()
	print("recuperaste oxigeno")

func Use_Oxygen(amount: float) -> void:
	# CLAMP AL RESTAR + CHEQUEO <= 0
	oxygen = max(oxygen - amount, 0.0)
	Check_Oxygen()
	if oxygen <= 0.0:
		# Player está dos niveles arriba: Player/CanvasLayer/OxygenComponent
		var player := get_node_or_null("../..")
		if player and player.has_method("RestarVida"):
			player.RestarVida()

func Check_Oxygen() -> void:
	if oxygen_Bar:
		oxygen_Bar.Update_Bar(max_Oxygen, oxygen)
		# print("se llamo a actualizar barra")

func _on_oxygen_timer_timeout() -> void:
	Use_Oxygen(5.0)
