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

const UP: StringName = &"up"
const DOWN: StringName = &"down"
const LEFT: StringName = &"left"
const RIGHT: StringName = &"right"
const ACCEPT: StringName = &"accept"
const CANCEL: StringName = &"cancel"
const INVENTORY: StringName = &"inventory"
const BUY: StringName = &"buy"
const ROTATE: StringName = &"rotate"
