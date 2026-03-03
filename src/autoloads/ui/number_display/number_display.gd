class_name NumberDisplay
extends Node2D

# The only thing that renders number using sprites, this game only renders positive numbers
@export var digit_scene: PackedScene # Set via engine GUI
@export var right_aligned: bool = false
@export var pad: bool = false
@export var digits: int = 6


func _ready() -> void:
	assert(digit_scene, "NumberDisplay: digit_scene must be set in the inspector")
	# Given that x is the top left NumberDisplay origin, we can render either like this
	# 123x = this is right aligned
	# x123
	# Regardless of which one we always add digit sprite from left to right
	for i in range(digits):
		var d: Digit = digit_scene.instantiate()
		add_child(d)
		d.initialize(-(digits - i) if right_aligned else i)


func display_number(number: int) -> void:
	# Number is truncated to fit available digit sprites
	# With 3 digit sprites, input 12000 is truncated to 120
	number = clampi(number, 0, int(pow(10, digits)) - 1)

	# If number is 15 then count is 2
	var raw: String = str(number)
	var digit_count: int = raw.length()

	# Pad number input to match available digit sprites
	# Given that we have 3 digit sprites, then we pad 15 to be 015 (right aligned) or 150
	var text: String = raw.lpad(digits, "0") if right_aligned else raw.rpad(digits, "0")

	# Since both padded number and sprites matches in size, we iter them to flip frame correctly
	for i in get_child_count():
		var d: Digit = get_child(i)
		assert(d is Digit, "NumberDisplay: all children must be Digit")

		# Set digit sprite frames and visibility
		d.frame = text[i].to_int()
		d.visible = pad or (i >= (digits - digit_count) if right_aligned else i < digit_count)
