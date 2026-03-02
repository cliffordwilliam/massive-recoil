class_name CustomAnimatedSprite
extends AnimatedSprite2D

signal flip_h_changed

@export var animation_transitions: Dictionary[StringName, StringName] = { }


func _ready() -> void:
	animation_finished.connect(
		func() -> void:
			if animation_transitions.has(animation):
				play(animation_transitions[animation])
	)


# Setter already exists and I cannot override it, so have to manually use this
func set_flip(value: bool) -> void:
	if flip_h != value:
		flip_h = value
		flip_h_changed.emit()
