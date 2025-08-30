extends Node2D
@onready var timer: Timer = $"tiempo de generacion"
const OBSTACULO = preload("res://obstaculos/obstaculo.tscn")

# Velocidad a la que se mueve el escenario
var velocidad: float = 300.0  # píxeles por segundo

func _ready():
	randomize()  
	timer.start()

func _process(delta):
	# Crear obstáculo cuando el timer se detiene
	if timer.is_stopped():
		crear_obstaculo()
		timer.start()

	# Mover todos los obstáculos hijos hacia la izquierda
	for hijo in get_children():
		if hijo.is_in_group("obstaculos"):
			hijo.position.x -= velocidad * delta
			# Si el obstáculo sale de la pantalla, lo eliminamos
			if hijo.position.x < -100:
				hijo.queue_free()

func crear_obstaculo():
	var nuevo_obstaculo = OBSTACULO.instantiate()
	nuevo_obstaculo.position = Vector2(1000, randf_range(-68.0, 90.0))
	add_child(nuevo_obstaculo)
	# Lo agregamos a un grupo para identificarlo fácilmente
	nuevo_obstaculo.add_to_group("obstaculos")
