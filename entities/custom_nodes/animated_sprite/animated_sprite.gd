class_name AnimatedSprite
extends AnimatedSprite2D

signal flip_h_changed

@export var trans: Dictionary[StringName, StringName] = { }


func _ready() -> void:
	animation_finished.connect(
		func() -> void:
			if trans.has(animation):
				play(trans[animation])
	)


func set_flip(value: bool) -> void:
	if flip_h != value:
		flip_h = value
		flip_h_changed.emit()
