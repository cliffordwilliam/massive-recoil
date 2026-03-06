# General-purpose static utilities.
# Extends RefCounted — no Node lifecycle API needed.
class_name Utils
extends RefCounted


# Validates a condition in both debug and release builds.
# - assert() fires only in debug; strips from release exports.
# - push_error() always fires, so misconfiguration is caught in all builds.
# Returns true if the condition holds, false otherwise.
# Callers should early-return on false.
# Ref: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst — Assert keyword section.
static func require(condition: bool, message: String) -> bool:
	assert(condition, message)
	if not condition:
		push_error(message)
		return false
	return true
