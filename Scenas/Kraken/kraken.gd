extends CharacterBody2D

@export var speed:float = 100

var direction = Vector2.RIGHT


func _physics_process(_delta):
	velocity = direction.normalized() * speed
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$"../Player".RestarVida(1)
		print("DetecteAlPlayer")
