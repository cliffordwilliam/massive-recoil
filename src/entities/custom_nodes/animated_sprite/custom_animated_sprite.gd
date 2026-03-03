class_name CustomAnimatedSprite
extends AnimatedSprite2D

# Upgraded AnimatedSprite2D so that it has flip h signal and transition animation feature
# Warning: Always use set_flip instead of setting AnimatedSprite2D.flip_h directly, or the signal will not emit.
signal flip_h_changed

@export var animation_transitions: Dictionary[StringName, StringName] = { }


func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


# In Godot you cannot override the setter of an existing/built‑in property
# There is no way in Godot to “enforce” that other code uses set_flip()
# So I have to manually use this
func set_flip(value: bool) -> void:
	if flip_h != value:
		flip_h = value
		flip_h_changed.emit()


func _on_animation_finished() -> void:
	if animation_transitions.has(animation):
		play(animation_transitions[animation])
