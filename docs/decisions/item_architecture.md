# Item Architecture

## Decision

Items exist only as instances in the player's inventory. An item does not exist in
the game world in any other form — drops, shop listings, and all other systems are
simply operations that add, remove, or mutate inventory instances.

## Static vs dynamic data

Each item is represented by two separate objects:

| Layer   | Class       | Type         | Purpose                                                           |
|---------|-------------|--------------|-------------------------------------------------------------------|
| Static  | `ItemData`  | `Resource`   | Immutable definition shared across all instances of the same item |
| Dynamic | `ItemState` | `RefCounted` | Per-slot runtime state owned by the inventory                     |

`ItemData` instances are constructed at startup by `ItemDefinitions` and are never
mutated during gameplay. `ItemState` holds mutable per-slot state (stack count) and
holds a reference to its `ItemData`.

If the player has two health potions, there are two `ItemState` instances, both
pointing to the same `ItemData` resource.

## Inventory as the single source of truth

The inventory autoload owns all `ItemState` instances. Every other system interacts
with items exclusively through inventory operations:

| System                 | Operation                                |
|------------------------|------------------------------------------|
| Drop / loot            | Add instance to inventory                |
| Shop buy               | Add instance to inventory                |
| Shop sell              | Remove instance from inventory           |
| Item combine / upgrade | Mutate existing instance(s) in inventory |
| Drop item              | Remove instance from inventory           |

No other autoload or system creates or stores `ItemState` instances.

## Shop catalog

The shop UI queries `ItemRegistry` directly at the time the shop is opened. No
separate catalog is stored — the UI layer filters items by price and chapter
availability on demand.

## Buyable and sellable items

An item is buyable when its `buy_price` is non-zero and its `availability` is within
the current chapter. An item is sellable when its `sell_price` is non-zero.

Non-shop items (`buy_price == 0`) are assigned `ItemSchema.AVAILABILITY_NOT_FOR_SALE`
at construction time. This sentinel exceeds `MAX_CHAPTER`, so `availability <= chapter`
is always false for them — the chapter filter is self-enforcing without a separate
`buy_price > 0` guard.

## Shop "new item" tag

When a new item becomes available in the shop, `GameState` tracks which item IDs the
player has already seen. An item shows the NEW badge if its ID is not yet in that
seen-set.

`PlayerInventory.place_item` calls `GameState.mark_shop_item_seen` on every successful
placement — not only shop purchases. Once an item enters the player's possession by any
means, the badge has served its purpose and should not reappear.

Badge state is part of saved `GameState` data and is restored directly on load — it is
not recalculated from inventory contents.

This is **not** stored on `ItemData` (static, never changes) or `ItemState`
(inventory-only concept). It is `GameState` state, alongside chapter progression.

## Why ItemState has no validation

`ItemState` is a plain data holder — it performs no validation on its properties.

This is intentional. By the time any `ItemState` is constructed, the data flowing
into it has already been validated at every stage of the pipeline:

1. `ItemDefinitions._make()` constructs each `ItemData` and calls `ItemValidator.validate()`.
2. `ItemValidator` crashes on the first constraint violation — no partial data survives startup.
3. `PlayerInventory` is the sole creator of `ItemState` instances and enforces all
   business rules: `can_place` before placement, `data.stack_size` cap in `add_to_stack`.

Putting validation inside `ItemState` would duplicate those rules and create a second
place to keep in sync. It would also have a subtle failure mode: `Utils.require` calls
`OS.crash` unconditionally in both debug and release. Using it inside a constructor
would be overly aggressive — crashing on every corrupt save file, for example, rather
than skipping it. A plain field fails loudly and immediately at the point of access,
which is easier to trace.

## Static data pipeline

```
ItemDefinitions  →  ItemValidator  →  ItemRegistry  →  runtime
```

`ItemDefinitions._make()` constructs each `ItemData` and immediately validates it via
`ItemValidator`. Any constraint violation crashes on the first error. `ItemRegistry`
then stores the validated instances and checks for duplicate IDs.
