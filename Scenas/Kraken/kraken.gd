extends CharacterBody2D

@export var speed: float = 200.0  # velocidad de avance (igual que la del juego)
@export var player_path: NodePath

var player

func _ready():
	player = get_node(player_path)
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Avanza hacia la derecha
	position.x += speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		print("Jugador atrapado por el Kraken")
		# Llamar a la lógica de Game Over, por ejemplo:
		get_tree().change_scene_to_file("res://GameOver.tscn")
