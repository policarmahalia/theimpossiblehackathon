extends Control

func _ready():
	GameManager.play_music("res://audio/music/menu_and_stage.mp3")
	$StartButton.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/world/MainWorld.tscn")
