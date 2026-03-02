# Upgraded AnimatedSprite2D so that it has flip h signal and transition animation feature
# WARNING: Always use set_flip() instead of setting flip_h directly, or the signal won't emit
class_name CustomAnimatedSprite
extends AnimatedSprite2D

signal flip_h_changed

@export var animation_transitions: Dictionary[StringName, StringName] = { }


func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


# Setter already exists and I cannot override it, so have to manually use this
func set_flip(value: bool) -> void:
	if flip_h != value:
		flip_h = value
		flip_h_changed.emit()


func _on_animation_finished() -> void:
	if animation_transitions.has(animation):
		play(animation_transitions[animation])
