extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const TOP_Y := 37.0    # techo visible
const BOTTOM_Y := 235.0  # piso visible


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	if direction != Vector2.ZERO:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	Decidir_Animaciones()
	global_position.y = clamp(global_position.y, TOP_Y, BOTTOM_Y)
	if global_position.y <= TOP_Y and velocity.y < 0.0:
		velocity.y = 0.0
	if global_position.y >= BOTTOM_Y and velocity.y > 0.0:
		velocity.y = 0.0

func Decidir_Animaciones():
	if velocity.x == 0: 
		$Animaciones.play("Idle")
		pass
	elif velocity.x < 0: 
		$Animaciones.flip_h=true	
		$Animaciones.play("Run")
		pass
	elif velocity.x > 0: 
		$Animaciones.flip_h=false	
		$Animaciones.play("Run")
		pass
	if velocity.y < 0:
		$Animaciones.flip_v=true	
		$Animaciones.play("Run")
		pass
	elif velocity. y > 0: 
		$Animaciones.flip_v=false	
		$Animaciones.play("Run")
		pass
