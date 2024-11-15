extends Node2D

const LEFT = Vector2.LEFT
const SPEED = 175

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement = LEFT.rotated(rotation) * SPEED * delta
	global_position += movement

func destroy():
	$AnimationTree.set("parameters/conditions/destroyed", true)
	await $AnimationTree.animation_finished
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
	
#TODO: add function to destroy the projectile when it collides with the ground or player
#func _on_area_2d_area_entered(area: Area2D) -> void:
#	destroy()
