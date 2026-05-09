extends Node2D

@onready var bunny = $Bunny
@onready var eyenstyne = $Eyenstyne
@onready var title = $TitleCard/Title
@onready var flash = $Flash

var bunny_stand = preload("res://assets/sprites/bunny/stand.png")

func _ready():
	var screen = get_viewport_rect().size       # gets actual screen size automatically
	
	# starting states
	eyenstyne.position.y = -screen.y 
	eyenstyne.play("default")           # eye starts fully above screen
	title.modulate.a = 0                        # title invisible
	flash.modulate.a = 0                        # flash invisible

	# size flash to cover full screen
	$Flash.size = screen
	$Flash.position = Vector2.ZERO

	await get_tree().create_timer(0.5).timeout  # short pause before it begins

	await eyenstyne_descend()
	await get_tree().create_timer(1.5).timeout 
	$sit2stand.play()   # eye comes down
	await flash_and_swap()      # flash + bunny transforms

	await get_tree().create_timer(1.5).timeout  # title stays on screen for 2 seconds
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")


# eye moves down to center of screen
func eyenstyne_descend():
	$aiDesends.play()
	var tween = create_tween()
	tween.tween_property(eyenstyne, "position:y", 400, 2.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished


# screen flashes white, bunny swaps sprite at peak of flash so its hidden
func flash_and_swap():
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 0.5)                          # flash in
	tween.tween_callback(func(): bunny.texture = bunny_stand)                    # swap sprite while white
	tween.tween_property(flash, "modulate:a", 0.0, 0.5)                          # flash out
	await tween.finished
