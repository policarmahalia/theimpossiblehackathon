extends Node2D

@onready var bunbun = $BunBun
@onready var carrot = $Carrot
@onready var carrot_sprite = $Carrot/Sprite2D
@onready var chain = $Carrot/Chain
@onready var eyenstein_helper = $EyensteinHelper
@onready var puzzle_overlay = $PuzzleOverlay
@onready var notif = $notif

var is_moving: bool = false
var target_position: Vector2 = Vector2.ZERO
var move_speed: float = 100.0
var puzzle_open: bool = false
var heading_to_carrot: bool = false
var carrot_unlocked: bool = false

const ANIM_IDLE = "idle"
const ANIM_WALK = "walk"


func _ready():
	GameManager.play_music("res://audio/music/menu_and_stage.mp3")
	bunbun.play(ANIM_IDLE)
	notif.visible = false
	carrot.visible = true
	chain.visible = true
	puzzle_overlay.visible = false
	eyenstein_helper.chat_opened.connect(_on_chat_opened)
	eyenstein_helper.chat_closed.connect(_on_chat_closed)

	# listen for puzzle completed signal
	puzzle_overlay.puzzle_completed.connect(_on_puzzle_completed)

	# eyenstein flies in from off screen
	var screen = get_viewport().size
	eyenstein_helper.position = Vector2(-screen.x + 500, screen.y - 500)
	var tween = create_tween()
	tween.tween_property(eyenstein_helper, "position", Vector2(screen.x - 700, screen.y - 100), 1.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(3.0).timeout
	notif.visible = true


func _input(event):
	if puzzle_open or eyenstein_helper.chat_panel.visible:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_pos = get_global_mouse_position()

		if carrot_unlocked and clicked_pos.distance_to(carrot_sprite.global_position) < 80:
			print("going to stage 2")
			get_tree().change_scene_to_file("res://scenes/world/stage_2.tscn")  # ← indented inside if
			return

		if not carrot_unlocked and clicked_pos.distance_to(carrot_sprite.global_position) < 80:
			_walk_to_carrot()
			return

		heading_to_carrot = false
		_move_bunny_to(clicked_pos)


func _move_bunny_to(pos: Vector2):
	target_position = pos
	is_moving = true
	bunbun.flip_h = pos.x < bunbun.position.x
	bunbun.play(ANIM_WALK)


func _walk_to_carrot():
	heading_to_carrot = true
	_move_bunny_to(carrot_sprite.global_position)


func _process(delta):
	if is_moving:
		var direction = target_position - bunbun.position
		if direction.length() > 5:
			bunbun.position += direction.normalized() * move_speed * delta

			# check if bunny reached carrot while walking to it
			if heading_to_carrot and bunbun.position.distance_to(carrot_sprite.global_position) < 60:
				is_moving = false
				bunbun.play(ANIM_IDLE)
				_open_puzzle()
		else:
			bunbun.position = target_position
			is_moving = false
			bunbun.play(ANIM_IDLE)

			if heading_to_carrot:
				heading_to_carrot = false
				_open_puzzle()


func _open_puzzle():
	if puzzle_open or carrot_unlocked:
		return
	puzzle_open = true
	puzzle_overlay.visible = true


func _on_puzzle_completed():
	puzzle_open = false
	puzzle_overlay.visible = false
	carrot_unlocked = true
	chain.visible = false
	notif.text = "click the carrot!"
	notif.visible = true


func _on_chat_opened():
	# hide puzzle when chat opens
	puzzle_overlay.visible = false


func _on_chat_closed():
	# only show puzzle again if it's supposed to be open
	if puzzle_open:
		puzzle_overlay.visible = true
