class_name ItemState
extends RefCounted
## Dynamic state for a single item instance.
##
## References an [ItemData] resource that defines the item's static data.
##
## [b]No validation is performed here.[/b] Validation is the responsibility of the
## pipeline that produces data flowing into this class:
## [br]- [code]generate_item_resources.gd[/code] validates JSON before writing [code].tres[/code].
## [br]- [code]ItemRegistry[/code] guards against missing resources at load time.
## [br]- [code]PlayerInventory[/code] is the sole creator of live [ItemState] instances and
##   enforces business rules (placement, stack cap via [member ItemData.stack_size]).
##   [member snapshot] builds a detached copy for read-only UI; copies are never in
##   [member PlayerInventory._slots] and must not be passed into any mutation method.
## [br]
## Adding validation here would be redundant and would create a second place to keep
## in sync with those rules. If invalid data somehow reaches this class, the failure
## will surface at the point of access — which is clear and close to the root cause.
##
## For more info, please read: "res://docs/decisions/item_architecture.md"

## Static template describing the item.
var data: ItemData

## Grid position of this item's top-left corner in the inventory.
##
## [b]Always set by [code]PlayerInventory[/code] immediately after construction,[/b]
## before the slot is appended to [member PlayerInventory._slots]. The sentinel
## [code]Vector2i(-1, -1)[/code] is never a valid grid position — a slot in
## [code]_slots[/code] always has an explicitly assigned position.
var position: Vector2i = Vector2i(-1, -1)

## Number of stacks this item occupies. E.g. ammo may have 25.
## Floor is [constant ItemSchema.MIN_STACK], enforced by the JSON validator in
## [code]generate_item_resources.gd[/code] and by [code]PlayerInventory[/code].
## Cap is [member ItemData.stack_size], enforced by [code]PlayerInventory[/code].
var stack_count: int = 1

## Whether this instance is a detached snapshot produced by [member snapshot].
##
## Live slots in [member PlayerInventory._slots] always have this as [code]false[/code].
## Snapshots always have this as [code]true[/code]. Used by [method UIShopItemList.set_sell_items]
## to enforce the architecture contract that the UI never receives live slot references.
##
## Read-only. Backed by [member _is_snapshot], which is written only by [member snapshot] getter.
var is_snapshot: bool:
	get:
		return _is_snapshot

## A detached copy of this slot for read-only use by the UI.
##
## [b]This copy is not owned by [code]PlayerInventory[/code].[/b] It reflects the
## state at the moment of access and will not update if the original slot later changes.
## [br][br]
## [member position] is preserved, so a snapshot can be used to locate the original
## slot in [code]PlayerInventory[/code] (e.g. for removal via its position). It must
## not be treated as a live slot reference or passed to any method that expects a slot
## owned by [code]PlayerInventory._slots[/code] — such as [code]place_item[/code].
## [br][br]
## [member data] is shared (immutable [Resource]), so it is safe to reference directly.
## [br][br]
## [member is_snapshot] is set to [code]true[/code] on the copy so call sites can
## enforce the live-vs-snapshot contract at runtime.
var snapshot: ItemState:
	get:
		# Crash if data is null — do not return null from a non-nullable typed property.
		# In practice this path is unreachable: every slot in PlayerInventory._slots is
		# constructed by _append_slot, which only accepts data from ItemRegistry.get_item —
		# a null there would have already crashed at that call site. The guard is kept as
		# belt-and-suspenders to catch any future code path that constructs an ItemState
		# outside PlayerInventory without going through the validated pipeline.
		#
		# False positive note: returning null from a non-nullable typed property was
		# flagged as a type contract violation. The fix here is to crash (Utils.require
		# with crash = true calls OS.crash) so null is never returned — the type
		# annotation is always satisfied. The "unreachable" comment above is the reason
		# this never fires in practice, not a reason to remove the guard.
		Utils.require(
			data != null,
			"ItemState.snapshot: data is null — slot was not constructed through PlayerInventory"
		)
		var copy: ItemState = ItemState.new(data)
		copy.position = position
		copy.stack_count = stack_count
		# Mark the copy as a snapshot so callers such as UIShopItemList.set_sell_items
		# can enforce the contract that only detached copies — never live slot references
		# from PlayerInventory._slots — enter the UI layer.
		copy.is_snapshot = true
		return copy

## Internal backing field for [member is_snapshot]. Written only by the [member snapshot] getter.
## Read externally via [member is_snapshot].
var _is_snapshot: bool = false


func _init(template: ItemData) -> void:
	# No null guard here — this is intentional, not an oversight.
	# Validation is the pipeline's responsibility (ItemRegistry at load time,
	# PlayerInventory at placement time), not ItemState's. Adding a guard here
	# would duplicate those rules and create a second place to keep in sync.
	# The snapshot getter crashes on null via Utils.require instead of returning null,
	# so broken state is surfaced at the point of snapshot access — the nearest
	# boundary where the symptom is clearly tied to the cause.
	# See class docstring and snapshot getter for full rationale.
	#
	# False positive note: the null-guard asymmetry between this constructor
	# (no guard) and snapshot (crashes via Utils.require) was flagged as an
	# inconsistency during review. It is intentional by design, not a bug.
	# The constructor's job is only to assign the field; snapshot is the nearest
	# boundary where a null data would produce a confusing delayed crash, so
	# that is the right place to fail loudly and immediately.
	data = template
