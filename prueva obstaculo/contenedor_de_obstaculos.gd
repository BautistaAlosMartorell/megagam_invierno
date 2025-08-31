extends Node2D

# --- NODOS ---
@onready var temporizador: Timer = $"tiempo de generacion"   # conectá su signal timeout
@export var objetivo_path: NodePath                          # Player o Camera2D
@onready var objetivo: Node2D = get_node(objetivo_path)

# --- ESCENA DEL OBSTÁCULO ---
const OBSTACULO := preload("res://Scenas/obstaculos/obstaculo.tscn")

# --- PARÁMETROS ---
@export var velocidad := 300.0              # velocidad a la que "corre" el mundo a la izquierda
@export var y_min := -68.0
@export var y_max :=  90.0
@export var offset_spawn := 0.6             # cuántas pantallas por delante spawnea
@export var prob_doble := 0.25              # 25% de las veces genera un segundo obstáculo
@export var separacion_doble_x := 150.0     # separación horizontal entre 1º y 2º obstáculo
@export var intervalo_min := 0.7            # espera aleatoria entre spawns
@export var intervalo_max := 1.6
@export var margen_despawn := 300.0         # cuánto atrás de la cámara elimino obstáculos

func _ready() -> void:
	randomize()
	temporizador.one_shot = true
	_programar_siguiente_spawn()
	# Conectar señal (si no la conectaste en el editor)
	if not temporizador.timeout.is_connected(_on_tiempo_de_generacion_timeout):
		temporizador.timeout.connect(_on_tiempo_de_generacion_timeout)

func _process(delta: float) -> void:
	# Mover SOLO los nodos del grupo "obstaculos"
	for o in get_tree().get_nodes_in_group("obstaculos"):
		o.position.x -= velocidad * delta
		# Despawn cuando quedan bastante detrás de la cámara/jugador
		var limite_atras := objetivo.global_position.x - get_viewport_rect().size.x * 0.5 - margen_despawn
		if o.global_position.x < limite_atras:
			o.queue_free()

func _on_tiempo_de_generacion_timeout() -> void:
	# X de spawn: por delante de la cámara/jugador (no un número fijo)
	var ancho_vista := get_viewport_rect().size.x
	var x_spawn := objetivo.global_position.x + ancho_vista * offset_spawn

	_spawn_uno(Vector2(x_spawn, randf_range(y_min, y_max)))

	# A veces generamos un segundo
	if randf() < prob_doble:
		_spawn_uno(Vector2(x_spawn + separacion_doble_x, randf_range(y_min, y_max)))

	_programar_siguiente_spawn()

func _spawn_uno(pos: Vector2) -> void:
	var o = OBSTACULO.instantiate()
	add_child(o)
	o.global_position = pos
	o.add_to_group("obstaculos")

func _programar_siguiente_spawn() -> void:
	temporizador.wait_time = randf_range(intervalo_min, intervalo_max)
	temporizador.start()
