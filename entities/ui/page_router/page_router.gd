class_name PageRouter
extends CanvasLayer


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel") and get_child_count():
		return close_page()
	if Input.is_action_just_pressed("inventory") and not get_child_count():
		return open_page(preload("uid://cenchx8ug57g2"))


func open_page(page_scene: PackedScene) -> void:
	add_child(page_scene.instantiate())
	get_tree().paused = true


func close_page() -> void:
	get_child(0).queue_free()
	get_tree().paused = false
