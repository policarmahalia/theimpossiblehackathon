extends CanvasLayer


@onready var angry = $Angry

func bounce_animation():
	var screen = get_viewport().size
	
	# start position: top right corner, normal size
	angry.position = Vector2(screen.x, 0)
	angry.scale = Vector2(1.0, 1.0)
	
	var tween = create_tween()
	
	# fly in to center and get big
	tween.tween_property(angry, "position", Vector2(screen.x / 1.4, screen.y / 2), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(angry, "scale", Vector2(3.0, 3.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# stay big for 1 second
	tween.tween_interval(0.4)
	
	# fly back to top right corner and shrink
	tween.tween_property(angry, "position", Vector2(1600, 200), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(angry, "scale", Vector2(1.8, 1.8), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
func _ready():
	angry.play("default")
	bounce_animation()
	# auto dismiss after 5 seconds
	await get_tree().create_timer(5.0).timeout
	queue_free()
