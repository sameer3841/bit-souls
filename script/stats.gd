extends Node

var max_health = 5
var health = 5
var num_of_souls = 0
var num_of_flasks = 2
var flask_strength = 3

func reset():
	health = max_health
	num_of_souls = 0
	num_of_flasks = 2

func heal(amount):
	health = mini(max_health, health + amount)
	print("Player Health:", health)

func use_flask():
	if num_of_flasks > 0 && health < 5:
		num_of_flasks -= 1
		heal(flask_strength)

func take_damage(amount):
	health -= amount
	print("Player Health:", health)

func collect_soul(amount):
	num_of_souls += amount
