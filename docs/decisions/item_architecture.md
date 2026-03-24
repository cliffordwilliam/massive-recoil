# Item Architecture

## Decision

Items exist only as instances in the player's inventory. An item does not exist in
the game world in any other form — drops, shop listings, and all other systems are
simply operations that add, remove, or mutate inventory instances.

## What "slot" means in this codebase

A **slot** is one placed item instance in the inventory grid. It is not a single grid
cell — an item can span multiple cells depending on its `inventory_size`. The word slot
refers to the item as a whole: its position, its stack count, and (for weapons) its stat
state. This is the meaning used throughout the code (`_slots`, `get_slots()`,
`get_slot_at()`, `_append_slot()`) and all documentation.

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
placement of a **buyable item** (`buy_price > 0`) — not only shop purchases. Once a
buyable item enters the player's possession by any means, the badge has served its purpose
and should not reappear. Non-buyable items are never added to the seen-set because the
NEW badge is a shop-only concept.

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

`RecipeRegistry` enforces two uniqueness constraints at startup and crashes if either
is violated:

- **Result IDs must be unique** — no two recipes may produce the same item.
- **Ingredient pairs must be unique** — the same pair of ingredients may not appear in
  more than one recipe.

All three items in a recipe — both ingredients and the result — must have identical
`inventory_size`. `RecipeRegistry` enforces this at startup and crashes immediately on
any violation. This guarantees that after both ingredients are removed from the
inventory, the result is always placeable at the target ingredient's former grid
position without a scan.

## Drop-action exclusivity

When one item is dropped onto another in the inventory, exactly one of three outcomes
can occur:

| Outcome        | Condition                                                                                 |
| -------------- | ----------------------------------------------------------------------------------------- |
| Stack merge    | Both items share the same `ItemData` and the item is stackable (`stack_size > MIN_STACK`) |
| Weapon upgrade | Dropped item is type `WEAPON_UPGRADE` and target is type `WEAPON`                         |
| Recipe combine | The two item IDs match a recipe in `RecipeRegistry`                                       |

These outcomes must be **mutually exclusive**. An item that qualifies for more than one
creates unresolvable ambiguity in the UI — there is no priority rule, so the conflict is
treated as a data error and caught at startup.

The constraint is enforced in two places:

- **`ItemValidator`** (runs at startup before `RecipeRegistry` exists):
  A `WEAPON_UPGRADE` item must have `stack_size == MIN_STACK`. This prevents the
  upgrade + stack conflict.

- **`RecipeRegistry`** (runs after `ItemRegistry` is ready):
  Each recipe ingredient must not be stackable (`stack_size > MIN_STACK`) and must not
  be type `WEAPON_UPGRADE`. This prevents the recipe + stack and recipe + upgrade conflicts.

Together these two checks cover all three pairwise conflicts at startup.

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

## Atomic construction via \_init

Both `ItemState` and `WeaponStatsState` define `_init` with all required fields as
parameters. All properties are populated as part of the `new()` call — there is no
window between allocation and first use where a partially-initialised object exists.

`PlayerInventory._append_slot` is the sole call site for `ItemState.new()` and passes
all fields directly. `is_snapshot` is never a constructor parameter — it is always
`false` at construction and transitions to `true` only via `create_snapshot`.

## The *Data / *State pattern

Classes in this codebase follow a consistent split:

| Class              | Role                                               | Validation                                           |
| ------------------ | -------------------------------------------------- | ---------------------------------------------------- |
| `ItemData`         | Static definition — programmer-authored, immutable | Validated by `ItemValidator` in `_init`, then frozen |
| `WeaponData`       | Static definition — nested inside `ItemData`       | Validated as part of parent `ItemData` validation    |
| `ItemState`        | Session object — mutable per-slot runtime state    | No business rules — only structural integrity guards |
| `WeaponStatsState` | Session object — mutable per-weapon stat state     | No business rules — only structural integrity guards |

`*Data` classes are programmer-authored static definitions — hardcoded in GDScript
source, never populated from external input. They are validated once at startup to
catch programmer errors, then frozen permanently as trusted constants for the rest of
the session.

`*State` classes are runtime instances whose values come from either save data or
programmatic defaults (new game). External data never touches `*Data` — it flows
through the autoload layer, which parses and validates it before constructing any
`*State` object. The autoloads (`PlayerInventory`, `GameState`) are the actual
boundary for external data: they act as a combined service and repository layer,
enforcing all business rules before any `*State` is created or mutated.

`*State` setters do have structural integrity guards — write-once fields, snapshot
guards — but these protect the object's own consistency, not game-world business
rules. By the time any `*State` constructor is called, every constraint has already
been checked by its sole creator.

Putting business validation inside a `*State` class would duplicate the rules already
enforced by the autoloads, creating a second place to keep in sync with no added
safety.

## ItemData field invariants

All constraints are enforced by `ItemValidator` at startup — a violation crashes
immediately, so no invalid `ItemData` can survive into runtime. Bounds are defined
in `ItemSchema`.

| Field            | Constraint                                                                                                                                                                                                |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`             | `MIN_ID_LENGTH`–`MAX_ID_LENGTH` (1–32) chars; lowercase letters, digits, and underscores only; must start with a lowercase letter and end with a letter or digit (snake_case convention — see note below) |
| `ui_name`        | `MIN_UI_NAME_LENGTH`–`MAX_UI_NAME_LENGTH` (1–12) chars; free-form display text                                                                                                                            |
| `description`    | `MIN_DESCRIPTION_LENGTH`–`MAX_DESCRIPTION_LENGTH` (1–50) chars; free-form display text                                                                                                                    |
| `buy_price`      | `MIN_PRICE`–`MAX_PRICE` (0–999999); `0` means not buyable                                                                                                                                                 |
| `sell_price`     | `MIN_PRICE`–`MAX_PRICE` (0–999999); `0` means not sellable; must be strictly less than `buy_price` when `buy_price != 0`                                                                                  |
| `stack_size`     | `MIN_STACK`–`MAX_STACK` (1–99)                                                                                                                                                                            |
| `availability`   | `MIN_CHAPTER`–`MAX_CHAPTER` (1–4) when `buy_price != 0`; otherwise `AVAILABILITY_NOT_FOR_SALE`                                                                                                            |
| `inventory_size` | Each axis `MIN_SIZE_DIM`–`MAX_SIZE_DIM` (1–8)                                                                                                                                                             |
| `weapon_data`    | `null` for all non-`WEAPON` types; non-`null` `WeaponData` for `WEAPON` (enforced bidirectionally)                                                                                                        |
| `upgrade_stat`   | `NONE` for all non-`WEAPON_UPGRADE` types; non-`NONE` `UpgradeStat` for `WEAPON_UPGRADE` (enforced bidirectionally)                                                                                       |

### id naming convention

`id` is a code-level identifier, not display text. It must follow snake_case:
lowercase letters, digits, and underscores only, starting with a lowercase
letter and ending with a letter or digit — no trailing underscore (e.g. `field_medkit`, `smg_ammo`).
This is a **hard constraint enforced by `ItemValidator`** — not just a style preference.

The restriction exists because `RecipeRegistry` builds order-independent lookup
keys by joining two ingredient IDs with a `|` separator. The snake_case
constraint guarantees no ID can ever contain `|`, making key collisions
impossible by construction.

This is distinct from `ui_name` and `description`, which are free-form display
strings and accept any non-empty text.

## ammo_type field ownership

`ammo_type` lives on `WeaponData` (not `ItemData`) — it describes which ammo type a
`WEAPON` consumes, not what an `AMMO`-type item _is_. `ItemValidator` enforces that
`weapon_data` is `null` on all non-`WEAPON` items, so `AMMO`-type items carry no
`ammo_type` at all.

This means the ammo-to-weapon relationship is one-directional: the weapon declares what
it consumes; the ammo item carries no reference back to its compatible weapons. Pairing
is resolved at the point of use (e.g. a weapon fires, looks up its own `ammo_type`, and
finds the matching `AMMO` item in inventory by convention).

## Static data pipeline

```
ItemDefinitions  →  ItemValidator  →  ItemRegistry  →  runtime
```

`ItemDefinitions.get_all()` constructs each `ItemData` and immediately validates it via
`ItemValidator`. Any constraint violation crashes on the first error. `ItemRegistry`
then stores the validated instances and checks for duplicate IDs.
