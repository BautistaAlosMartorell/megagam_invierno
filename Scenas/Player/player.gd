extends CharacterBody2D

const SPEED := 150.0
const TOP_Y := 37.0
const BOTTOM_Y := 235.0

@export var obstacle_oxygen_penalty := 12.0
@export var slow_factor := 1.0
@export var slow_time   := 0.45
var _slow_left := 0.0

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
