class_name Digit
extends Sprite2D


func init(i: int) -> Digit:
	position.x = i * get_rect().size.x
	name = StringName(str(abs(i)))
	return self
