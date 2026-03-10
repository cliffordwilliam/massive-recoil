class_name Digit
extends Sprite2D
## A single digit sprite used by SpriteNumber to render numerical values.
##
## The Digit class represents an individual numeral in a sprite-based number display.
## It is intended to be instantiated by a parent SpriteNumber node, which manages
## multiple Digit instances to render full integers.


## Initializes the digit and sets its horizontal position.
## `i` is the index of the digit in the parent number sequence.
func initialize(i: int) -> void:
	if not Utils.require(texture != null, "Digit: texture must be assigned in the inspector"):
		return
	position.x = i * get_rect().size.x
