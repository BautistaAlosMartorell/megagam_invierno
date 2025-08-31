extends CharacterBody2D


const SPEED := 150.0
const TOP_Y := 37.0
const BOTTOM_Y := 235.0

@export var obstacle_oxygen_penalty := 12.0
@export var slow_factor := 1.0
@export var slow_time   := 0.45
var _slow_left := 0.0

var vida: int = 1
# Dash
var dash_speed: float = 300
var dash_duration: float = 0.1
var dash_cooldown: float = 1

var is_dashing: bool = false
var dash_time: float = 0
var dash_direction: Vector2 = Vector2.ZERO
var can_dash: bool = true


@onready var hitbox: Area2D     = $Hitbox
@onready var anim               = $Animaciones
@onready var flashlight: Node2D = $Node2D
@onready var oxygen_manager     = $"CanvasLayer/OxygenComponent" 


func _ready() -> void:
	if not hitbox.area_entered.is_connected(_on_hitbox_area_entered):
		hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(dt: float) -> void:
	if _slow_left > 0.0:
		_slow_left = max(0.0, _slow_left - dt)

	var speed_now: float = SPEED
	if _slow_left > 0.0:
		speed_now *= slow_factor

	var dir := Input.get_vector("ui_left","ui_right","ui_up","ui_down").normalized()
	if dir != Vector2.ZERO:
		velocity.x = dir.x * speed_now
		velocity.y = dir.y * speed_now
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

	# límites en Y
	global_position.y = clamp(global_position.y, TOP_Y, BOTTOM_Y)
	if global_position.y <= TOP_Y and velocity.y < 0.0: velocity.y = 0.0
	if global_position.y >= BOTTOM_Y and velocity.y > 0.0: velocity.y = 0.0

	Decidir_Animaciones()

func _process(_dt: float) -> void:
	flashlight.rotation = (get_global_mouse_position() - global_position).angle()

# ---- Colisión con obstáculo ----
func _on_hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("obstaculos"):
		return

	_flash()
	velocity *= 0.25      
	_slow_left = slow_time

	if oxygen_manager and oxygen_manager.has_method("Use_Oxygen"):
		oxygen_manager.Use_Oxygen(obstacle_oxygen_penalty)
	else:
		print("OxygenComponent no encontrado o sin Use_Oxygen")


	if area.has_method("consume"):
		area.consume()
	else:
		area.queue_free()

func _flash() -> void:
	if anim is CanvasItem:
		anim.modulate = Color(1, 0.5, 0.5)
		var t := get_tree().create_timer(0.12)
		t.timeout.connect(func(): anim.modulate = Color(1,1,1))

func Decidir_Animaciones() -> void:
	if velocity.x == 0:
		anim.play("Idle")
	elif velocity.x < 0:
		anim.flip_h = true;  anim.play("Run")
	else:
		anim.flip_h = false; anim.play("Run")

	if velocity.y < 0:
		anim.flip_v = true;  anim.play("Run")
	elif velocity.y > 0:
		anim.flip_v = false; anim.play("Run")
=======
@onready var linterna = $Node2D

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
	if velocity.x == 0: 
		$Animaciones.play("Idle")
	elif velocity.x < 0: 
		$Animaciones.flip_h = true	
		$Animaciones.play("Run")
	elif velocity.x > 0: 
		$Animaciones.flip_h = false	
		$Animaciones.play("Run")
	
	if velocity.y < 0:
		$Animaciones.flip_v = true	
		$Animaciones.play("Run")
	elif velocity.y > 0: 
		$Animaciones.flip_v = false	
		$Animaciones.play("Run")

func RestarVida(damage: int):
	if vida == 1:
		vida -= damage
	if vida == 0:
		queue_free()

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var direccion = (mouse_pos - global_position).angle()  # Ángulo hacia el mouse
	linterna.rotation = direccion

