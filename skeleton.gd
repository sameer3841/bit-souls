extends CharacterBody2D

var player = null
var state_machine

# TODO: Play around with the range and speed values
const ATTACK_RANGE = 2
const WALK_RANGE = 12

@export var player_path : NodePath
@export var health = 3
@export var speed = 3.0

@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	match state_machine.get_current_node():
		"walk":
			if not is_on_floor():
				velocity += get_gravity() * delta
			if player.global_position - global_position > 0:
				$Sprite2D.scale.x = 1
				$SwordArea.rotation_degrees = 0
				velocity.x = speed
			else:
				$Sprite2D.scale.x = -1
				$SwordArea.rotation_degrees = 180
				velocity.x = -speed
	
	# Conditions
	anim_tree.set("parameters/conditions/idle", !_target_in_range())
	anim_tree.set("parameters/conditions/walk", _target_in_range())
	anim_tree.set("parameters/conditions/attack1", _target_in_attack_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < WALK_RANGE

func _target_in_attack_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

# TODO: Change collision layers/masks to work and create/set groups "player_sword" and "player_hitbox" in player scene
func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_sword"):
		health -= 1
		if health > 0:
			anim_tree.set("parameters/conditions/hurt", true)
			await $AnimationTree.animation_finished
			anim_tree.set("parameters/conditions/hurt", false)
		else:
			anim_tree.set("parameters/conditions/die", true)
			await get_tree().create_timer(2.5).timeout
			queue_free()

func _on_sword_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		pass # TODO: Subtract 1 from player's health
