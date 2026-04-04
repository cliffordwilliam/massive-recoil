class_name Utils
extends RefCounted
## This class serves as a centralized collection of reusable utility functions
## that can be called statically without creating an instance.
## This is not an autoload — it has no singleton instance and is never
## registered in Project Settings.


## Returns [code]-1[/code], [code]0[/code], or [code]1[/code] depending on which of
## [param negative_action] and [param positive_action] are pressed in [param event].
## Mirrors [method Input.get_axis] for use in [method Node._unhandled_key_input] handlers.
static func get_axis(
	event: InputEvent, negative_action: StringName, positive_action: StringName
) -> int:
	return (
		int(event.is_action_pressed(positive_action))
		- int(event.is_action_pressed(negative_action))
	)


## Parses a JSON scalar as an integer.
##
## JSON parsers may return whole-number values as [float] rather than [int].
## Returns the value as an [int] if [param v] is an [int] or a [float] with no
## fractional part; otherwise returns [code]null[/code].
static func parse_json_int(v: Variant) -> Variant:
	if v is int:
		return v as int
	if v is float:
		var f: float = v as float
		if is_finite(f) and f == floor(f):
			return int(f)
	return null
