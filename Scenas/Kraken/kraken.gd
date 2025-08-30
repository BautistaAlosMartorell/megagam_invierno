extends CharacterBody2D

@export var speed:float = 100
var direction = Vector2.RIGHT
func _physics_process(delta):
	velocity = direction.normalized() * speed
	move_and_slide()
	
