extends CharacterBody2D

var player
var pickup_speed
const PICKUP_RANGE = 100
const ORANGE = Color(0.79, 0.341, 0.175)
const YELLOW = Color(1, 1, 0)
const colors = [ORANGE, YELLOW]
var newColor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_parent().get_node("Player") # there is definitely a better way to get the player...
	pickup_speed = randi_range(65, 100)
	scale.x = randf_range(0.2, 0.4)
	scale.y = scale.x
	newColor = colors[randi() % colors.size()]
	$ColorRect.color = newColor
	$PointLight2D.color = newColor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ColorRect.color = lerp($ColorRect.color, newColor, 0.2)
	$PointLight2D.color = lerp($PointLight2D.color, newColor, 0.2)
	velocity = Vector2.ZERO
	if (player_in_pickup_range()):
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * pickup_speed
	move_and_slide()

# TODO: Figure out how to get the player's position.
func player_in_pickup_range():
	return global_position.distance_to(player.global_position) <= PICKUP_RANGE

func _on_timer_timeout() -> void:
	match newColor:
		ORANGE:
			newColor = YELLOW
		YELLOW:
			newColor = ORANGE
	$Timer.wait_time = randf_range(0.3, 1)

# TODO: Currently, it is only collected via sword swing. Figure out how to collect it by walking into it.
func _on_area_2d_area_entered(area: Area2D) -> void:
	# increase number of souls by one
	print("pickup")
	queue_free()
