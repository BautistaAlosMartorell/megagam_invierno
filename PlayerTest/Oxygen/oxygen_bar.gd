class_name OxygenBar extends ProgressBar

var target_Value := 100.0

func _process(delta):
	if target_Value >= 0.0:
		var aux
		aux = move_toward(self.value, target_Value, delta * 1.0)
		self.value = aux

func Update_Bar(maxim: float, act: float):
	target_Value = act / maxim
	print("Se actualizo barra")
