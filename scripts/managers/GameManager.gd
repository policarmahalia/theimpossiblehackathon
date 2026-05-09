# game_manager.gd
extends Node

signal answer_given_correct
signal answer_given_wrong

var health: int = 25
var irritation_level: int = 0
var current_stage: int = 1

func answer_correct():
	health = min(health + 25, 100)
	emit_signal("answer_given_correct")

func answer_wrong():
	irritation_level += 1
	emit_signal("answer_given_wrong")

func reset():
	health = 25
	irritation_level = 0
	current_stage = 1

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_music(path: String):
	if music_player.stream and music_player.playing:
		if music_player.stream.resource_path == path:
			return  # already playing this song, don't restart
	music_player.stream = load(path)
	music_player.play()

func stop_music():
	music_player.stop()
