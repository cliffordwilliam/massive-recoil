# Upgraded AnimatedSprite2D that adds a flip_h signal and transition animation feature.
class_name MyAnimatedSprite
extends AnimatedSprite2D

# Warning: always use set_flip instead of setting AnimatedSprite2D.flip_h directly,
# or the signal will not emit.
signal flip_h_changed

@export var animation_transitions: Dictionary[StringName, StringName] = { }


# In Godot you cannot override the setter of an existing/built‑in property.
# There is no way in Godot to “enforce” that other code uses set_flip().
# So I have to manually call this everywhere instead.
func set_flip(value: bool) -> void:
	if flip_h != value:
		flip_h = value
		flip_h_changed.emit()


func _on_animation_finished() -> void: # Connected via engine GUI
	if animation_transitions.has(animation):
		play(animation_transitions[animation])
