extends Node2D

var rightButtonPos = Vector2(779, 763)
var leftButtonPos = Vector2(373, 763)
var centerPos = Vector2(574.0, 763)
var speed = 250
var moveRight = false
var moveLeft = false
var moveCenter = false
var correct = "n/a"
var currentQuestion = 1
var canAnswer = false
var timer: SceneTreeTimer = null

func _ready() -> void:
	var my_font = load("res://fonts/Minecraft.ttf")
	var style = LabelSettings.new()
	style.font = my_font
	style.font_size = 64
	style.font_color = Color.WHITE
	
	var preQuestion = LabelSettings.new()
	preQuestion.font = my_font
	preQuestion.font_size = 32
	preQuestion.font_color = Color.WHITE
	
	var q1 = LabelSettings.new()
	q1.font = my_font
	q1.font_size = 100
	q1.font_color = Color.ROYAL_BLUE
	
	var q2 = LabelSettings.new()
	q2.font = my_font
	q2.font_size = 100
	q2.font_color = Color.CORAL
	
	var q3 = LabelSettings.new()
	q3.font = my_font
	q3.font_size = 100
	q3.font_color = Color.PURPLE
	
	$q1.label_settings = q1
	$q2.label_settings = q2
	$q3.label_settings = q3
	$preQuestion.label_settings = preQuestion
	$openingQ.label_settings = style
	$bunbun.play("idle")
	$ai.play("idle")
	
	# Hide everything initially
	$openingQ.hide()
	$q1.hide()
	$q2.hide()
	$q3.hide()
	$blue.hide()
	$red.hide()
	$pink.hide()
	$orange.hide()
	$purple.hide()
	$black.hide()
	$beamleft.hide()
	$beamright.hide()
	$wrong1.hide()
	$wrong2.hide()
	$wrong3.hide()
	$preQuestion.hide()
	
	await get_tree().create_timer(1.5).timeout
	$openingQ.show()
	
	await get_tree().create_timer(1.7).timeout
	$openingQ.hide()
	$preQuestion.show()
	
	_show_question(1)

func _show_question(q: int) -> void:
	currentQuestion = q
	canAnswer = false
	$ai.play("attack")
	
	# Hide everything
	$q1.hide()
	$q2.hide()
	$q3.hide()
	$blue.hide()
	$red.hide()
	$pink.hide()
	$orange.hide()
	$purple.hide()
	$black.hide()
	$beamleft.hide()
	$beamright.hide()
	$wrong1.hide()
	$wrong2.hide()
	$wrong3.hide()
	
	# Disconnect old signals
	if $blue.pressed.is_connected(_on_right_pressed):
		$blue.pressed.disconnect(_on_right_pressed)
	if $red.pressed.is_connected(_on_left_pressed):
		$red.pressed.disconnect(_on_left_pressed)
	if $pink.pressed.is_connected(_on_right_pressed):
		$pink.pressed.disconnect(_on_right_pressed)
	if $orange.pressed.is_connected(_on_left_pressed):
		$orange.pressed.disconnect(_on_left_pressed)
	if $purple.pressed.is_connected(_on_right_pressed):
		$purple.pressed.disconnect(_on_right_pressed)
	if $black.pressed.is_connected(_on_left_pressed):
		$black.pressed.disconnect(_on_left_pressed)

	if q == 1:
		$q1.show()
		$blue.show()
		$red.show()
		$blue.pressed.connect(_on_right_pressed.bind(true))
		$red.pressed.connect(_on_left_pressed.bind(false))
	elif q == 2:
		$q2.show()
		$pink.show()
		$orange.show()
		$pink.pressed.connect(_on_right_pressed.bind(true))
		$orange.pressed.connect(_on_left_pressed.bind(false))
	elif q == 3:
		$q3.show()
		$purple.show()
		$black.show()
		$purple.pressed.connect(_on_right_pressed.bind(true))
		$black.pressed.connect(_on_left_pressed.bind(false))

	# Start the 3 second countdown
	canAnswer = true
	timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_on_time_ran_out)

func _on_time_ran_out() -> void:
	if not canAnswer:
		return
	canAnswer = false
	correct = "false"
	
	# Hide all buttons
	$blue.hide()
	$red.hide()
	$pink.hide()
	$orange.hide()
	$purple.hide()
	$black.hide()
	
	# Show wrong labels one by one
	$wrong1.show()
	await get_tree().create_timer(0.2).timeout
	$wrong2.show()
	await get_tree().create_timer(0.2).timeout
	$wrong3.show()
	
	# Wait then move on
	await get_tree().create_timer(1.5).timeout
	$wrong1.hide()
	$wrong2.hide()
	$wrong3.hide()
	
	if currentQuestion < 3:
		_show_question(currentQuestion + 1)
	else:
		_game_over()

func _on_right_pressed(isCorrect: bool) -> void:
	if not canAnswer:
		return
	canAnswer = false
	correct = "true" if isCorrect else "false"
	$bunbun.play("walkR")
	$bunbun.scale = Vector2(1.2, 1.2)
	moveLeft = false
	moveRight = true

func _on_left_pressed(isCorrect: bool) -> void:
	if not canAnswer:
		return
	canAnswer = false
	correct = "true" if isCorrect else "false"
	$bunbun.play("walkL")
	$bunbun.scale = Vector2(1.2, 1.2)
	moveLeft = true
	moveRight = false

func _process(_delta: float) -> void:
	if moveLeft:
		$bunbun.global_position = $bunbun.global_position.move_toward(leftButtonPos, speed * _delta)
		if $bunbun.global_position.distance_to(leftButtonPos) < 2:
			moveLeft = false
			$bunbun.play("idle")
			$bunbun.scale = Vector2(1, 1)
			_on_reached_button()
	elif moveRight:
		$bunbun.global_position = $bunbun.global_position.move_toward(rightButtonPos, speed * _delta)
		if $bunbun.global_position.distance_to(rightButtonPos) < 2:
			moveRight = false
			$bunbun.play("idle")
			$bunbun.scale = Vector2(1, 1)
			_on_reached_button()
	elif moveCenter:
		$bunbun.global_position = $bunbun.global_position.move_toward(centerPos, speed * _delta)
		if $bunbun.global_position.distance_to(centerPos) < 2:
			moveCenter = false
			$bunbun.play("idle")
			$bunbun.scale = Vector2(1, 1)
			if currentQuestion < 3:
				_show_question(currentQuestion + 1)
			else:
				_game_over()

func _on_reached_button() -> void:
	if correct == "true":
		if $bunbun.global_position.x < centerPos.x:
			$beamleft.show()
			$beamleft.play("default")
		else:
			$beamright.show()
			$beamright.play("default")
	
	await get_tree().create_timer(1.5).timeout
	$beamleft.hide()
	$beamright.hide()
	
	# Walk back to center
	if $bunbun.global_position.x < centerPos.x:
		$bunbun.play("walkR")
	else:
		$bunbun.play("walkL")
	$bunbun.scale = Vector2(1.2, 1.2)
	moveCenter = true

func _game_over() -> void:
	print("All questions done!")
	# add your scene change here!
