# Static actor in game world, when player enter, they can open shop page
class_name Shop
extends Area2D

@export var page_router: PageRouter # Set via engine GUI

@onready var black_overlay: Sprite2D = $BlackOverlay


func _ready() -> void:
	assert(page_router, "PageRouter: page_router must be set in the inspector")

	# Sleeps and play animation
	set_process_unhandled_input(false)
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(black_overlay, "modulate:a", 0.0, 1.0)
	tween.tween_property(black_overlay, "modulate:a", 1.0, 1.0)


# Check if player press open shop button
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("accept"):
			page_router.open_buy_page()
			get_viewport().set_input_as_handled()


# Only wakes up if player overlaps me
func _set_active(value: bool, body: Node2D) -> void:
	if body is Player:
		set_process_unhandled_input(value)


func _on_body_entered(body: Node2D) -> void:
	_set_active(true, body)


func _on_body_exited(body: Node2D) -> void:
	_set_active(false, body)
