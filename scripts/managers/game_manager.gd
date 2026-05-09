extends Node

var irritation_level : int = 0
var health           : int = 100
var current_stage    : int = 1

func reset_for_puzzle():
	irritation_level = 0

func restore_health(amount: int):
	health = min(health + amount, 100)

func take_damage(amount: int):
	health = max(health - amount, 0)
