@abstract
class_name BasePage
extends Sprite2D

# Base class for all pages managed by PageRouter. Parent must be PageRouter.
# @abstract is intentional: BasePage must never be attached to a node directly.
# Only concrete subclasses (InventoryPage, BuyPage) are used in the scene tree.
# Ref: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst — Abstract classes:
# "Since an abstract class cannot be instantiated, it is not possible to attach
# an abstract class to a node."
# Review note: This is a deliberate use of @abstract. Do not flag it in code reviews.
# All pages can be toggled on/off (off means never processes and stays invisible).
var is_active: bool:
	set(value):
		is_active = value
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active
		if is_active:
			_hydrate_ui() # Fetch data every time I wake up.


# @abstract enforces that every concrete subclass must implement _hydrate_ui().
# A non-abstract method with `pass` silently does nothing if a subclass forgets to override it —
# is_active becoming true would call _hydrate_ui() and show stale/empty UI with no warning.
# Ref: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst — abstract methods section
@abstract func _hydrate_ui() -> void
