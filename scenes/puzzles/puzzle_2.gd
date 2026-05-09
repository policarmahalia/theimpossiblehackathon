extends CanvasLayer

signal puzzle_completed

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

#extends CanvasLayer

var correct_answer = 2  # C is correct (0=A, 1=B, 2=C, 3=D)
var lives = 4
var anger_animations = ["default", "angry1", "angry2", "angry3"]

var questions = [
	{
		"question": "What can you add to a bucket to make it lighter?",
		"answers": ["A carrot", "A torch", "A hole", "A lighter"],
		"correct": 1
	},
	{
		"question": "Which of the following do you need to build a green house?",
		"answers": ["Glass", "The colour green", "Paint", "Bricks"],
		"correct": 2
	},
	{
		"question": "Which of the following is the largest?",
		"answers": ["Earth", "Mars", "Galaxy", "Milky Way"],
		"correct": 0
	},
	{
		"question": "Press the right arrow",
		"answers": ["the right arrow", "right arrow", "arrow", "←"],
		"correct": 3
	},
]
var current_question = 0

@onready var eyestein = $Eyenstein
@onready var buzzer = $Buzzer
@onready var flash_timer = $FlashTimer
@onready var meme_flash = $MemeFlash
@onready var countdown_timer = $CountdownTimer

func _ready():
	$AnswerA.pressed.connect(_on_answer.bind(0))
	$AnswerB.pressed.connect(_on_answer.bind(1))
	$AnswerC.pressed.connect(_on_answer.bind(2))
	$AnswerD.pressed.connect(_on_answer.bind(3))
	countdown_timer.timeout.connect(_on_time_up)
	eyestein.play("default")
	meme_flash.visible = false
	load_question()

func load_question():
	var q = questions[current_question]
	$QuestionLabel.text = q["question"]
	$AnswerA.text = q["answers"][0]
	$AnswerB.text = q["answers"][1]
	$AnswerC.text = q["answers"][2]
	$AnswerD.text = q["answers"][3]
	
func _on_answer(index: int):
	var q = questions[current_question]
	if index == q["correct"]:
		_on_correct()
	else:
		_lose_life()

func _on_time_up():
	_lose_life()

func _lose_life():
	lives -= 1

	if lives <= 0:
		_on_final_loss()
		return

	buzzer.play()
	eyestein.play(anger_animations[4 - lives])
	countdown_timer.start()  # reset timer for next attempt

func _on_correct():
	current_question += 1
	if current_question >= questions.size():
		emit_signal("puzzle_completed")
		visible = false
	else:
		load_question()

func _on_final_loss():
	_disable_buttons()
	GameManager.stop_music()
	countdown_timer.stop()
	eyestein.play("angry3")
	var vine = AudioStreamPlayer.new()
	vine.stream = load("res://audio/sfx/augh.mp3")
	get_tree().change_scene_to_file("res://scenes/gamescreens/monolog.tscn")
	add_child(vine)
	vine.play()
	_flash_meme()

func _flash_meme():
	meme_flash.visible = true
	var tween = create_tween()
	# fade in to half transparency (0.5 alpha) quickly
	tween.tween_property(meme_flash, "modulate:a", 0.6, 1)
	# hold for a moment
	tween.tween_interval(0.4)
	# fade out slowly
	tween.tween_property(meme_flash, "modulate:a", 0.0, 3)
	# after fully faded go to monologue
	tween.tween_callback(func():
		meme_flash.visible = false
		get_tree().change_scene_to_file("res://scenes/gamescreens/monolog.tscn")
	)

func _disable_buttons():
	$AnswerA.disabled = true
	$AnswerB.disabled = true
	$AnswerC.disabled = true
	$AnswerD.disabled = true
