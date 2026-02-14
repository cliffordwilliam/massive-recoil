class_name AnimatedSprite
extends AnimatedSprite2D

@export var transitions: Dictionary[StringName, StringName] = {}

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if transitions.has(animation):
		play(transitions[animation])
