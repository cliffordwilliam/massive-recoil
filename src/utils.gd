class_name Utils
extends RefCounted
## This class serves as a centralized collection of reusable utility functions
## that can be called statically without creating an instance.


## Use this to catch impossible or invalid states during runtime.
##
## By default crashes in both debug and release via [method OS.crash] — use this
## for programmer errors and broken-build conditions that should never occur in
## correct code.
##
## Pass [param crash] as [code]false[/code] only at external boundaries (e.g.
## save-file parsing) where a corrupt input should be logged and skipped rather
## than crashing the game.
static func require(valid_condition: bool, message: String, crash: bool = true) -> bool:
	if not valid_condition:
		if crash:
			OS.crash(message)
		else:
			push_error(message)
	return valid_condition


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
