extends CanvasLayer


signal puzzle_completed

var lives = 4
var anger_animations = ["default", "angry1", "angry2", "angry3"]

var questions = [
	{
		"question": "What has four letters, sometimes nine, always six?",
		"answers": ["A calendar", "A word", "The answer", "A riddle"],
		"correct": 2
	},
	{
		"question": "Click the smallest thing on this page.",
		"answers": ["The moon", "An atom", "This full stop.", "A grain of sand"],
		"correct": 2
	},
	{
		"question": "How many months have 28 days?",
		"answers": ["1", "2", "12", "It depends on the year"],
		"correct": 2
	},
	{
		"question": "A rooster lays an egg on the peak of a roof. Which side does it roll down?",
		"answers": ["Left", "Right", "The steeper side", "Roosters don't lay eggs"],
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
	countdown_timer.start()

	# show warning screen after 2 fails
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

func _on_final_loss():
	_disable_buttons()
	GameManager.stop_music()
	countdown_timer.stop()
	eyestein.play("angry3")
	var vine = AudioStreamPlayer.new()
	vine.stream = load("res://audio/sfx/vine_boom.mp3")
	#get_tree().change_scene_to_file("res://scenes/gamescreens/monolog.tscn")
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
