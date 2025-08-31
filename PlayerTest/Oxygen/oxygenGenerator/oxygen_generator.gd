extends Node2D

@export var oxygen_item_scene: PackedScene
@export var player_path: NodePath
@export var spawn_area_size: Vector2 = Vector2(300, 200)
@export var spawn_offset: Vector2 = Vector2(300, 0)
@export var max_items: int = 5

var player: Node2D


func _ready():
	player = get_node(player_path)
	randomize()

func _process(_delta):
	if not player:
		return

	# Mover el generador delante del jugador
	global_position = player.global_position + spawn_offset

func try_spawn_item() -> void:
	var attempts = 0
	var max_attempts = 10

	while attempts < max_attempts:
		attempts += 1
		var item = oxygen_item_scene.instantiate()
		print("intento de objeto")
		# Posición aleatoria relativa al generador
		var offset = Vector2(
			randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
			randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
		)
		item.global_position = position + offset

		get_tree().get_current_scene().add_child(item)
		await get_tree().process_frame

		# Comprobar colisiones
		if item is Area2D and item.get_overlapping_bodies().is_empty():
			print(item.position)
			print("exito")
			return  # Éxito
		else:
			item.queue_free()  # Falló, reintentar
			print("fracaso")


func _on_timer_timeout() -> void:
	print("iniciar intento")
	try_spawn_item()
