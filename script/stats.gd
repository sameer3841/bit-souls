extends Node

var max_health = 5
var health = 5
var num_of_souls = 0

func take_damage(amount):
	health -= amount
	print("Player Health:", health)

func collect_soul(amount):
	num_of_souls += amount
