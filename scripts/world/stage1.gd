# stage_1.gd
extends Node2D

@onready var bunbun = $BunBun
@onready var carrot = $Carrot
@onready var chain = $Carrot/Chain
@onready var eyenstein_helper = $EyensteinHelper
@onready var health_bar = $HUD/HealthBar
@onready var puzzle_overlay = $PuzzleOverlay

var is_moving: bool = false
var target_position: Vector2 = Vector2.ZERO
var move_speed: float = 100.0
var puzzle_open: bool = false
var heading_to_carrot: bool = false

# change these to match your exact animation names in SpriteFrames
const ANIM_IDLE = "idle"
const ANIM_WALK = "walk"


func _ready():
	# health
	GameManager.health = 25
	health_bar.value = GameManager.health
	health_bar.max_value = 100

	# bunny starts idle
	bunbun.play(ANIM_IDLE)

	# carrot visible, puzzle hidden
	carrot.visible = true
	chain.visible = true
	puzzle_overlay.visible = false

	# eyenstein flies in from off screen bottom left
	var screen = get_viewport().size
	eyenstein_helper.position = Vector2(-100, screen.y + 100)   # starts off screen
	var tween = create_tween()
	tween.tween_property(eyenstein_helper, "position", Vector2(80, screen.y - 80), 1.5)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# connect signals
	GameManager.answer_given_correct.connect(_on_correct_answer)
	GameManager.answer_given_wrong.connect(_on_wrong_answer)


func _input(event):
	if puzzle_open:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_pos = get_global_mouse_position()

		if clicked_pos.distance_to(carrot.position) < 40:
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
	_move_bunny_to(carrot.position)


func _process(delta):
	if is_moving:
		var direction = target_position - bunbun.position
		if direction.length() > 5:
			bunbun.position += direction.normalized() * move_speed * delta

			if heading_to_carrot and bunbun.position.distance_to(carrot.position) < 30:
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
	if puzzle_open:
		return
	puzzle_open = true
	puzzle_overlay.visible = true


func _on_correct_answer():
	puzzle_open = false
	puzzle_overlay.visible = false
	chain.visible = false
	health_bar.value = GameManager.health
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/world/stage_2.tscn")


func _on_wrong_answer():
	health_bar.value = GameManager.health
	eyenstein_helper.update_sprite(GameManager.irritation_level)

	if GameManager.irritation_level == 2:
		var warning = preload("res://scenes/ui/warning_screen.tscn").instantiate()
		add_child(warning)

	if GameManager.irritation_level >= 3:
		get_tree().change_scene_to_file("res://scenes/bossfight/boss_fight.tscn")
