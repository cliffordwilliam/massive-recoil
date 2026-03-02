# The only thing that renders number using sprites, this game only renders positive numbers
class_name NumberDisplay
extends Node2D

@export var digit_scene: PackedScene # Set via engine GUI
@export var right_aligned: bool = false
@export var pad: bool = false
@export var digits: int = 6


func _ready() -> void:
	for i in range(digits): # Add digit sprite from left to right
		var d: Digit = digit_scene.instantiate()
		add_child(d)
		d.initialize(-(digits - i) if right_aligned else i)


func display_number(number: int) -> void:
	number = clampi(number, 0, int(pow(10, digits)) - 1) # Number is chopped to max digit sprites
	var raw: String = str(number)
	var digit_count: int = raw.length()
	var text: String = raw.lpad(digits, "0") if right_aligned else raw.rpad(digits, "0")
	for i in get_child_count():
		var d: Digit = get_child(i)
		assert(d is Digit, "NumberDisplay: all children must be Digit")
		d.frame = text[i].to_int() # Set digit sprite frames and visibility
		d.visible = pad or (i >= (digits - digit_count) if right_aligned else i < digit_count)
