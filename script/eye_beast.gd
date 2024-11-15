extends CharacterBody2D

var player
var state_machine
var is_chasing
const CHASE_RANGE = 400
const TOO_CLOSE_RANGE = 150
const TOO_FAR_RANGE = 200

@export var health = 3
@export var speed = 200
@export var num_of_souls = 20

@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EnemyGlobals.set_player() # there is probably a better place to put this line, but it works for now
	player = EnemyGlobals.target_player
	state_machine = anim_tree.get("parameters/playback")
	is_chasing = false

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	match state_machine.get_current_node():
		"Idle":
			is_chasing = target_in_range()
		"Move":
			rotation = player.global_position.angle_to_point(position)
			if target_too_close():
				var direction = player.global_position.direction_to(position)
				velocity = direction * speed
			elif target_too_far():
				var direction = position.direction_to(player.global_position)
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

func drop_items():
	EnemyGlobals.drop_items(self, num_of_souls)

func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_sword"):
		health -= 1
		if health > 0:
			anim_tree.set("parameters/conditions/hit", true)
			await $AnimationTree.animation_finished
			anim_tree.set("parameters/conditions/hit", false)
		else:
			anim_tree.set("parameters/conditions/hit", true)
			anim_tree.set("parameters/conditions/death", true)
