extends CharacterBody2D

var player = null
var state_machine

# TODO: Play around with the range and speed values
const ATTACK_RANGE = 50
const WALK_RANGE = 300

@export var player_path : NodePath
@export var health = 3
@export var speed = 70

@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.x = 0
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match state_machine.get_current_node():
		"walk":
			if player.global_position.x - $".".global_position.x > 0:
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
	return $".".global_position.distance_to(player.global_position) < WALK_RANGE

func _target_in_attack_range():
	return $".".global_position.distance_to(player.global_position) < ATTACK_RANGE

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
			await $AnimationTree.animation_finished
			queue_free()

func _on_sword_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		player.health -= 1
		player.hurt()
