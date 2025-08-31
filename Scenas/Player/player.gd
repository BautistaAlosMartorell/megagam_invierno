extends CharacterBody2D

const SPEED = 150.0
var vida: int = 1

# Dash
var dash_speed: float = 300
var dash_duration: float = 0.5
var dash_cooldown: float = 1
var esta_Vivo: bool = true
var is_dashing: bool = false
var dash_time: float = 0
var dash_direction: Vector2 = Vector2.ZERO
var can_dash: bool = true

# Límites
const TOP_Y := 37.0
const BOTTOM_Y := 235.0

# Slow / feedback
@export var slow_factor := 0.35
@export var slow_time := 0.45
@export var hit_stop_time := 0.10
var _slow_left := 0.0
var _hit_stop_left := 0.0

# Oxígeno por golpe
@export var oxygen_hit_cost := 12.0
@export var hit_cooldown := 0.25
var _hit_cooldown_left := 0.0

@onready var linterna = $Pivot
@onready var sprite: AnimatedSprite2D = $Animaciones
@onready var hitbox: Area2D = $Hitbox
@onready var oxygen_manager = $CanvasLayer/OxygenComponent

func _ready() -> void:
	add_to_group("Player")
	sprite.animation_changed.connect(_on_animation_changed)
	sprite.animation_finished.connect(_on_animation_finished)

	# señales del hitbox
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	# timers de feedback
	if _hit_stop_left > 0.0:
		_hit_stop_left -= delta
		move_and_slide()
		Decidir_Animaciones()
		_clamp_vertical()
		return
	if _hit_cooldown_left > 0.0:
		_hit_cooldown_left -= delta

	# Movimiento y dash
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
	else:
		var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

		var speed := SPEED
		if _slow_left > 0.0:
			_slow_left -= delta
			speed *= slow_factor

		if direction != Vector2.ZERO:
			velocity.x = direction.x * speed
			velocity.y = direction.y * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)

		# Dash consume oxígeno
		if Input.is_action_just_pressed("dash") and oxygen_manager.oxygen >= 30 and can_dash:
			start_dash(direction)

	move_and_slide()
	Decidir_Animaciones()
	_clamp_vertical()

func _clamp_vertical() -> void:
	global_position.y = clamp(global_position.y, TOP_Y, BOTTOM_Y)
	if global_position.y <= TOP_Y and velocity.y < 0.0:
		velocity.y = 0.0
	if global_position.y >= BOTTOM_Y and velocity.y > 0.0:
		velocity.y = 0.0

func start_dash(input_dir: Vector2) -> void:
	is_dashing = true
	dash_time = dash_duration
	velocity = input_dir.normalized() * dash_speed
	oxygen_manager.Use_Oxygen(5)
	can_dash = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

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
		queue_free()

# --- COLISIÓN CON OBSTÁCULOS (destruir + ralentizar + consumir oxígeno) ---

func _on_hitbox_area_entered(area: Area2D) -> void:
	_handle_obstacle_hit(area)

func _on_hitbox_body_entered(body: Node) -> void:
	_handle_obstacle_hit(body)

func _handle_obstacle_hit(n: Node) -> void:
	# i-frames para evitar múltiples golpes simultáneos
	if _hit_cooldown_left > 0.0:
		return

	if n.is_in_group("destructible_on_player_touch") or n.is_in_group("mina_floor") or n.is_in_group("mina_top"):
		# Feedback: hit-stop + tintado + slow
		_apply_hit_feedback()
		_slow_left = max(_slow_left, slow_time)
		_hit_cooldown_left = hit_cooldown

		# Consumir oxígeno
		if oxygen_manager:
			oxygen_manager.Use_Oxygen(oxygen_hit_cost)

		# Destruir obstáculo (n o su owner)
		var root := n.get_owner()
		if root == null:
			root = n
		if is_instance_valid(root):
			root.queue_free()

func _apply_hit_feedback() -> void:
	_hit_stop_left = hit_stop_time
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 0.6, 0.6), 0.05)
	t.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)
