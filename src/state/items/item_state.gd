class_name ItemState
extends RefCounted
## Dynamic state for a single item instance.
##
## References an [ItemData] resource that defines the item's static data.
##
## [b]No validation is performed here.[/b] [code]PlayerInventory[/code] is the sole
## creator of live [ItemState] instances and enforces all business rules.
##
## [method create_snapshot] produces a detached read-only copy for UI consumption;
## snapshots are never in [member PlayerInventory._slots] and must not be passed to
## any mutation method.
##
## [b]Convention:[/b] every mutable field added to this class must include its own
## snapshot guard (checking [member is_snapshot]) and must be copied in [method create_snapshot].
##
## See: "res://docs/decisions/item_architecture.md"

## Whether this instance is a detached snapshot produced by [method create_snapshot].
##
## Live slots always have this as [code]false[/code]; snapshots always [code]true[/code].
## Write-once — only the [code]false → true[/code] transition is allowed, exactly once.
var is_snapshot: bool = false:
	set(value):
		(
			Utils
			. require(
				not is_snapshot and value,
				"ItemState.is_snapshot: write-once — can only transition from false to true",
			)
		)
		is_snapshot = value

## Static template describing the item.
##
## Write-once — crashes if [param value] is [code]null[/code] or if [member data]
## has already been set. Only the [code]null → non-null[/code] transition is allowed.
## No snapshot guard needed — write-once already prevents reassignment on both
## live slots and snapshots.
var data: ItemData = null:
	set(value):
		(
			Utils
			. require(
				data == null and value != null,
				"ItemState.data: write-once — value must be non-null and cannot be reassigned",
			)
		)
		data = value

## Grid position of this item's top-left corner in the inventory.
##
## [b]Always set by [code]PlayerInventory[/code] at construction via [method _init].[/b]
## The sentinel [code]Vector2i(-1, -1)[/code] is never a valid grid position — a slot in
## [code]_slots[/code] always has an explicitly assigned position.
##
## Guarded against mutation on snapshots. Safe to set in [method _init] because
## [member is_snapshot] is always [code]false[/code] on a freshly allocated object.
var position: Vector2i = Vector2i(-1, -1):
	set(value):
		# Guard against mutating a snapshot: writing position here would not update
		# the live slot in PlayerInventory._slots — it would silently diverge from it.
		(
			Utils
			. require(
				not is_snapshot,
				"ItemState.position: snapshot is read-only — do not mutate a detached copy",
			)
		)
		position = value

## Number of stacks this item occupies. E.g. ammo may have 25.
## Floor is [constant ItemSchema.MIN_STACK], cap is [member ItemData.stack_size];
## both enforced by [code]PlayerInventory[/code].
##
## Guarded against mutation on snapshots. Safe to set in [method _init] because
## [member is_snapshot] is always [code]false[/code] on a freshly allocated object.
var stack_count: int = ItemSchema.MIN_STACK:
	set(value):
		# Same reasoning as the position setter.
		(
			Utils
			. require(
				not is_snapshot,
				"ItemState.stack_count: snapshot is read-only — do not mutate a detached copy",
			)
		)
		stack_count = value

## Runtime stat state for weapon items. [code]null[/code] for all
## non-[constant ItemData.Type.WEAPON] items. Set by [code]PlayerInventory[/code]
## at construction via [method _init].
##
## For weapon items: write-once — the setter requires a non-[code]null[/code] value and
## crashes if called more than once. Only the [code]null → non-null[/code] transition is allowed.
## For non-weapon items: the setter is never called — the field stays at its default
## [code]null[/code] without passing through the setter at all.
## No snapshot guard needed — write-once already prevents reassignment on both
## live slots and snapshots.
var weapon_stats_state: WeaponStatsState = null:
	set(value):
		(
			Utils
			. require(
				weapon_stats_state == null and value != null,
				"ItemState.weapon_stats_state: write-once — value must be non-null and cannot be reassigned",
			)
		)
		weapon_stats_state = value


## Initialises all fields atomically — no gap between allocation and first use.
##
## [param p_weapon_stats] is [code]null[/code] for non-[constant ItemData.Type.WEAPON]
## items and non-[code]null[/code] for weapons. Setters are safe at construction time
## because [member is_snapshot] is always [code]false[/code] when [method _init] runs.
## Godot initialises property default values directly in the backing store — bypassing
## the setter — so [member is_snapshot] starts at [code]false[/code] without triggering
## its write-once guard. The snapshot guards on [member position] and
## [member stack_count] then pass because [member is_snapshot] is [code]false[/code].
func _init(
	p_data: ItemData,
	p_position: Vector2i,
	p_count: int,
	p_weapon_stats: WeaponStatsState = null,
) -> void:
	data = p_data
	position = p_position
	stack_count = p_count
	if p_weapon_stats != null:
		weapon_stats_state = p_weapon_stats


## Returns a detached copy of this slot for read-only use by the UI.
##
## The copy reflects state at the moment of the call and will not update if the
## original slot changes. [member position] is preserved so the UI can locate the
## original slot (e.g. [code]PlayerInventory.remove_item_at(snapshot.position)[/code]).
## [member data] is shared (immutable [Resource]). [member is_snapshot] is [code]true[/code]
## on the copy so call sites can assert the live-vs-snapshot contract at runtime.
##
## [b]Allocates a new [ItemState] on every call[/b] — use a local variable if you
## need the snapshot more than once.
func create_snapshot() -> ItemState:
	Utils.require(
		not is_snapshot,
		(
			"ItemState.create_snapshot: cannot snapshot a snapshot — only live slots may "
			+ "produce snapshots"
		)
	)
	Utils.require(
		data != null,
		"ItemState.create_snapshot: data is null — live slot was never properly initialized"
	)

	var weapon_stats_copy: WeaponStatsState = null
	if weapon_stats_state != null:
		weapon_stats_copy = weapon_stats_state.create_snapshot()
	var copy: ItemState = ItemState.new(data, position, stack_count, weapon_stats_copy)
	copy.is_snapshot = true

	return copy
