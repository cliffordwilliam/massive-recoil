class_name InputActions
extends RefCounted
## Input Map action name constants.
##
## Centralises all action [StringName] literals so a rename in Project Settings
## requires only one edit here rather than a grep across every [method InputEvent.is_action_pressed]
## call site.
##
## Use [constant StringName] literals ([code]&"..."[/code]) — action names are compared on every
## input event so [StringName] avoids repeated [String] → [StringName] conversion at runtime.
## See: "res://docs/godot/how_to_use_string_name.md"

## Move cursor or selection up.
const UP: StringName = &"up"
## Move cursor or selection down.
const DOWN: StringName = &"down"
## Move cursor or selection left.
const LEFT: StringName = &"left"
## Move cursor or selection right.
const RIGHT: StringName = &"right"
## Confirm / interact.
const ACCEPT: StringName = &"accept"
## Close the current overlay or cancel the current action.
const CANCEL: StringName = &"cancel"
## Open the inventory overlay.
const INVENTORY: StringName = &"inventory"
## Open the shop overlay.
const BUY: StringName = &"buy"
## Rotate the held item in Move state.
const ROTATE: StringName = &"rotate"
