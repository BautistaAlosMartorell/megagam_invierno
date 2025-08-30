extends ParallaxLayer

var speed = -100


func _process(delta):
	get_parent().scroll_offset.x += speed*delta
