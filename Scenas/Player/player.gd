extends CharacterBody2D

# Velocidad vertical controlable por el jugador
@export var speed_vertical := 150.0
# Velocidad de avance automática hacia la derecha (la “del juego”)
@export var forward_speed := 220.0

var vida: int = 1
var esta_Vivo: bool = true

# Dash (impulso hacia adelante)
@export var dash_speed: float = 300.0
@export var dash_duration: float = 0.5
@export var dash_cooldown: float = 1.0
var is_dashing: bool = false
var dash_time: float = 0.0
var can_dash: bool = true

const TOP_Y := 37.0
const BOTTOM_Y := 235.0

# Hundimiento al morir
@export var sink_speed: float = 140.0      # velocidad hacia abajo al morir
@export var sink_fade_time: float = 1.2    # tiempo de desvanecido

# --- COLISIONES / DAÑO ---
@onready var hitbox: Area2D = $Hitbox
var invul_left := 0.0
@export var invul_time := 0.35
@export var dano_oxigeno := 12.0

@onready var linterna = $Pivot
@onready var sprite: AnimatedSprite2D = $Animaciones

func _ready() -> void:
	add_to_group("Player")
	sprite.animation_changed.connect(_on_animation_changed)
	sprite.animation_finished.connect(_on_animation_finished)

	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if invul_left > 0.0:
		invul_left -= delta

	# Si está muerto: no hay controles; hundirse y desvanecer
	if not esta_Vivo:
		velocity.x = 0.0
		velocity.y = sink_speed
		move_and_slide()
		return

	# --- AVANCE HORIZONTAL FORZADO ---
	var vx := forward_speed

	# --- CONTROL VERTICAL DEL JUGADOR ---
	var vy_input := Input.get_axis("ui_up", "ui_down")  # -1 arriba, +1 abajo
	var vy := vy_input * speed_vertical

	# --- DASH ---
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0.0:
			is_dashing = false
	else:
		if Input.is_action_just_pressed("dash") and $CanvasLayer/OxygenComponent.oxygen >= 30.0:
			start_dash(vy_input)

	# Impulso de dash
	if is_dashing:
		vx += dash_speed
		vy = vy_input * dash_speed

	# Aplicar velocidades
	velocity.x = vx
	velocity.y = vy if vy_input != 0 else move_toward(velocity.y, 0.0, speed_vertical)

	move_and_slide()
	Decidir_Animaciones()

	# Limitar Y SOLO en vida
	global_position.y = clamp(global_position.y, TOP_Y, BOTTOM_Y)
	if global_position.y <= TOP_Y and velocity.y < 0.0:
		velocity.y = 0.0
	if global_position.y >= BOTTOM_Y and velocity.y > 0.0:
		velocity.y = 0.0

func start_dash(vy_input: float):
	is_dashing = true
	dash_time = dash_duration
	$CanvasLayer/OxygenComponent.Use_Oxygen(5)
	can_dash = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

# ---------- COLISIÓN ----------
func _on_hitbox_area_entered(area: Area2D) -> void:
	_procesar_golpe_con(_find_obstacle_root(area))

func _on_hitbox_body_entered(body: Node) -> void:
	_procesar_golpe_con(_find_obstacle_root(body))

func _find_obstacle_root(n: Node) -> Node:
	var cur := n
	while cur and not cur.is_in_group("destructible_on_player_touch"):
		cur = cur.get_parent()
	return cur

func _procesar_golpe_con(o: Node) -> void:
	if o == null or not is_instance_valid(o):
		return
	if not o.is_in_group("destructible_on_player_touch"):
		return
	if invul_left > 0.0:
		return
	invul_left = invul_time

	_feedback_golpe()

	if has_node("CanvasLayer/OxygenComponent"):
		$CanvasLayer/OxygenComponent.Use_Oxygen(dano_oxigeno)

	_destruir_obstaculo(o, 0.18 if is_dashing else 0.25)

func _feedback_golpe() -> void:
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 0.5, 0.5, 1), 0.06)
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.14)
	velocity.y *= 0.6

func _destruir_obstaculo(o: Node, anim_time: float) -> void:
	for c in o.get_children():
		if c is Area2D:
			c.monitoring = false
			c.monitorable = false

	if o.has_node("Animaciones"):
		var a: AnimatedSprite2D = o.get_node("Animaciones")
		if "explode" in a.sprite_frames.get_animation_names():
			a.play("explode")
		await get_tree().create_timer(anim_time).timeout
	elif o.has_node("Particles2D"):
		o.get_node("Particles2D").emitting = true
		await get_tree().create_timer(anim_time).timeout

	if is_instance_valid(o):
		o.queue_free()
# ---------- FIN COLISIÓN ----------

func Decidir_Animaciones():
	# Si está muerto, no reproducimos ninguna animación
	if not esta_Vivo:
		return

	if is_dashing:
		$Animaciones.speed_scale = 1
		$Animaciones.flip_h = false
		$Animaciones.play("Dash")
		return

	$Animaciones.flip_h = false
	if abs(Input.get_axis("ui_up", "ui_down")) > 0.0:
		$Animaciones.play("Run")
	else:
		$Animaciones.play("Idle")

func RestarVida():
	if not esta_Vivo:
		return
	esta_Vivo = false
	is_dashing = false
	velocity = Vector2.ZERO

	# Detener animaciones y evitar nuevas colisiones
	if sprite: sprite.stop()
	if hitbox:
		hitbox.monitoring = false
		hitbox.set_deferred("monitorable", false)

	# Desvanecerse mientras se hunde (el hundimiento lo hace _physics_process)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate:a", 0.0, sink_fade_time)
	await tw.finished

	# Mostrar pantalla de fin
	if has_node("../Perder_ganar"):
		$"../Perder_ganar".show_game_over(false)

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var direccion = (mouse_pos - global_position).angle()
	linterna.rotation = direccion

var animation_scales := {
	"Idle": Vector2(1, 1),
	"Run": Vector2(1, 1),
	"Muerte": Vector2(0.35, 0.35), # ya no se usa, lo dejo por compatibilidad
	"Dash": Vector2(0.22, 0.22),
}

func _on_animation_changed():
	var current_anim = sprite.animation
	if animation_scales.has(current_anim):
		sprite.scale = animation_scales[current_anim]
	else:
		sprite.scale = Vector2(1, 1)

func _on_animation_finished():
	# Ya no dispararmos nada en "Muerte"; la lógica de muerte se maneja en RestarVida()
	pass
