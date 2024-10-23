extends CharacterBody2D

var state_machine
var health = 5
const SPEED = 150
const JUMP_VELOCITY = -400.0
@onready var anim_tree = $AnimationTree


func _ready() -> void:
	state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x < 0:
		$Sprite2D.flip_h = true
		$SwordArea.rotation_degrees = 180
	if velocity.x > 0:
		$Sprite2D.flip_h = false
		$SwordArea.rotation_degrees = 0
	
		
	# conditions
	anim_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	anim_tree.set("parameters/conditions/walk", velocity.x != 0)
	anim_tree.set("parameters/conditions/attack1", Input.is_action_just_pressed("attack"))

	move_and_slide()

func hurt():
	if health > 0:
		anim_tree.set("parameters/conditions/hurt", true)
		await $AnimationTree.animation_finished
		anim_tree.set("parameters/conditions/hurt", false)
	else:
		anim_tree.set("parameters/conditions/die", true)
		await $AnimationTree.animation_finished
		queue_free()
