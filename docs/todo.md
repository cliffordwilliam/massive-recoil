# Project TODO

## Data Layer

### Concrete `ShopItemData` subclasses

* [x] Create **`BuySellItemData`**

  * Overrides both `get_buy_price()` and `get_sell_price()`
  * Used for:

	* Medkit
	* Bandages
	* Antiseptic
	* Treated bandage
	* Weapons

* [x] Create **`SellOnlyItemData`**

  * Overrides only `get_sell_price()`
  * Used for:

	* Ammo

* [x] Create **`BuyOnlyItemData`**

  * Overrides only `get_buy_price()`
  * Used for:

	* Field pack upgrade

---

### ItemRegistry — load static data

* [x] Load `items.json`

  * Instantiate correct subclass depending on which price fields are present
  * Done via `src/editor/generate_item_resources.gd` — run once to generate `.tres` files

* [ ] Load `weapons.json`

  * Instantiate `WeaponData` (`extends ItemData`)
  * Includes upgrade trees

* [ ] Load `treasures.json`

  * Instantiate `TreasureData` (`extends ItemData`)

* [ ] Load `keys.json`

  * Instantiate `KeyData` (`extends ItemData`)

* [ ] Load `recipes.json`

  * Populate `RecipeRegistry`

---

## Runtime State

### Weapon State

* [ ] Create **`WeaponState`** (`extends RefCounted`)

  * Holds reference to `WeaponData`
  * Tracks upgrade levels:

	* `power`
	* `rate_of_fire`
	* `reload_speed`
	* `capacity`

---

### Inventory State

* [ ] Create **`InventoryEntry`** (`extends RefCounted`)

  * Holds:

	* `ShopItemState` or `WeaponState`
	* grid position `(x, y)`

* [ ] Create **`InventoryGrid`** (`extends RefCounted`)

  * Stores a **2D grid**
  * Implement methods:

```
place(entry, x, y)
remove(x, y)
can_place(item, x, y)
move(from, to)
```

---

### Key & Treasure Storage

* [ ] Create **`KeyState`**

  * Holds reference to `KeyData`

* [ ] Create **`TreasureState`**

  * Holds reference to `TreasureData`
  * Includes `count`

* [ ] Create **`KeyRing`**

  * `Array[KeyState]`
  * Methods:

	* `add`
	* `remove`
	* `has`

* [ ] Create **`TreasurePouch`**

  * `Array[TreasureState]`
  * Methods:

	* `add`
	* `remove`

---

## Fix Existing Stubs

* [ ] Fix **UPGRADE render mode** in
  `ui_shop_item_list.gd:145`

  * Pass real **upgrade level**
  * Pass real **upgrade cost**
  * Data should come from `WeaponState`

---

# UI

## Inventory Grid

* [ ] Create **`UIInventoryItem`**

  * Renders a single item tile
  * Size based on `width × height` grid cells

* [ ] Create **`UIInventoryGrid`**

  * Renders `InventoryGrid`
  * Fixed cell size
  * Displays items at their positions

---

### Inventory Interaction

* [ ] Add **cursor / selection highlight**
* [ ] Add **move action**

Interaction flow:

```
select item
move cursor
confirm
reposition item
```

---

# Recipe / Combination System

* [ ] Implement:

```
RecipeRegistry.find_recipe(id_a, id_b)
```

Requirements:

* Order-independent lookup
* Returns recipe or `null`

---

### Combination Tests

* [ ] `sterile_bandage + antiseptic_vial → treated_bandage`
* [ ] `sun_emblem_fragment + moon_emblem_fragment → sun_moon_emblem`
* [ ] `ornate_pendant + ruby_gem → jeweled_pendant`

---

# Test Scene

Create a minimal playable sandbox to validate systems.

---

## Basic Input

* [ ] Keyboard input:

  * `up`
  * `down`
  * `left`
  * `right`
  * `confirm`

---

## Shop UI

* [ ] Add **`UIShopItemList`** in **BUY mode**

  * Populate from `ItemRegistry`
  * Use mock `ShopItemState`
  * Test **paging**

* [ ] Add **SELL mode**

  * Items with `count > 0`

* [ ] Add **UPGRADE mode**

  * Populate from `WeaponState`

* [ ] Add **tab switching**

  * BUY
  * SELL
  * UPGRADE

---

## Inventory Testing

* [ ] Add **`UIInventoryGrid`** next to the shop
* [ ] Test placing items of different sizes

---

## Economy

* [ ] Add **currency counter**

* [ ] Implement **BUY**

  * Deduct currency
  * Add item to inventory grid

* [ ] Implement **SELL**

  * Remove item from grid
  * Add currency

---

## Combination

* [ ] Add **combine action**

Flow:

```
select item A
select item B
query RecipeRegistry
if recipe exists:
	remove ingredients
	add result
```

---

## Key & Treasure Display

* [ ] Add **Key Ring UI**

  * Populate from `KeyState`

* [ ] Add **Treasure Pouch UI**

  * Populate from `TreasureState`

---

# Final Goal

A functional vertical slice including:

* Merchant shop
* Inventory grid
* Weapon upgrades
* Item combination
* Keys & treasures
* Buy / Sell loop
