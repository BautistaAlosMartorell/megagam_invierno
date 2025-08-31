extends Node2D

# ---- A QUIÉN SEGUIR (Camera2D o Player) ----
@export_node_path("Node2D") var seguir_path: NodePath
var seguir: Node2D

# ---- Límites verticales visibles ----
const TOP_Y := -5.0        # techo visible
const BOTTOM_Y := 235.0    # piso visible

# ---- Escenas de obstáculos ----
@export var obstacle_scenes: Array[PackedScene] = []
const MINA     = preload("res://Scenas/mina.tscn")
const MINA_TOP = preload("res://Scenas/mina_top.tscn")

# ---- Estado interno ----
var obstacles: Array[Node2D] = []
var next_spawn_x: float = -INF

# ---- Tuning ----
@export var min_gap_px := 320.0
@export var max_gap_px := 520.0
@export var prob_doble := 0.18
@export var doble_sep_x := 140.0
@export var margen_vertical := 24.0
@export var margen_spawn_x := 40.0
@export var mover_obstaculos := true
@export var velocidad := 300.0
@export var margen_despawn := 300.0

func _ready() -> void:
	randomize()
	if seguir_path != NodePath():
		seguir = get_node_or_null(seguir_path) as Node2D
	if seguir == null:
		seguir = get_viewport().get_camera_2d()
	if obstacle_scenes.is_empty():
		obstacle_scenes = [MINA, MINA_TOP]

func _process(delta: float) -> void:
	if seguir == null or obstacle_scenes.is_empty():
		return

	var vr := get_viewport().get_visible_rect()
	var left   := seguir.global_position.x - vr.size.x * 0.5
	var right  := seguir.global_position.x + vr.size.x * 0.5
	var top    := seguir.global_position.y - vr.size.y * 0.5
	var bottom := seguir.global_position.y + vr.size.y * 0.5

	if next_spawn_x == -INF:
		next_spawn_x = right + randi_range(int(min_gap_px), int(max_gap_px))

	if right + margen_spawn_x >= next_spawn_x:
		var scene: PackedScene = obstacle_scenes[randi() % obstacle_scenes.size()]
		_spawn(scene, Vector2(next_spawn_x, _pick_y_for_scene(scene, top, bottom)))
		if randf() < prob_doble:
			_spawn(scene, Vector2(next_spawn_x + doble_sep_x, _pick_y_for_scene(scene, top, bottom)))
		next_spawn_x = right + randi_range(int(min_gap_px), int(max_gap_px))

	# mover (excepto MINA y MINA_TOP) y limpiar
	if mover_obstaculos:
		for o in obstacles:
			if is_instance_valid(o):
				if o.scene_file_path == MINA.resource_path or o.scene_file_path == MINA_TOP.resource_path:
					continue
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
	# Marcar como destruible y etiquetar tipo
	inst.add_to_group("destructible_on_player_touch")
	if scene == MINA:
		inst.add_to_group("mina_floor")
	elif scene == MINA_TOP:
		inst.add_to_group("mina_top")
	obstacles.append(inst)

func _pick_y_for_scene(scene: PackedScene, top: float, bottom: float) -> float:
	if scene == MINA:
		return BOTTOM_Y          # pegada al piso
	elif scene == MINA_TOP:
		return TOP_Y             # pegada al techo
	else:
		return randf_range(top + margen_vertical, bottom - margen_vertical)
