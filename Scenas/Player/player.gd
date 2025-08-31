extends CharacterBody2D

const SPEED = 150.0
var vida: int = 1
# Dash
var dash_speed: float = 300
var dash_duration: float = 0.5
var dash_cooldown: float = 1
var esta_Vivo: bool= true
var is_dashing: bool = false
var dash_time: float = 0
var dash_direction: Vector2 = Vector2.ZERO
var can_dash: bool = true

const TOP_Y := 37.0    # techo visible
const BOTTOM_Y := 235.0  # piso visible

@onready var linterna = $Pivot
func _ready() -> void:
	add_to_group("Player")
	sprite.animation_changed.connect(_on_animation_changed)
	sprite.animation_finished.connect(_on_animation_finished)
func _physics_process(delta: float) -> void:
	# Movimiento y dash
	if is_dashing:
		# Mientras dure el dash
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
		
		# Detectar input para dash
		if Input.is_action_just_pressed("dash")and $CanvasLayer/OxygenComponent.oxygen >= 30:
			start_dash(direction)

	move_and_slide()
	Decidir_Animaciones()

	# Limitar posición vertical
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
func Decidir_Animaciones():
	if velocity.x == 0 and esta_Vivo==true: 
		$Animaciones.play("Idle")
	elif velocity.x < 0 and esta_Vivo==true: 
		$Animaciones.flip_h = true	
		$Animaciones.play("Run")
	elif velocity.x > 0 and esta_Vivo==true: 
		$Animaciones.flip_h = false	
		$Animaciones.play("Run")
	if velocity.y < 0 and esta_Vivo==true:
		$Animaciones.play("Run")
	elif velocity.y > 0 and esta_Vivo==true: 
		$Animaciones.play("Run")
	elif is_dashing==true and esta_Vivo==true :
		$Animaciones.speed_scale=1
		$Animaciones.play("Dash")
	if esta_Vivo==false :
		$Animaciones.speed_scale=2
		$Animaciones.play("Muerte")

func RestarVida():
	esta_Vivo=false
	Decidir_Animaciones()
	print("murio")
	
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var direccion = (mouse_pos - global_position).angle()  # Ángulo hacia el mouse
	linterna.rotation = direccion
@onready var sprite: AnimatedSprite2D = $Animaciones

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
		sprite.scale = Vector2(1, 1) # valor por defecto

	pass # Replace with function body.
func _on_animation_finished():
	if sprite.animation== "Muerte":
		$"../Perder_ganar".show_game_over(false)
