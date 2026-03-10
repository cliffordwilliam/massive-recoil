class_name Utils
extends RefCounted
## This class serves as a centralized collection of reusable utility functions
## that can be called statically without creating an instance.


## Ensures a condition is true, logging an error if it fails.
## Use this to catch impossible or invalid states during runtime.
static func require(condition: bool, message: String) -> bool:
	assert(condition, message)
	if not condition:
		push_error(message)
		return false
	return true
