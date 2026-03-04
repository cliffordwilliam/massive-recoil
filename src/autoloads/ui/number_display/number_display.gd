# The only node that renders numbers using sprites. This game only renders positive numbers.
class_name NumberDisplay
extends Node2D

@export var digit_scene: PackedScene # Set via engine GUI
@export var right_aligned: bool = false
@export var pad: bool = false
@export var digits: int = 6


func _ready() -> void:
	# assert() fires only in debug/editor builds and is completely stripped in exported builds.
	# push_error() always fires, ensuring this misconfiguration is caught in all builds.
	# Ref: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst
	# — "assertions are ignored in non-debug builds"
	assert(digit_scene, "NumberDisplay: digit_scene must be set in the inspector")
	if not digit_scene:
		push_error("NumberDisplay: digit_scene must be set in the inspector")
		return
	# Given that x is the top‑left NumberDisplay origin, we can render either like this:
	# 123x = this is right‑aligned
	# x123
	# In both cases we always add digit sprites from left to right.
	for i in range(digits):
		var d: Digit = digit_scene.instantiate()
		add_child(d)
		d.initialize(-(digits - i) if right_aligned else i)


func display_number(number: int) -> void:
	# The number is truncated to fit the available digit sprites.
	# With 3 digit sprites, input 12000 is truncated to 120.
	number = clampi(number, 0, int(pow(10, digits)) - 1)

	# If the number is 15 then digit_count is 2.
	var raw: String = str(number)
	var digit_count: int = raw.length()

	# Pad the number input to match the available digit sprites.
	# Given that we have 3 digit sprites, we pad 15 to be 015 (right‑aligned) or 150.
	var text: String = raw.lpad(digits, "0") if right_aligned else raw.rpad(digits, "0")

	# Since both the padded number and sprites match in size, we iterate over them to set frames correctly.
	for i in get_child_count():
		var d: Digit = get_child(i)
		# assert() fires only in debug/editor builds — see _ready() comment for full context.
		assert(d is Digit, "NumberDisplay: all children must be Digit")
		if not d is Digit:
			push_error("NumberDisplay: all children must be Digit")
			continue

		# Set digit sprite frames and visibility
		d.frame = text[i].to_int()
		d.visible = pad or (i >= (digits - digit_count) if right_aligned else i < digit_count)
