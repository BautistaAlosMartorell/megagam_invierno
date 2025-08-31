extends Area2D

@export var oxygen_amount: float = 25.0 

func _on_body_entered(body):
	var oxygen_node = body.get_node_or_null("CanvasLayer/OxygenComponent")
	if oxygen_node and oxygen_node.has_method("Add_Oxygen"):
		oxygen_node.Add_Oxygen(oxygen_amount)
		queue_free() 


func _on_timer_timeout() -> void:
	queue_free() 
