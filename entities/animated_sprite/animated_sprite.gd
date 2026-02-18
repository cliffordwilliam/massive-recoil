class_name AnimatedSprite
extends AnimatedSprite2D

signal flip_h_changed

@export var transitions: Dictionary[StringName, StringName] = { }


func _ready() -> void:
	animation_finished.connect(
		func() -> void: if transitions.has(animation):play(transitions[animation])
	)


func set_flip(value: bool) -> void:
	if flip_h != value:
		flip_h = value
		flip_h_changed.emit()
