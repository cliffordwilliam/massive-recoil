@abstract class_name BaseOverlay
extends Node2D
## Abstract base class for all full-screen overlays managed by [code]OverlayRouter[/code].
##
## Subclasses implement [method _hydrate_ui] to populate their UI. Activation is
## controlled entirely through [member is_active] — subclasses must not touch
## [member Node.process_mode] or [member CanvasItem.visible] directly.
##
## See: "res://docs/decisions/overlay_router.md"

## Controls whether this overlay is the currently displayed one.
##
## Setting [code]true[/code] makes the node visible, restores processing, and calls
## [method _hydrate_ui] so the UI always reflects current game state when it opens.
## Setting [code]false[/code] hides the node and disables all processing.
## Only [code]OverlayRouter[/code] should write this property.
var is_active: bool:
	set(value):
		# Godot 4 GDScript detects self-assignment within a setter and writes
		# directly to the backing store — this does NOT cause infinite recursion.
		# See: "res://docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md"
		is_active = value
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active
		if is_active:
			_hydrate_ui()

## Called every time this overlay becomes active. Populate or refresh UI contents here.
## [member Node.visible] and [member Node.process_mode] are set before this is called,
## so layout calculations that depend on visibility are safe to perform here.
@abstract func _hydrate_ui() -> void
