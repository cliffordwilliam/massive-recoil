class_name PageRouter
extends CanvasLayer


func open_page(page_scene: PackedScene) -> void:
	add_child(page_scene.instantiate())
	get_tree().paused = true


func close_page() -> void:
	get_child(0).queue_free()
	get_tree().paused = false
