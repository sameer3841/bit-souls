extends CharacterBody2D

const SPEED = 260.0
const JUMP_VELOCITY = -550.0
var respawn_point = Vector2(45, -73)
var coin_count = 0

func _process(delta):
	check_fall_off_map()
func check_fall_off_map():
	# Set the Y position threshold, for example, if the player falls below Y = 500
	if position.y > 1000:
		respawn()

func respawn():
	# Reset the player's position to the respawn point
	position = respawn_point
	velocity = Vector2.ZERO # Reset any velocity to stop the player from moving immediately after respawn

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("jump"):
		$AnimatedSprite2D.play("jump")
		
	if is_on_floor():
		$AnimatedSprite2D.play("idle")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var multi = 1
	if Input.is_action_pressed("run"):
		
		multi = 2
	else:
		
		multi = 1
		
		
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * multi
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * multi)
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()
