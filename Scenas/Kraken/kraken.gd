extends CharacterBody2D

@export var speed:float = 100

var direction = Vector2.RIGHT
@onready var player = get_node("Player")

func _physics_process(delta):
	velocity = direction.normalized() * speed
	move_and_slide()

func _on_Area2D_body_enterede(body):
	if body.name == "Player":
		body.RestarVida
