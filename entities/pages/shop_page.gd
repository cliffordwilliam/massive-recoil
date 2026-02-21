extends Control


func _ready() -> void:
	$Label.text = "Money: " + str(GameState.money)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().current_scene.page_router.close_page()
