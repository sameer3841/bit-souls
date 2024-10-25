extends CharacterBody2D

var current_state = player_status.MOVE
enum player_status {MOVE, JUMP, ATTACK}

const SPEED = 260.0
const JUMP_VELOCITY = -550.0
const COMBO_TIMEOUT = 0.1

var respawn_point = Vector2(45, -73)
var coin_count = 0
var combo_counter = 0
var combo_timer := Timer.new()

func _ready():
	add_child(combo_timer)
	combo_timer.wait_time = COMBO_TIMEOUT
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)

func _process(delta):
	if Input.is_action_just_pressed("jump"): current_state = player_status.JUMP
	if Input.is_action_just_pressed("attack"): 
		combo_counter += 1
		current_state = player_status.ATTACK
	check_fall_off_map()

func check_fall_off_map():
	if position.y > 1000: respawn()

func respawn():
	position = respawn_point
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:

	if not is_on_floor(): velocity += get_gravity() * delta

	match current_state:
		player_status.JUMP:
			$AnimatedSprite2D.play("jump")
			velocity.y = JUMP_VELOCITY
			current_state = player_status.MOVE

		player_status.MOVE:
			var multi = 1
			if Input.is_action_pressed("run"): multi = 2
			else: multi = 1
			var direction := Input.get_axis("left", "right")
			if direction != 0:
				velocity.x = direction * SPEED * multi
				if is_on_floor(): $AnimatedSprite2D.play("run")
				$AnimatedSprite2D.flip_h = velocity.x < 0
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED * multi)
				if is_on_floor(): $AnimatedSprite2D.play("idle")
			if not is_on_floor():
				$AnimatedSprite2D.play("jump")
				await is_on_floor()
		player_status.ATTACK:
			handle_combo()
	move_and_slide()


func handle_combo():
	if combo_counter == 1:
		$AnimatedSprite2D.play("attack1")  # First attack animation
		await $AnimatedSprite2D.animation_finished
		current_state = player_status.MOVE

	elif combo_counter == 2:
		$AnimatedSprite2D.play("attack2")  # Second attack animation (combo move)
		await $AnimatedSprite2D.animation_finished
		current_state = player_status.MOVE

	elif combo_counter == 3:
		$AnimatedSprite2D.play("attack3")  # Third attack animation (3-combo move)
		await $AnimatedSprite2D.animation_finished
		current_state = player_status.MOVE
		combo_counter = 0

	combo_timer.start()

func _on_combo_timeout():
	combo_counter = 0
