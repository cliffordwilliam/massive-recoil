class_name Digit
extends Sprite2D


# Single sprite digit managed by NumberDisplay. Parent must be NumberDisplay.
func initialize(i: int) -> void:
	position.x = i * get_rect().size.x
