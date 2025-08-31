extends CharacterBody2D

@export var speed: float = 1000.0
var direction := Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$"../Player".RestarVida()
