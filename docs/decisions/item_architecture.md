# Item Architecture

## Decision

Items exist only as instances in the player's inventory. An item does not exist in
the game world in any other form — drops, shop listings, and all other systems are
simply operations that add, remove, or mutate inventory instances.

## Static vs dynamic data

Each item is represented by two separate objects:

| Layer   | Class       | Type         | Purpose                                                           |
| ------- | ----------- | ------------ | ----------------------------------------------------------------- |
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
| ---------------------- | ---------------------------------------- |
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

The `buy_price` and `availability` fields are bidirectionally coupled:

- A non-shop item (`buy_price == 0`) **must** have `availability == AVAILABILITY_NOT_FOR_SALE`.
- A shop item (`buy_price != 0`) **must** have `availability` in `[MIN_CHAPTER, MAX_CHAPTER]`.

`ItemValidator` enforces both directions at startup — no silent correction is applied
at construction time. Passing the wrong combination crashes immediately.

`AVAILABILITY_NOT_FOR_SALE` exceeds `MAX_CHAPTER`, so `availability <= chapter`
is always false for non-shop items — the chapter filter is self-enforcing without a
separate `buy_price > 0` guard.

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

## Recipe system

Recipes are defined as static data in `RecipeDefinitions` and loaded at startup by
`RecipeRegistry`. Each recipe specifies exactly two ingredient item IDs and one result
item ID. All IDs are validated against `ItemRegistry` at startup — an unknown ID crashes
immediately.

Ingredient order does not matter: `RecipeRegistry` builds an order-independent lookup
key by sorting the two IDs alphabetically before joining them.

Combining an item with itself (both ingredients are the same ID) is explicitly
supported — for example, two key fragments combining into a complete key. There is no
constraint requiring the two ingredients to be distinct items.

`RecipeRegistry` detects duplicate recipes (same ingredient pair appearing more than
once) at startup and crashes if found.

## Error handling philosophy

When loading save data or validating static definitions, a hard crash is always
preferred over graceful degradation with partial or inconsistent state. Partial state
is harder to debug — the failure point is disconnected from the corrupted data, and
the program may continue to behave incorrectly in ways that are difficult to trace.

`Utils.require` calls `OS.crash` unconditionally in both debug and release builds.
Any constraint violation terminates immediately at the point of detection. No
defensive fallbacks, silent skips, or partial loads are used.

This also applies to save file loading: if saved data references an item ID that no
longer exists, the game crashes rather than silently skipping it. If items are removed
from the game after save files exist, the save data must be migrated or wiped.

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

## ItemData field invariants

All constraints are enforced by `ItemValidator` at startup — a violation crashes
immediately, so no invalid `ItemData` can survive into runtime. Bounds are defined
in `ItemSchema`.

| Field            | Constraint                                                                                                                       |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `id`             | `MIN_ID_LENGTH`–`MAX_ID_LENGTH` (1–32) chars; lowercase letters, digits, and underscores only; must start and end with a letter or digit (snake_case convention — see note below) |
| `ui_name`        | `MIN_NAME_LENGTH`–`MAX_NAME_LENGTH` (1–12) chars; free-form display text                                                         |
| `description`    | `MIN_DESCRIPTION_LENGTH`–`MAX_DESCRIPTION_LENGTH` (1–50) chars; free-form display text                                           |
| `buy_price`      | `MIN_PRICE`–`MAX_PRICE` (0–999999); `0` means not buyable                                                                        |
| `sell_price`     | `MIN_PRICE`–`MAX_PRICE` (0–999999); `0` means not sellable                                                                       |
| `stack_size`     | `MIN_STACK`–`MAX_STACK` (1–999)                                                                                                  |
| `availability`   | `MIN_CHAPTER`–`MAX_CHAPTER` (1–4) when `buy_price != 0`; otherwise `AVAILABILITY_NOT_FOR_SALE`                                   |
| `inventory_size` | Each axis `MIN_SIZE_DIM`–`MAX_SIZE_DIM` (1–8)                                                                                    |
| `ammo_type`      | Must be `NONE` for non-`WEAPON` types; any `AmmoType` value valid for `WEAPON`                                                   |

### id naming convention

`id` is a code-level identifier, not display text. It must follow snake_case:
lowercase letters, digits, and underscores only, starting and ending with a
letter or digit — no trailing underscore (e.g. `field_medkit`, `smg_ammo`).
This is a **hard constraint enforced by `ItemValidator`** — not just a style preference.

The restriction exists because `RecipeRegistry` builds order-independent lookup
keys by joining two ingredient IDs with a `|` separator. The snake_case
constraint guarantees no ID can ever contain `|`, making key collisions
impossible by construction.

This is distinct from `ui_name` and `description`, which are free-form display
strings and accept any non-empty text.

## ammo_type field ownership

`ammo_type` is a weapon-side field — it describes which ammo type a `WEAPON` consumes,
not what an `AMMO`-type item _is_. `ItemValidator` enforces that `ammo_type` must be
`NONE` on all non-`WEAPON` items, so `AMMO`-type items always carry `AmmoType.NONE`.

This means the ammo-to-weapon relationship is one-directional: the weapon declares what
it consumes; the ammo item carries no reference back to its compatible weapons. Pairing
is resolved at the point of use (e.g. a weapon fires, looks up its own `ammo_type`, and
finds the matching `AMMO` item in inventory by convention).

A `WEAPON` with `ammo_type == NONE` is valid and represents an infinite-ammo weapon.

## Static data pipeline

```
ItemDefinitions  →  ItemValidator  →  ItemRegistry  →  runtime
```

`ItemDefinitions._make()` constructs each `ItemData` and immediately validates it via
`ItemValidator`. Any constraint violation crashes on the first error. `ItemRegistry`
then stores the validated instances and checks for duplicate IDs.
