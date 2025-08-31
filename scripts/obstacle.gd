extends Area2D
@export var vanish_delay := 0.12

func _ready() -> void:
	monitoring = true
	add_to_group("obstaculos")

func consume() -> void:
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	monitoring = false
	if has_node("Sprite2D"): $Sprite2D.visible = false
	await get_tree().create_timer(vanish_delay).timeout
	queue_free()
