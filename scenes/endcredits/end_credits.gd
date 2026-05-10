extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Auto scroll section
	#$ScrollContainer.scroll_vertical = 0
	#$ScrollContainer.show()
	#$ScrollContainer/Label.show()
	#
	#await get_tree().process_frame
	#await get_tree().process_frame
	#pass # Replace with function body.
	$AudioStreamPlayer.play()
	await get_tree().process_frame
	await get_tree().process_frame
	$ScrollContainer.scroll_vertical = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ScrollContainer.scroll_vertical += int(250 * delta)
		
	
