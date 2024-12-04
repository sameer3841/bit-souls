extends Node2D

var interactable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interactable && Input.is_action_just_pressed("interact"):
		$InteractLabel.visible = false
		var shop_menu = load("res://scenes/shop_menu.tscn").instantiate()
		get_parent().add_child(shop_menu)
		get_parent().get_node("GUI").visible = false
		get_tree().paused = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$InteractLabel.visible = true
		interactable = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$InteractLabel.visible = false
		interactable = false
