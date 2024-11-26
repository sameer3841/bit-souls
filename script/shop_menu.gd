extends CanvasLayer

var selected_item
var cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("TransitionIn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/Souls/NumberOfSouls.text = str(Stats.num_of_souls)
	match selected_item:
		"Red Flask":
			cost = 75
			$Control/SelectedLabel.text = "selected: red flask"
			$Control/DescriptionLabel.text = "drink to regain some health"
			$Control/CostLabel.text = "cost: " + str(cost)


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	$AnimationPlayer.play("TransitionOut")
	get_parent().get_node("GUI").visible = true
	queue_free()

func _on_purchase_button_pressed() -> void:
	if cost != null && cost <= Stats.num_of_souls:
		Stats.num_of_souls -= cost
		match selected_item:
			"Red Flask":
				Stats.num_of_flasks += 1
	
	
func _on_red_potion_button_pressed() -> void:
	selected_item = "Red Flask"
