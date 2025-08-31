extends Node

# ---------------- CONFIG JUEGO ----------------
@export var score_por_px: float = 0.05

@export var forward_speed_base: float = 220.0
@export var dificultad_periodo: float = 10.0
@export var forward_speed_incremento: float = 20.0

@export var spawner_vel_inc: float = 20.0
@export var spawner_min_gap_step: float = -14.0
@export var spawner_max_gap_step: float = -18.0
@export var spawner_min_gap_min: float = 200.0

# ---------------- CONFIG KRAKEN ----------------
@export var kraken_speed_base: float = 140.0     # velocidad mínima del Kraken
@export var kraken_speed_scale: float = 0.90     # cuánto sube el Kraken por cada 1 de forward_speed extra
@export var kraken_speed_max: float = 900.0      # techo de seguridad

# ---------------- HUD ----------------
@onready var score_label: Label = $HUID/score_label
@onready var high_label: Label  = $HUID/high_label

# ---------------- NODOS ----------------
var player: Node = null
var spawner: Node = null
var kraken: Node  = null

# ---------------- ESTADO ----------------
var start_x: float = 0.0
var score: float = 0.0
var high_score: int = 0
var tiempo: float = 0.0
var nivel: int = 1
var _high_guardado: bool = false

const SAVE_PATH := "user://save.cfg"
const SAVE_SECTION := "stats"
const SAVE_KEY := "high_score"

func _ready() -> void:
	player  = get_node_or_null("Player")
	spawner = get_node_or_null("ObstacleSpawner")
	kraken  = get_node_or_null("Kraken")

	high_score = _load_high_score()

	# Velocidad inicial del player
	if player and "forward_speed" in player:
		player.forward_speed = forward_speed_base

	# Posición inicial para score
	var p2d := player as Node2D
	start_x = p2d.global_position.x if p2d else 0.0

	# Velocidad inicial del spawner
	if spawner and "velocidad" in spawner:
		spawner.velocidad = 300.0

	# Velocidad inicial del Kraken
	_sync_kraken_speed()

	_actualizar_labels()

func _process(delta: float) -> void:
	if not player:
		return
	var p2d := player as Node2D
	if not p2d:
		return

	# Score por distancia
	var px: float = p2d.global_position.x - start_x
	var distancia: float = maxf(0.0, px)
	score = int(distancia * score_por_px)

	# High Score live
	if score > high_score:
		high_score = score

	# Dificultad por tiempo
	tiempo += delta
	if tiempo >= dificultad_periodo * nivel:
		_subir_dificultad()

	# Si murió, guardamos HS
	if "esta_Vivo" in player and not player.esta_Vivo and not _high_guardado:
		_save_high_score(high_score)
		_high_guardado = true

	# Por si cambiás forward_speed en otro lado, mantenemos Kraken sincronizado cada frame
	_sync_kraken_speed()

	_actualizar_labels()

func _subir_dificultad() -> void:
	nivel += 1

	# Acelerar player
	if player and "forward_speed" in player:
		player.forward_speed += forward_speed_incremento

	# Acelerar/ajustar spawner
	if spawner:
		if "velocidad" in spawner:
			spawner.velocidad += spawner_vel_inc
		if "min_gap_px" in spawner:
			spawner.min_gap_px = maxf(spawner_min_gap_min, spawner.min_gap_px + spawner_min_gap_step)
		if "max_gap_px" in spawner:
			var piso: float = spawner.min_gap_px if "min_gap_px" in spawner else spawner_min_gap_min
			spawner.max_gap_px = maxf(piso, spawner.max_gap_px + spawner_max_gap_step)

	# Kraken también sube su velocidad
	_sync_kraken_speed()

func _sync_kraken_speed() -> void:
	if not kraken:
		return
	if "speed" in kraken:
		var fwd: float
		if player and "forward_speed" in player:
			fwd = float(player.forward_speed)
		else:
			fwd = forward_speed_base

		var extra: float = maxf(0.0, fwd - forward_speed_base)
		var target_speed: float = kraken_speed_base + extra * kraken_speed_scale
		kraken.speed = clampf(target_speed, kraken_speed_base, kraken_speed_max)


func _actualizar_labels() -> void:
	score_label.text = "SCORE: %d" % int(score)
	high_label.text  = "HI: %d" % int(high_score)

# ---------------- GUARDADO ----------------
func _load_high_score() -> int:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK and cfg.has_section_key(SAVE_SECTION, SAVE_KEY):
		return int(cfg.get_value(SAVE_SECTION, SAVE_KEY, 0))
	return 0

func _save_high_score(value: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value(SAVE_SECTION, SAVE_KEY, int(value))
	cfg.save(SAVE_PATH)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_save_high_score(high_score)
