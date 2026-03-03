# This is to be managed by NumberDisplay, it is a single number sprite. Parent must be NumberDisplay
class_name Digit
extends Sprite2D


func initialize(i: int) -> void:
	position.x = i * get_rect().size.x
