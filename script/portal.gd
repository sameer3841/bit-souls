extends Node2D

@export var next_level: String





func _on_portal_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file(next_level)
