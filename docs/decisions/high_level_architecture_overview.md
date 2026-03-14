# High-Level Architecture Overview

The project follows a **data-driven architecture** with three main layers:

1. **Static Data Layer** – immutable definitions loaded from resources or JSON
2. **Runtime State Layer** – mutable objects representing the player's session
3. **Presentation Layer** – UI that renders runtime state

This separation prevents gameplay logic, UI, and content definitions from becoming entangled.

Conceptually:

```
Static Data (Resource)
        ↓
Runtime State (session objects)
        ↓
UI Rendering
```

Or using a real example:

```
ItemData      (static definition)
       ↓
ItemRegistry  (loads blueprints; owns all ItemState at runtime)
       ↓
UIShopItemList / UIShopItem  (visual representation)
```

---

# Static Data Layer

## ItemData

`ItemData` is the **single resource class for all item definitions**.

All item types — meds, ammo, weapons, upgrades, treasures, and keys — share this one
class. Behavioural differences are expressed through the `type` field and the presence
or absence of prices and flags. There is no subclass hierarchy.

Fields:

```
id               unique identifier used for lookups
display_name     text shown in UI
description      flavour text
type             determines gameplay behaviour (see enum below)
buy_price        cost to purchase; 0 = not buyable
sell_price       value when sold; 0 = not sellable
availability     earliest chapter the item appears in the shop
inventory_size   grid cells occupied (width × height)
stack_size       max quantity per slot; 1 = not stackable
ammo_type        ammo the weapon consumes (weapons only; see AmmoType enum)
```

Key principle:

> `ItemData` objects represent **templates**, not instances.

These are loaded once and reused.

### Type enum

Item behaviour is driven by the `Type` enum rather than a class hierarchy.

| Type                | Buyable | Sellable | Stackable | Notes                                            |
|---------------------|---------|----------|-----------|--------------------------------------------------|
| `MED`               | YES     | YES      | NO        | Healing consumable                               |
| `COMBINABLE_MED`    | NO      | YES      | YES       | Healing ingredient; combinable via recipe lookup |
| `AMMO`              | NO      | YES      | YES       | Stackable ammunition                             |
| `INVENTORY_UPGRADE` | YES     | NO       | NO        | Permanent capacity expansion                     |
| `WEAPON`            | YES     | YES      | NO        | Unique weapon                                    |
| `WEAPON_UPGRADE`    | YES     | NO       | NO        | Consumable that upgrades a weapon stat when used |
| `TREASURE`          | NO      | YES      | NO        | Valuable sellable item; some combinable via recipe lookup |
| `KEY`               | NO      | NO       | NO        | Progression item; some combinable via recipe lookup |

Buyability and sellability are determined by whether `buy_price` / `sell_price` is non-zero,
not by the type alone — this keeps the shop system simple.

Example behavior:

```
field_medkit           type=MED               buy=5000  sell=2500
handgun_ammo           type=AMMO                        sell=50
sterile_band           type=COMBINABLE_MED              sell=300
pack_upgrade           type=INVENTORY_UPGRADE buy=30000
ornate_pendant         type=TREASURE                    sell=4000
ruby_gem               type=TREASURE                    sell=2500
maintenance_key        type=KEY
sun_emblem_fragment    type=KEY
```

---

# Runtime State Layer

Static data cannot track gameplay changes.
For that reason the system introduces **runtime state objects**.

## ItemRegistry

`ItemRegistry` is the **autoload singleton that bridges static data and runtime state**.

At startup it scans the generated `.tres` directory, loads every `ItemData` resource,
and creates one `ItemState` per item. All states live in a single flat dictionary:

```
_item_states: Dictionary[StringName, ItemState]
```

This means `ItemRegistry` is both the loader and the runtime state store. There is
no separate step — loading a blueprint immediately produces the state object that
the rest of the game reads and writes.

Key methods:

```
get_buyable_shop_states()   filtered, sorted list for the buy page
get_item_state(id)          direct lookup by id
load_save(save_data)        hydrates count / is_new from a save file
```

---

## ItemState

`ItemState` represents the **runtime state of an item** for the current session.

It references the static definition but stores mutable data.

Structure:

```
ItemState
    data: ItemData
    count
    is_new
```

Example runtime instance:

```
data → handgun_ammo
count → 43
is_new → false
```

Important rule:

> `ItemState` never owns static information like name or price.

Instead it references the `ItemData` blueprint.

This avoids duplication and keeps runtime objects lightweight.

---

# Presentation Layer (UI)

The UI layer renders runtime data but **does not store gameplay state**.

Its job is purely visual.

The flow looks like this:

```
ItemRegistry
    ↓  (get_buyable_shop_states / get_item_state)
UIShopItemList
    ↓
UIShopItem
```

---

## UIShopItemList

This class is responsible for:

* Displaying a **paged list**
* Managing **selection** — a `Cursor` sprite is repositioned over the active slot each time the index changes
* Navigating with `next()` and `previous()`, which advance `_current_index` and trigger a page refresh
* Updating the visible entries

Key design choice:

The list uses **fixed UI entries** instead of dynamically spawning nodes.

```
_PAGE_SIZE = 5
```

This approach is extremely common in games because it avoids:

* constant node allocation
* UI garbage
* layout instability

Instead, the system **reuses existing UI elements**.

A scrollbar thumb is drawn via `_draw()` when the total item count exceeds one page.
It is hidden when everything fits on a single page.

Conceptually:

```
Visible UI Slots = 5

Data List = N

Page renders subset of list
```

---

## Render Modes

The same list UI can render multiple shop pages.

```
BUY
SELL
```

Each mode uses a different UI configuration:

```
BUY   → show price + NEW tag
SELL  → show count + sell price
```

This is handled through:

```
UIShopItem.setup_buy()
UIShopItem.setup_sell()
```

---

## UIShopItem

This class represents a **single visual entry** in the shop list.

Responsibilities:

* Render item name
* Render price
* Render quantity (sell page only)
* Show NEW tag (buy page only)

Important design choice:

UI elements are reused and simply **configured differently depending on context**.

Example:

```
BUY PAGE

Field Kit         5000
Treat Band        1800
Pack Upgrade     30000
```

```
SELL PAGE

HG Ammo        X43     50
Sterile Band    X2     300
```

---

# Content Data Model

JSON files are the **source of truth** for all static game content.

They live in `src/resources/data/`.

Current JSON files:

```
items.json      — all item definitions (meds, ammo, weapons, upgrades, treasures, keys)
recipes.json    — item combination rules
```

Each file defines **static gameplay content**. All item types are unified in `items.json`
and distinguished by the `type` field; there are no separate files per category.

## items.json pipeline

`items.json` is **never loaded at runtime directly**.
Instead, an editor script converts it into typed `.tres` resource files:

```
src/resources/data/items.json
    ↓  (run generate_item_resources.gd after any change to items.json)
src/resources/data/generated/items/*.tres
```

At runtime, `ItemRegistry` loads the generated `.tres` files — not the JSON.

### Item schema (items.json)

Each entry in the `items` array must have this shape and pass validation (enforced by
`generate_item_resources.gd` when generating `.tres` files):

**Required keys and types:**

| Key            | Type   | Constraints                                                                                                 |
|----------------|--------|-------------------------------------------------------------------------------------------------------------|
| `id`           | string | Non-empty, unique across all items                                                                          |
| `name`         | string | Non-empty, max 12 characters                                                                                |
| `description`  | string | Non-empty, max 50 characters                                                                                |
| `type`         | string | One of: `med`, `combinable_med`, `ammo`, `inventory_upgrade`, `weapon`, `weapon_upgrade`, `treasure`, `key` |
| `ammo_type`    | string | One of: `""`, `"handgun_ammo"`, `"smg_ammo"` (empty or omitted = no ammo)                                   |
| `buy_price`    | int    | 0–999999                                                                                                    |
| `sell_price`   | int    | 0–999999                                                                                                    |
| `stack_size`   | int    | 1–999                                                                                                       |
| `availability` | int    | 1–4 (earliest chapter)                                                                                      |
| `size`         | object | Required; must have `width` and `height` (each int 1–6)                                                     |

All numeric fields are required and must be integers within the ranges above.

Example valid item:

```json
{
  "ammo_type": "",
  "availability": 1,
  "buy_price": 0,
  "description": "Two fragments joined together to form a complete emblem.",
  "id": "sun_moon_emblem",
  "name": "Sun/Moon Embl",
  "sell_price": 0,
  "size": { "width": 1, "height": 1 },
  "stack_size": 1,
  "type": "key"
}
```

Invalid or malformed entries are reported in the editor output and skipped; no `.tres` file is generated for them.

## recipes.json

`recipes.json` does not have a `.tres` generation pipeline.
How it is consumed at runtime will be defined when the Combination System is implemented.

---

# Combination System

The merge system is **recipe-driven**.

Instead of items knowing how to combine, the logic is centralized.

Example recipe:

```
sterile_band + antiseptic
→ treat_band
```

Key recipe:

```
sun_emblem_fragment + moon_emblem_fragment
→ sun_moon_emblem
```

Treasure upgrade:

```
ornate_pendant + ruby_gem
→ jeweled_pendant
```

Runtime behavior:

```
player attempts combine
↓
recipe lookup
↓
if match found
    remove ingredients
    add result
```

This keeps item definitions **simple and decoupled**.
