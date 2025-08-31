extends Node

@export  var oxygen := 100.0
@export  var max_Oxygen := 100.0

@export var oxygen_Bar : OxygenBar

func Add_Oxygen(amount : float):
	oxygen += amount
	oxygen = clamp(oxygen, 0, max_Oxygen)
	Check_Oxygen()
	if $OxygenTimer:
		$OxygenTimer.start()
	print("recuperaste oxigeno")

func Use_Oxygen(amount : float):
	oxygen -= amount
	
	Check_Oxygen()
	
	if oxygen <= 0:
		$"../..".RestarVida(1)

func Check_Oxygen():
	if oxygen_Bar:
		oxygen_Bar.Update_Bar(max_Oxygen, oxygen)
		print("se llamo a actualizar barra")


func _on_oxygen_timer_timeout():
		Use_Oxygen(5)
