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
