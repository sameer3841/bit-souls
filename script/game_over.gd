extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Stats.health = Stats.max_health
	Stats.num_of_souls = 0
	$AnimationPlayer.play("GameOver")

func return_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
