class_name ShopPage
extends Sprite2D


func _ready() -> void:
	$NumberDisplay.display_number(GameState.money)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().current_scene.page_router.close_page()
