# Static actor in the game world; when the player overlaps it, they can open the shop page.
class_name Shop
extends Area2D

@onready var black_overlay: Sprite2D = $BlackOverlay


func _ready() -> void:
	# Starts sleeping.
	set_process_unhandled_input(false)

	# Plays animation.
	# Node.create_tween() already binds to self — no need for bind_node(self).
	# Ref: docs/godot/classes/class_node.rst — create_tween():
	# "This is the equivalent of doing: get_tree().create_tween().bind_node(self)"
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(black_overlay, "modulate:a", 0.0, 1.0)
	tween.tween_property(black_overlay, "modulate:a", 1.0, 1.0)


# Only check for the open‑shop input while I am awake.
func _unhandled_input(event: InputEvent) -> void:
	# This game uses keyboard input only.
	if event is not InputEventKey:
		return

	if event.is_action_pressed("accept"):
		PageRouter.open_shop_page()
		get_viewport().set_input_as_handled()


# Only wakes up if player overlaps me.
func _set_active(value: bool, body: Node2D) -> void:
	if body is Player:
		set_process_unhandled_input(value)


func _on_body_entered(body: Node2D) -> void: # Connected via engine GUI.
	_set_active(true, body)


func _on_body_exited(body: Node2D) -> void: # Connected via engine GUI.
	_set_active(false, body)
