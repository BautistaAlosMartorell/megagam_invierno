extends CharacterBody2D

const SPEED = 150.0
var vida: int = 1
var esta_Vivo: bool = true

# Dash
var dash_speed: float = 300
var dash_duration: float = 0.5
var dash_cooldown: float = 1
var is_dashing: bool = false
var dash_time: float = 0
var dash_direction: Vector2 = Vector2.ZERO
var can_dash: bool = true

const TOP_Y := 37.0
const BOTTOM_Y := 235.0

# --- NUEVO ---
@onready var hitbox: Area2D = $Hitbox
var invul_left := 0.0  # i-frames cortos tras golpear
@export var invul_time := 0.35
@export var dano_oxigeno := 12.0

@onready var linterna = $Pivot
@onready var sprite: AnimatedSprite2D = $Animaciones

func _ready() -> void:
	add_to_group("Player")
	sprite.animation_changed.connect(_on_animation_changed)
	sprite.animation_finished.connect(_on_animation_finished)

	# Conectar colisiones del hitbox
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if invul_left > 0.0:
		invul_left -= delta

	# Movimiento y dash
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
	else:
		var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
		if direction != Vector2.ZERO:
			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)

		if Input.is_action_just_pressed("dash") and $CanvasLayer/OxygenComponent.oxygen >= 30:
			start_dash(direction)

	move_and_slide()
	Decidir_Animaciones()

	# Limitar Y
	global_position.y = clamp(global_position.y, TOP_Y, BOTTOM_Y)
	if global_position.y <= TOP_Y and velocity.y < 0.0:
		velocity.y = 0.0
	if global_position.y >= BOTTOM_Y and velocity.y > 0.0:
		velocity.y = 0.0

func start_dash(input_dir: Vector2):
	is_dashing = true
	dash_time = dash_duration
	velocity = input_dir.normalized() * dash_speed
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

	if is_dashing:
		_destruir_obstaculo(o, 0.18)
	else:
		_destruir_obstaculo(o, 0.25)

func _feedback_golpe() -> void:
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 0.5, 0.5, 1), 0.06)
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.14)
	velocity *= 0.6

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
	if velocity.x == 0 and esta_Vivo: 
		$Animaciones.play("Idle")
	elif velocity.x < 0 and esta_Vivo: 
		$Animaciones.flip_h = true	
		$Animaciones.play("Run")
	elif velocity.x > 0 and esta_Vivo: 
		$Animaciones.flip_h = false	
		$Animaciones.play("Run")
	if velocity.y < 0 and esta_Vivo:
		$Animaciones.play("Run")
	elif velocity.y > 0 and esta_Vivo: 
		$Animaciones.play("Run")
	elif is_dashing and esta_Vivo:
		$Animaciones.speed_scale = 1
		$Animaciones.play("Dash")
	if not esta_Vivo:
		$Animaciones.speed_scale = 2
		$Animaciones.play("Muerte")

func RestarVida():
	esta_Vivo = false
	Decidir_Animaciones()
	print("murio")

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var direccion = (mouse_pos - global_position).angle()
	linterna.rotation = direccion

var animation_scales := {
	"Idle": Vector2(1, 1),
	"Run": Vector2(1, 1),
	"Muerte": Vector2(0.35, 0.35),
	"Dash": Vector2(0.22, 0.22),
}

func _on_animation_changed():
	var current_anim = sprite.animation
	if animation_scales.has(current_anim):
		sprite.scale = animation_scales[current_anim]
	else:
		sprite.scale = Vector2(1, 1)

func _on_animation_finished():
	if sprite.animation == "Muerte":
		$"../Perder_ganar".show_game_over(false)
