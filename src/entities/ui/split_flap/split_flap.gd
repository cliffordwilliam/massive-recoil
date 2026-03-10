@icon("res://assets/images/static/icons/scoreboard_24dp_8DA5F3_FILL0_wght400_GRAD0_opsz24.svg")
@tool
class_name SplitFlap
extends Node2D
## SplitFlap renders integer numbers using pre-placed Sprite2D nodes.
## It simulates a physical split-flap display with a fixed maximum number of digits (8 by default).
## The display can be right- or left-aligned and can optionally pad numbers with leading zeros.

## The total number of digit slots in this display.
const _SIZE: int = 8

## The maximum number that can be displayed.
const _MAX_NUMBER: int = 99999999

## Determines whether digits are right-aligned within the display.
## If false, digits are left-aligned.
@export var is_right_aligned: bool = false:
	set(value):
		is_right_aligned = value
		_update_digits()

## If true, numbers smaller than the pad length are displayed with leading zeros.
@export var pad_with_zeros: bool = false:
	set(value):
		pad_with_zeros = value
		_update_digits()

## The minimum number of digits to display when `pad_with_zeros` is true.
## Value is clamped between 0 and the total number of digit slots (`_SIZE`).
@export_range(0, _SIZE, 1, "suffix:digits") var pad_length: int = 3:
	set(value):
		pad_length = clampi(value, 0, _SIZE)
		_update_digits()

## The integer currently displayed on the split-flap.
## Automatically clamped between 0 and `_MAX_NUMBER`.
@export_range(0, _MAX_NUMBER) var number: int = 150:
	get:
		return _number
	set(value):
		_number = clampi(value, 0, _MAX_NUMBER)
		_update_digits()

## Internal storage of the current number.
var _number: int = 0

## Array of pre-placed Sprite2D nodes representing each digit slot.
@onready var _digits: Array = [$D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8]


## Updates all digit sprites to reflect the current number, alignment, and padding options.
##
## This function:
## - Sets each Sprite2D to show the correct digit (0–9).
## - Adjusts visibility based on alignment and padding rules.
func _update_digits() -> void:
	var raw: String = str(_number)
	var digit_count: int = raw.length()

	# Pad the string to the full display size to align digits with Sprite nodes.
	var text: String = raw.lpad(_SIZE, "0") if is_right_aligned else raw.rpad(_SIZE, "0")

	# Determine how many digits should be visible.
	var visible_count: int = digit_count
	if pad_with_zeros:
		visible_count = max(digit_count, pad_length)

	for i: int in range(_SIZE):
		var digit: Sprite2D = _digits[i]

		# Update the digit's frame to match the corresponding character.
		digit.frame = text[i].to_int()

		# Determine visibility based on alignment.
		var is_in_visible_range: bool = false

		if is_right_aligned:
			# For right-aligned numbers, visible digits are at the end of the array.
			is_in_visible_range = i >= (_SIZE - visible_count)
		else:
			# For left-aligned numbers, visible digits are at the start of the array.
			is_in_visible_range = i < visible_count

		digit.visible = is_in_visible_range
