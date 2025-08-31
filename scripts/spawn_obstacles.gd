# res://scripts/SpawnObstaculos.gd
extends Node2D

# ---- A QUIÉN SEGUIR (Camera2D o Player) ----
@export_node_path("Node2D") var seguir_path: NodePath
var seguir: Node2D

# ---- Escenas de obstáculos ----
@export var obstacle_scenes: Array[PackedScene] = []    # opcional, podés dejarlo vacío
const ROCK   := preload("res://Scenas/rock.tscn")
const ROCK_2 := preload("res://Scenas/rock_2.tscn")     # ajustá las rutas si difieren

# ---- Estado interno ----
var obstacles: Array[Node2D] = []
var next_spawn_x: float = -INF

# ---- Tuning ----
@export var min_gap_px := 320.0       # distancia mínima al próximo spawn
@export var max_gap_px := 520.0       # distancia máxima al próximo spawn
@export var offset_spawn := 0.65      # cuánto por delante del borde derecho
@export var prob_doble := 0.18        # probabilidad de generar 2
@export var doble_sep_x := 140.0      # separación X entre el 1º y 2º
@export var margen_vertical := 24.0   # no pegarnos al top/bottom
@export var margen_spawn_x := 40.0    # empuje extra de spawn
@export var mover_obstaculos := true  # si el mundo “corre” a la izquierda
@export var velocidad := 300.0        # px/s hacia la izquierda
@export var margen_despawn := 300.0   # limpiar atrás de cámara

func _ready() -> void:
	randomize()
	if seguir_path != NodePath():
		seguir = get_node_or_null(seguir_path) as Node2D
	if seguir == null:
		seguir = get_viewport().get_camera_2d()
	# Si no cargaste nada en el array desde el Inspector, uso los preloads:
	if obstacle_scenes.is_empty():
		obstacle_scenes = [ROCK, ROCK_2]

func _process(delta: float) -> void:
	if seguir == null or obstacle_scenes.is_empty():
		return

	var vr := get_viewport().get_visible_rect()
	var left   := seguir.global_position.x - vr.size.x * 0.5
	var right  := seguir.global_position.x + vr.size.x * 0.5
	var top    := seguir.global_position.y - vr.size.y * 0.5
	var bottom := seguir.global_position.y + vr.size.y * 0.5

	# inicializar primer punto de spawn
	if next_spawn_x == -INF:
		next_spawn_x = right + randi_range(int(min_gap_px), int(max_gap_px))

	# ¿toca spawnear?
	if right + margen_spawn_x >= next_spawn_x:
		var scene: PackedScene = obstacle_scenes[randi() % obstacle_scenes.size()]
		_spawn(scene, Vector2(next_spawn_x, randf_range(top + margen_vertical, bottom - margen_vertical)))
		if randf() < prob_doble:
			_spawn(scene, Vector2(next_spawn_x + doble_sep_x, randf_range(top + margen_vertical, bottom - margen_vertical)))
		next_spawn_x = right + randi_range(int(min_gap_px), int(max_gap_px))

	# mover y limpiar
	if mover_obstaculos:
		for o in obstacles:
			if is_instance_valid(o):
				o.position.x -= velocidad * delta
	for i in range(obstacles.size() - 1, -1, -1):
		var o := obstacles[i]
		if not is_instance_valid(o):
			obstacles.remove_at(i)
		elif o.global_position.x < left - margen_despawn:
			o.queue_free()
			obstacles.remove_at(i)

func _spawn(scene: PackedScene, pos: Vector2) -> void:
	var inst := scene.instantiate() as Node2D
	add_child(inst)
	inst.global_position = pos
	inst.add_to_group("obstaculos")
	obstacles.append(inst)
