# Single sprite digit managed by NumberDisplay. Parent must be NumberDisplay.
class_name Digit
extends Sprite2D


func initialize(i: int) -> void:
	if not Utils.require(texture != null, "Digit: texture must be assigned in the inspector"):
		return
	position.x = i * get_rect().size.x
