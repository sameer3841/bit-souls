extends CharacterBody2D

var player = null
var state_machine
var is_chasing
const CHASE_RANGE = 400
const TOO_CLOSE_RANGE = 200
const TOO_FAR_RANGE = 250

@export var player_path : NodePath
@export var health = 3
@export var speed = 200

@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node_or_null(player_path)
	if player == null:
		print("Warning: Player node not found at path ", player_path)
	state_machine = anim_tree.get("parameters/playback")
	is_chasing = false

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	match state_machine.get_current_node():
		"Idle":
			is_chasing = target_in_range()
		"Move":
			var target_position = Vector2(player.global_position.x, player.global_position.y + 30)
			rotation = target_position.angle_to_point(position)
			if target_too_close():
				var direction = target_position.direction_to(position)
				velocity = direction * speed
			elif target_too_far():
				var direction = position.direction_to(target_position)
				velocity = direction * speed
	
	anim_tree.set("parameters/conditions/move", is_chasing)
	anim_tree.set("parameters/conditions/attack", !target_too_far())
	
	move_and_slide()

func target_in_range():
	return global_position.distance_to(player.global_position) < CHASE_RANGE

func target_too_far():
	return global_position.distance_to(player.global_position) > TOO_FAR_RANGE

func target_too_close():
	return global_position.distance_to(player.global_position) < TOO_CLOSE_RANGE

func target_in_attack_range():
	return target_in_range() && !target_too_close()
	
func attack():
	var projectile = load("res://scenes/eye_beast_projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.global_rotation = global_rotation

func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_sword"):
		health -= 1
		if health >= 0:
			anim_tree.set("parameters/conditions/hit", true)
			await $AnimationTree.animation_finished
			anim_tree.set("parameters/conditions/hit", false)
		else:
			anim_tree.set("parameters/conditions/death", true)
			await $AnimationTree.animation_finished
			queue_free()
