extends Node

var target_player

# set target_player to a reference to the player in a scene
func set_player():
	target_player = get_tree().current_scene.get_node_or_null("Player")
	if target_player == null:
		print("Warning: Player node not found")

# can be used to make enemies drop souls
func drop_items(enemy):
	for n in range(enemy.num_of_souls):
		var soul = load("res://scenes/soul.tscn").instantiate()
		enemy.get_parent().add_child(soul)
		soul.global_position = Vector2(enemy.global_position.x + randf_range(-10, 10), enemy.global_position.y + randf_range(-10, 10))
		#print("drop soul")
