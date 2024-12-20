extends CharacterBody2D

var player = null
var state_machine

# TODO: Play around with the range and speed values
const ATTACK_RANGE = 50
const WALK_RANGE = 400

@export var health = 3
@export var speed = 85
@export var num_of_souls = 10

@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EnemyGlobals.set_player()
	player = EnemyGlobals.target_player
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return  # Skip processing if player is not found
	
	velocity.x = 0
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match state_machine.get_current_node():
		"walk":
			if player.global_position.x - global_position.x > 0:
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
	return player != null and global_position.distance_to(player.global_position) < WALK_RANGE

func _target_in_attack_range():
	return player != null and global_position.distance_to(player.global_position) < ATTACK_RANGE

func drop_items():
	EnemyGlobals.drop_items(self, num_of_souls)

# TODO: Change collision layers/masks to work and create/set groups "player_sword" and "player_hitbox" in player scene
func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_sword"):
		print("Health is: ", health)
		health -= 1
		if health > 0:
			anim_tree.set("parameters/conditions/hurt", true)
			await $AnimationTree.animation_finished
			anim_tree.set("parameters/conditions/hurt", false)
		else:
			anim_tree.set("parameters/conditions/die", true)


func _on_sword_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		Stats.take_damage(1)
