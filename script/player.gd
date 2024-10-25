extends CharacterBody2D

const SPEED = 260.0
const JUMP_VELOCITY = -550.0
var respawn_point = Vector2(45, -73)
var coin_count = 0

func _process(delta):
	check_fall_off_map()
	
func check_fall_off_map():
	if position.y > 1000:
		respawn()

func respawn():
	position = respawn_point
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		$AnimatedSprite2D.play("jump")
		velocity.y = JUMP_VELOCITY
		

	var multi = 1
	if Input.is_action_pressed("run"):
		multi = 2
	else:
		multi = 1

	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED * multi
		if is_on_floor():
			$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * multi)
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
	
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	
	move_and_slide()
