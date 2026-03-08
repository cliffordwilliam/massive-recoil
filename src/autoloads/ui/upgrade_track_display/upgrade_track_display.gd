# The only node that renders weapon upgrade track using sprites.
class_name UpgradeTrackDisplay
extends Node2D

const MAX_SLOTS: int = 22 # There are only space enough to render 22 slots.
const GAP: int = 1 # Gaps between upgrade slots

@export var upgrade_slot_scene: PackedScene # Set via engine GUI.


func display_track(data: UpgradeListData) -> void:
	if not Utils.require(
		upgrade_slot_scene != null,
		"UpgradeTrackDisplay: upgrade_slot_scene must be set in the inspector",
	):
		return
	clear_previous_slots()
	# Given that x is the top‑left NumberDisplay origin, s are upgrade slots, we render like this:
	# xsss
	# We always add upgrade slot sprites from left to right.
	# There are only 22 "s" we can render, since we do not have enough space for more.
	for i in range(mini(data.items.size(), MAX_SLOTS)):
		var slot: UpgradeSlot = upgrade_slot_scene.instantiate()
		add_child(slot)
		slot.position.x = i * (slot.get_width() + GAP)
		if i <= data.index:
			slot.show_bright()
		else:
			slot.show_dim()


func clear_previous_slots() -> void:
	# get_children() returns an Array snapshot — iterating while calling remove_child() is safe.
	# Doc ref: docs/godot/classes/class_node.rst — get_children():
	# "Returns all children of this node inside an Array."
	# remove_child() is called before queue_free() so the node is immediately
	# detached from the tree. queue_free() alone would leave the child counted
	# until end-of-frame; since display_track() re-populates children in the
	# same frame, any get_child_count() read between clear and populate would
	# see stale entries.
	for child in get_children():
		remove_child(child)
		child.queue_free()
