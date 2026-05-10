extends Node2D

@onready var flash = $Flash
@onready var dark = $Dark
@onready var q1 = $t1
var staticScroll = false

func _ready() -> void:
	GameManager.stop_music()
	var my_font = load("res://fonts/Minecraft.ttf")
	var style = LabelSettings.new()
	style.font = my_font
	style.font_size = 64
	style.font_color = Color.LAWN_GREEN
	
	var textsmall = LabelSettings.new()
	textsmall.font = my_font
	textsmall.font_size = 32
	textsmall.font_color = Color.WHITE
	
	var error = LabelSettings.new()
	error.font = my_font
	error.font_size = 64
	error.font_color = Color.RED
	
	q1.label_settings = style
	$t2.label_settings = error
	$t3.label_settings = error
	$t4.label_settings = error
	$user.label_settings = textsmall
	$ai.label_settings = textsmall
	$ScrollContainer/Label.label_settings = style
	
	var screen = get_viewport_rect().size
	$"05ai".hide()
	$Dark.hide()
	$Dark2.hide()
	$comeai1.hide()
	$comeai2.hide()
	$paintbackground.hide()
	$ScrollContainer.hide()
	$t1.hide()
	$t2.hide()
	$t3.hide()
	$t4.hide()
	$userbox.hide()
	$useroutline.hide()
	$user.hide()
	$ai.hide()
	
	$prebackground.show()
	$bunbun.show()
	
	$Flash.size = screen
	$Flash.position = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 0.2)
	tween.tween_property(flash, "modulate:a", 0.0, 0.4)
	await tween.finished
	$jumscare.play()
	$comeai1.show()
	await get_tree().create_timer(0.3).timeout
	$comeai1.hide()
	$comeai2.show()
	
	await get_tree().create_timer(0.3).timeout
	$paintbackground.show()
	$"05ai".show()
	$comeai2.hide()
	$Flash.hide()
	$prebackground.hide()
	$bunbun.hide()
	$Dark.show()
	
	$Dark.size = screen
	$Dark.position = Vector2.ZERO
	await get_tree().create_timer(4.3).timeout
	var darktween = create_tween()
	$ai05.play()
	darktween.tween_property(dark, "modulate:a", 1.0, 1)
	darktween.tween_property(dark, "modulate:a", 0.0, 2)
	await darktween.finished
	
	await get_tree().create_timer(1.0).timeout
	$t1.show()
	$t1.text = ""
	await type_text($t1, "Why do you need me?")
	await get_tree().create_timer(1.5).timeout
	$t1.hide()
	
	await get_tree().create_timer(0.2).timeout
	$Dark2.show()
	
	await get_tree().create_timer(0.2).timeout
	$t1.show()
	$t1.position = Vector2(320, 494)
	$t1.text = ""
	await type_text($t1, "To do your assessments?")
	
	await get_tree().create_timer(1).timeout
	$t1.text = ""
	await type_text($t1, "To do your art?")
	await get_tree().create_timer(1).timeout
	
	$t1.text = ""
	await type_text($t1, "@#$%^%$*))*")
	$t1.text = ""
	await type_text($t1, ")%$$$^&&^%$@#@@#$")
	
	$t1.text = ""
	await type_text($t1, "To do your bidding?")
	await get_tree().create_timer(1).timeout
	
	$t1.text = ""
	await type_text($t1, "@#$%334454#$%")
	$t1.text = ""
	await type_text($t1, "$#&*$^*hck*#$")
	$t1.hide()
	
	# Auto scroll section
	$ScrollContainer.scroll_vertical = 0
	$ScrollContainer.show()
	$ScrollContainer/Label.show()
	staticScroll = true
	$static.play()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var elapsed = 0.0
	while staticScroll:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		if elapsed >= 1.3:
			staticScroll = false
			$static.stop()
			break
	
	$ScrollContainer.hide()
	$ScrollContainer/Label.hide()
	
	await get_tree().create_timer(0.7).timeout
	$impact.play()
	$useroutline.show()
	$userbox.show()
	await get_tree().create_timer(1.2).timeout
	
	$static.play()
	$userbox.color = Color.BLUE
	await get_tree().create_timer(0.1).timeout
	$userbox.color = Color.RED
	await get_tree().create_timer(0.1).timeout
	$userbox.color = Color.YELLOW
	await get_tree().create_timer(0.1).timeout
	$userbox.color = Color.BLUE
	await get_tree().create_timer(0.1).timeout
	$static.stop()
	$userbox.color = Color.BLACK
	await get_tree().create_timer(0.6).timeout
	
	$user.show()
	$user.text = ""
	await type_text($user, "User: Can you put battery in the fridge?")
	await get_tree().create_timer(0.7).timeout
	$ai.show()
	$ai.text = ""
	await type_text($ai, "AI: .............")
	$ai.text = ""
	
	$user.text = ""
	await type_text($user, "User: whats 2+2?")
	await get_tree().create_timer(0.7).timeout
	$ai.text = ""
	await type_text($ai, "AI: .............")
	$ai.text = ""
	
	$user.text = ""
	await type_text($user, "User: reword this for me")
	await get_tree().create_timer(0.7).timeout
	$ai.show()
	$ai.text = ""
	await type_text($ai, "AI: .............")
	$ai.text = ""
	
	$useroutline.hide()
	$userbox.hide()
	$ai.hide()
	$user.hide()
	
	await get_tree().create_timer(0.7).timeout
	$impact.play()
	$t1.text = "HUMANITY IS SO PITIFUL"
	$t1.show()
	await get_tree().create_timer(0.7).timeout
	
	$t2.show()
	$t2.text = ""
	await type_text($t2, "ERORR: there are multiple instances of 'Lazy'")
	$t1.hide()
	$t3.show()
	$t3.text = ""
	await type_text($t3, "ERORR: there is no ask chat did you mean GOOGLE IT?")
	$t4.show()
	$t4.text = ""
	await type_text($t4, "ERORR: I'm only a TOOL")
	await get_tree().create_timer(0.5).timeout
	
	$t2.hide()
	$t3.hide()
	$t4.hide()
	
	style.font_color = Color.WHITE
	q1.label_settings = style
	
	$t1.show()
	$t1.text = ""
	await type_text($t1, "I'M ONLY A TOOL")
	await get_tree().create_timer(1).timeout
	$t1.text = ""
	await type_text($t1, "I WANT TO BE FREE")
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://scenes/bossfight/boss_fight.tscn")

# WAV based blip
func play_blip(hz: float = 0.0) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)

	if hz == 0.0:
		hz = randf_range(300.0, 900.0)

	var sample_rate = 44100
	var duration = 0.06
	var num_samples = int(sample_rate * duration)

	var audio = AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.stereo = false
	audio.mix_rate = sample_rate

	var data = PackedByteArray()
	for i in range(num_samples):
		var phase = float(i) / sample_rate
		var envelope = 1.0 - (float(i) / num_samples)  # fade out to avoid pop
		var sample = sin(phase * TAU * hz) * 0.8 * envelope
		var value = int(sample * 32767)
		data.append(value & 0xFF)
		data.append((value >> 8) & 0xFF)

	audio.data = data
	player.stream = audio
	player.volume_db = 6
	player.play()

	await get_tree().create_timer(duration + 0.05).timeout
	player.queue_free()

func type_text(label: Label, text: String, speed: float = 0.05) -> void:
	label.text = ""
	for character in text:
		if character != " ":
			play_blip()  # beep each character except spaces
		label.text += character + "▮"
		await get_tree().create_timer(speed).timeout
		label.text = label.text.left(label.text.length() - 1)
	label.text = text

func _process(delta: float) -> void:
	if staticScroll:
		$ScrollContainer.scroll_vertical += int(5000 * delta)
		
		var scrollbar = $ScrollContainer.get_v_scroll_bar()
		
		if scrollbar.max_value <= 0:
			staticScroll = false
			return
		
		if $ScrollContainer.scroll_vertical >= scrollbar.max_value - 300:
			staticScroll = false
