class_name Shop
extends Area2D


func _ready() -> void:
	set_process_unhandled_input(false)
	var tween: Tween = create_tween().set_loops()
	tween.tween_property($BlackOverlay, "modulate:a", 0.0, 1.0)
	tween.tween_property($BlackOverlay, "modulate:a", 1.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if Input.is_action_just_pressed("accept"):
		if get_tree().current_scene and get_tree().current_scene is Room:
			get_tree().current_scene.page_router.open_shop_page()
			get_viewport().set_input_as_handled()


func _set_active(value: bool, body: Node2D) -> void:
	if body is Player:
		set_process_unhandled_input(value)


func _on_body_entered(body: Node2D) -> void:
	_set_active(true, body)


func _on_body_exited(body: Node2D) -> void:
	_set_active(false, body)
