class_name Utils
extends RefCounted
## This class serves as a centralized collection of reusable utility functions
## that can be called statically without creating an instance.


## Crashes via [method OS.crash] if [param valid_condition] is false.
##
## Use this to catch impossible or invalid states during runtime — programmer
## errors and broken-build conditions that should never occur in correct code.
static func require(valid_condition: bool, message: String) -> void:
	if not valid_condition:
		OS.crash(message)


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
