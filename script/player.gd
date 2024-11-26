extends CharacterBody2D

var current_state = player_status.MOVE
enum player_status {MOVE, JUMP, ATTACK, FALL, ROLL, HURT}

@export var respawnX: float
@export var respawnY: float

const SPEED = 260.0
const JUMP_VELOCITY = -550.0
const COMBO_TIMEOUT = 0.1



var respawn_point = Vector2(respawnX, respawnY)
var combo_counter = 0
var combo_timer := Timer.new()
var isAttacking = false


func _ready():
	add_child(combo_timer)
	combo_timer.wait_time = COMBO_TIMEOUT
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)

func _process(_delta):
	respawn_point = Vector2(respawnX, respawnY)
	if Input.is_action_just_pressed("use_item"):
		Stats.use_flask()
	if Input.is_action_just_pressed("jump") && is_on_floor() && current_state == player_status.MOVE:
		current_state = player_status.JUMP
	if Input.is_action_just_pressed("attack"): 
		combo_counter += 1
		current_state = player_status.ATTACK
	if Input.is_action_just_pressed("roll") && is_on_floor() && velocity.x != 0:
		current_state = player_status.ROLL
	check_fall_off_map()

func check_fall_off_map():
	if position.y > 1000: respawn()

func respawn():
	position = respawn_point
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:

	if not is_on_floor(): velocity += get_gravity() * delta
	if velocity.x < 0:
		$player_sword.rotation_degrees = 180
	if velocity.x > 0:
		$player_sword.rotation_degrees = 0
		
	match current_state:
		player_status.JUMP:
			
			$AnimatedSprite2D.play("jump")
			var direction := Input.get_axis("left", "right")
			if direction != 0:
				velocity.x = direction * SPEED * 1
				$AnimatedSprite2D.flip_h = velocity.x < 0
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED * 1)
			if velocity.y > 0:
				current_state = player_status.FALL
			
			
		player_status.FALL:
			$AnimatedSprite2D.play("falling")
			var direction := Input.get_axis("left", "right")
			if is_on_floor():
				$AnimatedSprite2D.play("landing")
				current_state = player_status.MOVE
			if direction != 0:
				velocity.x = direction * SPEED * 1
				$AnimatedSprite2D.flip_h = velocity.x < 0
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED * 1)
			
			
		player_status.MOVE:
			var multi = 1
			if Input.is_action_pressed("block"):
				$AnimatedSprite2D.play("block")
				await $AnimatedSprite2D.animation_finished
			if Input.is_action_pressed("run") and is_on_floor(): multi = 2
			else: multi = 1
			var direction := Input.get_axis("left", "right")
			if direction != 0:
				velocity.x = direction * SPEED * multi
				if is_on_floor(): $AnimatedSprite2D.play("run")
				$AnimatedSprite2D.flip_h = velocity.x < 0
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED * multi)
				if is_on_floor(): $AnimatedSprite2D.play("idle")
					
			if is_on_floor() and Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				current_state = player_status.JUMP
			elif not is_on_floor():
				current_state = player_status.FALL
				
		player_status.ATTACK:
			handle_combo()
		
		player_status.ROLL:
			roll()
		
		player_status.HURT:
			velocity.x = 0
			hurt()
	
	move_and_slide()


func handle_combo():
	# Perform air attack if not on floor
	if not is_on_floor():
		combo_counter -= 1
		$AnimationPlayer.play("air_atk")
		await $AnimationPlayer.animation_finished
		current_state = player_status.MOVE
		return  # Exit function to avoid running other code
	
	match combo_counter:
		1:
			$AnimationPlayer.play("attack1")  # First attack animation
			await $AnimationPlayer.animation_finished
		2:
			$AnimationPlayer.play("attack2")  # Second attack animation (combo move)
			await $AnimationPlayer.animation_finished
		3:
			$AnimationPlayer.play("attack3")  # Third attack animation (end of combo)
			await $AnimationPlayer.animation_finished
			combo_counter = 0  # Reset combo after last attack
		_:
			combo_counter = 0  # Safety reset for unexpected counter values

	current_state = player_status.MOVE
	combo_timer.start()

func _on_combo_timeout():
	combo_counter = 0
	
func roll():
	$AnimationPlayer.play("roll")
	await $AnimationPlayer.animation_finished
	current_state = player_status.MOVE

func hurt():
	$AnimationPlayer.play("hurt")
	await $AnimationPlayer.animation_finished
	if Stats.health > 0:
		current_state = player_status.MOVE
	else:
		game_over()

func game_over():
	Stats.reset()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		current_state = player_status.HURT
