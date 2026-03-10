@tool
class_name SpriteNumber
extends Node2D
## SpriteNumber is a Node2D responsible for rendering a positive integer
## using a fixed number of sprite-based digit nodes. It instantiates a
## configurable number of Digit scenes and arranges them horizontally,
## optionally supporting right-aligned numbers and zero padding.
##
## The node clamps input numbers to the maximum value representable by the
## configured digit count, converts the number into text, and updates each
## child Digit's frame to display the correct numeral. Digits that are not
## part of the number can be hidden or shown depending on the padding setting.
##
## This allows numbers such as scores, timers, or counters to be displayed
## using sprite sheets instead of fonts, similar to mechanical or scoreboard
## style number displays.

## The digit scene used to render each number.
@export var digit_scene: PackedScene:
	set(value):
		digit_scene = value
		update_configuration_warnings()

## If true, the rendered number will be right-aligned.
@export var is_right_aligned: bool = false

## If true, the number will be padded with leading zeros.
@export var pad_with_zeros: bool = false

## Maximum number of digit sprites used to render the number.
@export var digits: int = 6


## Checks if digit_scene is assigned and if digits is valid,
## returning messages that show up in the Scene dock
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if not digit_scene:
		warnings.append("SpriteNumber: 'digit_scene' must be assigned.")
	if digits <= 0:
		warnings.append("SpriteNumber: 'digits' must be greater than 0.")
	return warnings


func _ready() -> void:
	if not (
		Utils
		. require(
			digit_scene != null,
			"SpriteNumber: 'digit_scene' must be set in the inspector.",
		)
	):
		return

	for i: int in range(digits):
		var digit: Digit = digit_scene.instantiate()
		add_child(digit)
		digit.initialize(-(digits - i) if is_right_aligned else i)


# TODO: Use this in a setter instead, so we abstract away by just having other set my 'value'
# Use a setter abstract away cognitive load to just set its value and it renders
# Do make the value be private, always need to use the setter/getter
func set_number(_number: int) -> void:
	if not (
		Utils
		. require(
			get_child_count() > 0,
			"SpriteNumber: no digit children — digit_scene was not set in the inspector",
		)
	):
		return
