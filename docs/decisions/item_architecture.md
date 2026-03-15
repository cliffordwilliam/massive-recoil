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

`ItemData` resources are generated from `items.json` by the editor script and loaded
at runtime. They are never mutated during gameplay. `ItemState` holds mutable per-slot
state (stack count) and holds a reference to its `ItemData`.

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

The shop autoload holds a list of `ItemData` references — the items available for
purchase at the current point in the game. It does not own `ItemState` instances.

An item is sellable when its `sell_price` is non-zero. Items with `sell_price == 0`
cannot be sold to the merchant. The same logic applies to buying: `buy_price == 0`
means the item is not available for purchase.

Non-shop items (`buy_price == 0`) are assigned `ItemSchema.AVAILABILITY_NOT_FOR_SALE`
by `generate_item_resources.gd` at generation time, regardless of the JSON value.
This sentinel exceeds `MAX_CHAPTER`, so `availability <= chapter` is always false for
them — shop filters do not need a separate `buy_price > 0` guard to exclude them.

## Shop "new item" tag

When a new item becomes available in the shop (based on chapter and `availability`),
`GameState` tracks which item IDs the player has already seen. An item shows
the NEW badge if its ID is not yet in that seen-set.

`PlayerInventory.place_item` calls `GameState.mark_shop_item_seen` on every
successful placement — not only shop purchases. Once an item enters the player's
possession by any means (shop buy, drop, loot), the badge has served its purpose
and should not reappear. `load_save` passes `mark_seen = false` to `place_item`
so that reloading a save does not affect the seen-set: the badge state is already
reflected in the saved `GameState` data.

This is **not** stored on `ItemData` (static, never changes) or `ItemState`
(inventory-only concept). It is `GameState` state, alongside other global runtime
data such as chapter progression.

## Why ItemState has no validation

`ItemState` is a plain data holder — it performs no validation on its properties.

This is intentional. By the time any `ItemState` is constructed, the data flowing
into it has already been validated at every stage of the pipeline:

1. `generate_item_resources.gd` validates every JSON entry before writing any `.tres` file.
2. `ItemRegistry` guards against missing or malformed resources at load time.
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
items.json  →  generate_item_resources.gd  →  .tres files  →  loaded at runtime
```

The editor script validates every entry before writing any file. If any item fails
validation, no files are written and all errors are reported. This prevents partial
output from leaving the project in a broken state.
