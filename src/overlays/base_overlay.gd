@abstract class_name BaseOverlay
extends Node2D
## Abstract base class for all full-screen overlays managed by [code]OverlayRouter[/code].
##
## Subclasses implement [method _on_open] to populate their UI. Activation is
## controlled entirely through [member is_active] — subclasses must not touch
## [member Node.process_mode] or [member CanvasItem.visible] directly.

## Controls whether this overlay is the currently displayed one.
##
## Setting [code]true[/code] makes the node visible, restores processing, and calls
## [method _on_open] so the UI always reflects current game state when it opens.
## Setting [code]false[/code] hides the node and disables all processing.
## Only [code]OverlayRouter[/code] should write this property.
var is_active: bool:
	set(value):
		var was_active: bool = is_active
		is_active = value
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active
		if is_active:
			_on_open()
		elif was_active:
			_on_close()

## Called every time this overlay becomes active. Populate or refresh UI contents here.
## [member Node.visible] and [member Node.process_mode] are set before this is called,
## so layout calculations that depend on visibility are safe to perform here.
@abstract func _on_open() -> void

## Called every time this overlay transitions from active to inactive.
## Not called during initial setup — only on a true close.
## Use this to reset state machines or clear selection state before the next open.
@abstract func _on_close() -> void
