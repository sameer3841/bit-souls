extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Souls/NumberOfSouls.text = str(Stats.num_of_souls)
	$Item/NumberOfItem.text = str(Stats.num_of_flasks)
	$HealthBar.max_value = Stats.max_health
	$HealthBar.value = Stats.health


func _on_item_button_pressed() -> void:
	Stats.use_flask()
