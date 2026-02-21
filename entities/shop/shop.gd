class_name Shop
extends Area2D


func _ready() -> void:
	set_process_unhandled_input(false)
	var tween: Tween = create_tween().set_loops()
	tween.tween_property($PulseBackground, "modulate", Color.WHITE, 1.0)
	tween.tween_property($PulseBackground, "modulate", Color.BLACK, 1.0)
	create_tween().set_loops(). \
	tween_method(func(x: float) -> void: $Background.region_rect.position.x = x, 0.0, 128.0, 12.8)
	body_entered.connect(func(_body: Player) -> void: set_process_unhandled_input(true))
	body_exited.connect(func(_body: Player) -> void: set_process_unhandled_input(false))


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().current_scene.page_router.open_page(preload("uid://euoup28876nb"))
