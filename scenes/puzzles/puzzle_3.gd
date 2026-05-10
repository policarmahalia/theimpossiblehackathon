extends CanvasLayer

signal puzzle_completed

var lives = 4
var anger_animations = ["default", "angry1", "angry2", "angry3"]
var chat_open: bool = false

var questions = [
	{
		"question": "What gets wetter the more it dries?",
		"answers": ["A sponge", "A towel", "A fish", "Sand"],
		"correct": 1
	},
	{
		"question": "I have hands but cannot clap. What am I?",
		"answers": ["A statue", "A clock", "A glove", "A robot"],
		"correct": 1
	},
	{
		"question": "What comes once in a minute, twice in a moment, never in a thousand years?",
		"answers": ["Time", "Luck", "The letter M", "A second"],
		"correct": 2
	},
	{
		"question": "The more you take, the more you leave behind. What am I?",
		"answers": ["Money", "Time", "Footsteps", "Memories"],
		"correct": 2
	},
]

var current_question = 0

@onready var eyestein = $Eyenstein
@onready var buzzer = $Buzzer
@onready var meme_flash = $MemeFlash
@onready var countdown_timer = $CountdownTimer

var eyenstein_helper = null


func _ready():
	$AnswerA.pressed.connect(_on_answer.bind(0))
	$AnswerB.pressed.connect(_on_answer.bind(1))
	$AnswerC.pressed.connect(_on_answer.bind(2))
	$AnswerD.pressed.connect(_on_answer.bind(3))

	countdown_timer.timeout.connect(_on_time_up)

	eyestein.play("default")
	meme_flash.visible = false

	load_question()

	eyenstein_helper = get_parent().get_node_or_null("EyensteinHelper")
	if eyenstein_helper:
		eyenstein_helper.chat_opened.connect(_on_chat_opened)
		eyenstein_helper.chat_closed.connect(_on_chat_closed)


# ========================
# CHAT HANDLING
# ========================

func _on_chat_opened():
	chat_open = true
	visible = false   
	countdown_timer.stop()


func _on_chat_closed():
	chat_open = false
	visible = true
	countdown_timer.start()


# ========================
# INPUT (CLICK EYENSTEIN)
# ========================

func _input(event):
	if chat_open:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse = get_viewport().get_mouse_position()

		if mouse.distance_to(eyestein.position) < 80:
			if eyenstein_helper:
				eyenstein_helper._open_chat()


# ========================
# PUZZLE LOGIC
# ========================

func load_question():
	var q = questions[current_question]
	$QuestionLabel.text = q["question"]
	$AnswerA.text = q["answers"][0]
	$AnswerB.text = q["answers"][1]
	$AnswerC.text = q["answers"][2]
	$AnswerD.text = q["answers"][3]


func _on_answer(index: int):
	if chat_open:
		return

	var q = questions[current_question]

	if index == q["correct"]:
		_on_correct()
	else:
		_lose_life()


func _on_time_up():
	if not chat_open:
		_lose_life()


func _lose_life():
	lives -= 1

	if lives <= 0:
		_on_final_loss()
		return

	buzzer.play()
	eyestein.play(anger_animations[4 - lives])
	countdown_timer.start()

	if lives == 2:
		var warning = preload("res://scenes/ui/warning_screen.tscn").instantiate()
		get_parent().add_child(warning)


func _on_correct():
	current_question += 1

	if current_question >= questions.size():
		emit_signal("puzzle_completed")
		visible = false
	else:
		load_question()


# ========================
# LOSS / EFFECTS
# ========================

func _on_final_loss():
	_disable_buttons()
	countdown_timer.stop()
	eyestein.play("angry3")

	var vine = AudioStreamPlayer.new()
	vine.stream = load("res://audio/sfx/vine_boom.mp3")
	add_child(vine)
	vine.play()

	_flash_meme()


func _flash_meme():
	meme_flash.visible = true

	var tween = create_tween()
	tween.tween_property(meme_flash, "modulate:a", 0.4, 0.1)
	tween.tween_interval(0.4)
	tween.tween_property(meme_flash, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func():
		meme_flash.visible = false
		get_tree().change_scene_to_file("res://scenes/gamescreens/monolog.tscn")
	)


func _disable_buttons():
	$AnswerA.disabled = true
	$AnswerB.disabled = true
	$AnswerC.disabled = true
	$AnswerD.disabled = true
