extends CharacterBody2D

@export var velocidad: int = -340
var en_juego: bool = true

func _process(delta: float) -> void:
	position.x += velocidad * delta
	
	if global_position.x <= -404:
		queue_free()

func _on_area_body_entered(body: Node) -> void:
	if body is RigidBody2D:

		pass
