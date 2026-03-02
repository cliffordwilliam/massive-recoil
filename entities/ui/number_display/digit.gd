# This is to be managed by NumberDisplay, it is a single number sprite
class_name Digit
extends Sprite2D


func initialize(i: int) -> void:
	position.x = i * get_rect().size.x
