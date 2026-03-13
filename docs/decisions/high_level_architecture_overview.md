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
ShopItemData   (static definition)
       ↓
ShopItemState  (runtime state)
       ↓
UIShopItem     (visual representation)
```

---

# Static Data Layer

## ItemData

`ItemData` is the **root base class for all item definitions**.

Responsibilities:

* Defines immutable item identity
* Provides shared fields used by all items
* Acts as the base type for polymorphism

Example fields:

```
id
display_name
description
```

Key principle:

> ItemData objects represent **templates**, not instances.

These are loaded once and reused.

Example mental model:

```
ItemData = blueprint
```

---

## ShopItemData

`ShopItemData` extends `ItemData` and describes **items that can appear in the merchant shop**.

It defines shared inventory fields and **polymorphic pricing behavior**.

Shared fields:

```
inventory_size   (Vector2i — grid cells occupied; (0,0) means no grid space)
stack_size       (max items per inventory slot)
availability     (earliest chapter the item appears in the shop)
```

Pricing design:

```
Buyable items override get_buy_price()
Sellable items override get_sell_price()
```

Returning `0` indicates the action is not supported.

This keeps the shop system simple because it never needs to know *what type of item it is*.

### Concrete subclasses

Three subclasses cover all item pricing combinations:

| Class | Overrides | Used for |
|---|---|---|
| `BuySellItemData` | both | medkits, bandages, antiseptic, treated bandage |
| `SellOnlyItemData` | `get_sell_price` only | ammo (found in the world, not sold by merchant) |
| `BuyOnlyItemData` | `get_buy_price` only | inventory upgrades (permanent, cannot be sold back) |

Example behavior:

```
Field Medkit        → BuySellItemData   buy=5000  sell=2500
Handgun Ammo        → SellOnlyItemData            sell=50
Field Pack Upgrade  → BuyOnlyItemData   buy=30000
```

---

# Runtime State Layer

Static data cannot track gameplay changes.
For that reason the system introduces **runtime state objects**.

## ShopItemState

`ShopItemState` represents a **player-owned instance of an item**.

It references the static definition but stores mutable data.

Structure:

```
ShopItemState
    data: ShopItemData
    count
    is_new
    sold_out
```

Example runtime instance:

```
data → handgun_ammo
count → 43
is_new → false
sold_out → false
```

Important rule:

> `ShopItemState` never owns static information like name or price.

Instead it references the `ShopItemData`.

This avoids duplication and keeps runtime objects lightweight.

---

# Presentation Layer (UI)

The UI layer renders runtime data but **does not store gameplay state**.

Its job is purely visual.

The flow looks like this:

```
ShopItemState
    ↓
UIShopItemList
    ↓
UIShopItem
```

---

## UIShopItemList

This class is responsible for:

* Displaying a **paged list**
* Managing **selection**
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
UPGRADE
```

Each mode uses a different UI configuration:

```
BUY      → show price
SELL     → show count + sell price
UPGRADE  → show upgrade level + cost
```

This is handled through:

```
UIShopItem.setup_buy()
UIShopItem.setup_sell()
UIShopItem.setup_upgrade()
```

---

## UIShopItem

This class represents a **single visual entry** in the shop list.

Responsibilities:

* Render item name
* Render price
* Render quantity or level
* Show status tags (NEW / SOLD OUT)

Important design choice:

UI elements are reused and simply **configured differently depending on context**.

Example:

```
BUY PAGE

Handgun Ammo       200
SMG Ammo           150
Field Medkit      5000
```

```
SELL PAGE

Handgun Ammo   X43     50
Sterile Bandage X2     300
```

```
UPGRADE PAGE

Power        Lv2   4000
Reload Speed Lv1   3000
```

---

# Content Data Model

JSON files are the **source of truth** for all static game content.

They live in `src/resources/data/` and are never loaded at runtime directly.
Instead, an editor script converts them into typed `.tres` resource files:

```
src/resources/data/items.json
    ↓  (run generate_item_resources.gd once)
src/resources/data/generated/items/*.tres
```

At runtime, `ItemRegistry` loads the generated `.tres` files — not the JSON.

Current JSON files:

```
items.json
keys.json
treasures.json
weapons.json
recipes.json
```

Each file defines **static gameplay content**.

Examples:

Items

* medkits
* bandages
* ammo
* upgrades

Keys

* puzzle keys
* key fragments

Treasures

* sellable valuables
* combinable items

Weapons

* weapon definitions
* upgrade tracks

Recipes

* combination rules

---

# Combination System

The merge system is **recipe-driven**.

Instead of items knowing how to combine, the logic is centralized.

Example recipe:

```
sterile_bandage + antiseptic_vial
→ treated_bandage
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

---

# Weapon Data

Weapons are defined separately because they contain complex upgrade trees.

Example structure:

```
weapon
  ammo_type
  size
  buy_price
  sell_price
  availability
  upgrades
```

Upgrade tracks:

```
power
rate_of_fire
reload_speed
ammo_capacity
```

Each track contains levels:

```
level
value
cost
```

Runtime state for weapons will eventually store:

```
current_power_level
current_rof_level
current_reload_level
current_capacity_level
```

---

# Inventory Design Rules

Your system uses these principles:

Items and weapons have inventory size:

```
width
height
```

Keys and treasures do not occupy grid space.

This mirrors the **RE4 attaché case model**.

Example:

```
Inventory Grid
  weapons
  ammo
  healing items

Key Ring
  keys

Treasure Pouch
  treasures
```

For MVP they may all live in one container, but the schema supports separation.

---

# Why This Architecture Works

This design is effective because it enforces separation of responsibilities.

### Static Data

Defines content.

```
ItemData
WeaponData
TreasureData
KeyData
```

### Runtime State

Tracks player progress.

```
ShopItemState
WeaponState
InventoryEntry
```

### UI

Displays state.

```
UIShopItem
UIShopItemList
```

---

# Strengths of the Current System

Your current setup already has several strong engineering practices:

* Data-driven content
* Clear separation of static vs runtime state
* Reusable UI components
* Paging UI instead of spawning nodes
* Recipe-based combination system
* Polymorphic shop pricing

These are patterns used in many production game systems.

---

# Potential Future Extensions (not required for MVP)

Some systems you may add later:

Weapon runtime state class

```
WeaponState
```

Inventory container

```
InventoryGrid
```

Key inventory

```
KeyRing
```

Treasure container

```
TreasureInventory
```

Recipe registry

```
RecipeRegistry
```

Item registry

```
ItemRegistry
```

---

# Final Assessment

Your architecture is **very solid for an early-stage project**.

You have:

* clear separation of concerns
* scalable data model
* UI that reuses components
* extensible combination system
* weapon upgrade trees

This is exactly the kind of structure that can grow **without needing major rewrites later**.