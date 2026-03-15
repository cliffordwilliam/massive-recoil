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
##   [method create_snapshot] builds a detached copy for read-only UI; copies are never in
##   [member PlayerInventory._slots] and must not be passed into any mutation method.
## [br]
## Adding validation here would be redundant and would create a second place to keep
## in sync with those rules. If invalid data somehow reaches this class, the failure
## will surface at the point of access — which is clear and close to the root cause.
##
## For more info, please read: "res://docs/decisions/item_architecture.md"

## Static template describing the item. Write-once — crashes on reassignment.
var data: ItemData:
	set(value):
		Utils.require(
			data == null, "ItemState.data: write-once — cannot reassign after initial set"
		)
		data = value

## Grid position of this item's top-left corner in the inventory.
##
## [b]Always set by [code]PlayerInventory[/code] immediately after construction,[/b]
## before the slot is appended to [member PlayerInventory._slots]. The sentinel
## [code]Vector2i(-1, -1)[/code] is never a valid grid position — a slot in
## [code]_slots[/code] always has an explicitly assigned position.
##
## Guarded against mutation on snapshots. [method create_snapshot] assigns
## this field before setting [member is_snapshot], so construction is unaffected.
var position: Vector2i = Vector2i(-1, -1):
	set(value):
		# Snapshots are read-only copies for UI consumption. Mutating one has no
		# effect on the live slot in PlayerInventory._slots, so any write is a
		# silent state divergence rather than a real update. Crash here to surface
		# the bug immediately rather than let it corrupt UI state quietly.
		Utils.require(
			not is_snapshot,
			"ItemState.position: snapshot is read-only — do not mutate a detached copy"
		)
		position = value

## Number of stacks this item occupies. E.g. ammo may have 25.
## Floor is [constant ItemSchema.MIN_STACK], enforced by the JSON validator in
## [code]generate_item_resources.gd[/code] and by [code]PlayerInventory[/code].
## Cap is [member ItemData.stack_size], enforced by [code]PlayerInventory[/code].
##
## Guarded against mutation on snapshots. [method create_snapshot] assigns
## this field before setting [member is_snapshot], so construction is unaffected.
var stack_count: int = 1:
	set(value):
		# Same reasoning as the position setter: writing to a snapshot has no effect
		# on the live slot, so the write is always a bug. Crash to catch it early.
		Utils.require(
			not is_snapshot,
			"ItemState.stack_count: snapshot is read-only — do not mutate a detached copy"
		)
		stack_count = value

## Whether this instance is a detached snapshot produced by [method create_snapshot].
##
## Live slots in [member PlayerInventory._slots] always have this as [code]false[/code].
## Snapshots always have this as [code]true[/code]. Used by [method UIShopItemList.set_sell_items]
## to enforce the architecture contract that the UI never receives live slot references.
##
## One-way — can only transition from [code]false[/code] to [code]true[/code].
## Crashes on any attempt to set it once it is already [code]true[/code], since
## it makes no sense to un-snapshot an instance. Set only by [method create_snapshot]
## on the detached copy it produces.
##
## [b]Note on false→false:[/b] The guard checks the current value, not the incoming
## value — [code]is_snapshot = false[/code] passes silently when already [code]false[/code].
## This is intentional. Re-assigning [code]false[/code] is a no-op and harmless; the
## contract only needs to block [code]true → false[/code] (un-snapshotting), which it does.
## Do not add a [code]value == true[/code] check — it would reject the only assignment that matters.
var is_snapshot: bool = false:
	set(value):
		Utils.require(
			not is_snapshot, "ItemState.is_snapshot: one-way — already marked as snapshot"
		)
		is_snapshot = value


## Returns a detached copy of this slot for read-only use by the UI.
##
## [b]Allocates a new [ItemState] on every call.[/b] Use a local variable if you
## need the snapshot more than once — do not call this method multiple times for
## the same snapshot.
## [br][br]
## [b]This copy is not owned by [code]PlayerInventory[/code].[/b] It reflects the
## state at the moment of the call and will not update if the original slot later changes.
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
func create_snapshot() -> ItemState:
	# Crash if data is null — do not silently return a broken copy.
	# In practice this path is unreachable: every slot in PlayerInventory._slots is
	# constructed by _append_slot, which only accepts data from ItemRegistry.get_item —
	# a null there would have already crashed at that call site. The guard is kept as
	# belt-and-suspenders to catch any future code path that constructs an ItemState
	# outside PlayerInventory without going through the validated pipeline.
	Utils.require(
		data != null,
		"ItemState.create_snapshot: data is null — slot was not constructed through PlayerInventory"
	)
	var copy: ItemState = ItemState.new(data)
	copy.position = position
	copy.stack_count = stack_count
	# Mark the copy as a snapshot so callers such as UIShopItemList.set_sell_items
	# can enforce the contract that only detached copies — never live slot references
	# from PlayerInventory._slots — enter the UI layer.
	copy.is_snapshot = true
	return copy


func _init(template: ItemData) -> void:
	# No null guard here — this is intentional, not an oversight.
	# Validation is the pipeline's responsibility (ItemRegistry at load time,
	# PlayerInventory at placement time), not ItemState's. Adding a guard here
	# would duplicate those rules and create a second place to keep in sync.
	# create_snapshot crashes on null via Utils.require instead of returning null,
	# so broken state is surfaced at the point of snapshot creation — the nearest
	# boundary where the symptom is clearly tied to the cause.
	# See class docstring and snapshot getter for full rationale.
	data = template
