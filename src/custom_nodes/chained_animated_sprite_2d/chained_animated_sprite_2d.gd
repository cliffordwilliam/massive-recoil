class_name ChainedAnimatedSprite2D
extends AnimatedSprite2D
## An [AnimatedSprite2D] that automatically transitions to a follow-up animation on finish.
##
## Configure [member animation_transitions] in the Inspector to map a source animation to the
## animation that should play immediately after it ends. Connect
## [signal AnimatedSprite2D.animation_finished]
## to [method _on_animation_finished] via the Inspector.
##
## Example: [code]{ &"turn": &"idle" }[/code] plays the idle animation after turn completes.

@export var animation_transitions: Dictionary[StringName, StringName] = {}


func _on_animation_finished() -> void:
	if animation_transitions.has(animation):
		play(animation_transitions[animation])
