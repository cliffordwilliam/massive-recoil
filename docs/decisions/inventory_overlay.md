# Inventory Overlay

## Input model

All input is keyboard-only. The player never uses a mouse or touch to interact with
the inventory grid. Movement keys (up/down/left/right) move a cursor one cell at a
time. What the cursor represents depends on the current state.

## UI States

The inventory overlay has four states. Only one is active at a time.

| State       | Description                                                              |
| ----------- | ------------------------------------------------------------------------ |
| Browse      | Default. Grid is rendered; player selects an item to act on it.          |
| Action menu | An item is selected; a contextual menu shows the four available actions. |
| Move        | An item is being repositioned; player chooses a destination.             |
| Examine     | A detail modal is shown for a selected item; only Close is valid.        |

## Browse state

The cursor is a single highlighted cell. Movement keys move it one cell at a time.
The grid renders all placed items beneath the cursor.

Pressing confirm on an occupied cell transitions to **Action menu** state for that
item. Pressing confirm on an empty cell does nothing.

Call `PlayerInventory.get_slot_at(cell)` to determine whether a cell is occupied.
The snapshot returned by `get_slot_at` is the UI's read handle for that item —
pass `snapshot.position` to all subsequent inventory calls.

## Action menu state

When an item is selected the menu shows four actions. Each action below specifies
whether it transitions out of this state and to which state.

### Use

Context-sensitive. Enabled only for item types with a gameplay effect:

| Type               | Effect                                                          |
| ------------------ | --------------------------------------------------------------- |
| `MED`              | Restores health                                                 |
| `INVENTORY_UPGRADE`| Permanently expands inventory capacity                          |
| `WEAPON`           | Equips the weapon as the player's active weapon                 |
| All other types    | Button is disabled — item has no use action                     |

On confirm for consumable types (`MED`, `INVENTORY_UPGRADE`): call
`PlayerInventory.remove_item_at(snapshot.position)` to consume the item, then apply
its effect. Returns to **Browse** state.

On confirm for `WEAPON`: equip the weapon without removing it from inventory. Returns
to **Browse** state.

### Move

Transitions to **Move** state with the selected item as the active item.
The item remains in `PlayerInventory._slots` — it is not removed until the move
resolves. This preserves the item's `ItemState` (including weapon stats) throughout.

### Examine

Transitions to **Examine** state.

### Discard

Permanently removes the item. Call `PlayerInventory.remove_item_at(snapshot.position)`.
Returns to **Browse** state.

## Move state

The cursor becomes the selected item's footprint — it moves as a rectangle matching
the item's current size rather than a single cell. Movement keys shift the footprint
one cell at a time.

### Rotation

The player can rotate the item while in Move state. Rotation swaps the width and
height of the item's footprint (e.g. a 3×2 item becomes 2×3).

> **TODO:** rotation requires a new `is_rotated` flag on `ItemState` so the
> inventory knows which size to use when placing and checking collisions. The
> effective size becomes `Vector2i(data.inventory_size.y, data.inventory_size.x)`
> when `is_rotated` is `true`. `can_move_item` and `move_item` will need to accept
> or read this flag. This is not yet implemented.

Pressing confirm drops the item at the current footprint position. Two outcomes are
possible depending on what occupies the destination.

### Drop onto empty space

Call `PlayerInventory.can_move_item(from_pos, to_pos)`.

- `true` → call `PlayerInventory.move_item(from_pos, to_pos)`. Returns to **Browse**.
- `false` → destination is out of bounds or blocked. Reject the drop; stay in Move state.

`move_item` updates `slot.position` in place on the existing `ItemState` — weapon
stats and stack count are preserved.

### Drop onto an occupied cell

Resolve the outcome against the three possibilities in order. Because the
drop-action exclusivity constraint is enforced at startup (see `item_architecture.md`),
at most one outcome applies — there is never ambiguity.

#### Stack merge

Conditions: held item and target item share the same `ItemData.id`, and
`stack_size > ItemSchema.MIN_STACK`.

Call `PlayerInventory.can_add_to_stack(target_pos, amount)`. If `true`, call
`PlayerInventory.add_to_stack(target_pos, amount)` and
`PlayerInventory.remove_item_at(held_pos)`. Returns to **Browse**.

#### Weapon upgrade

Conditions: held item type is `WEAPON_UPGRADE`, target item type is `WEAPON`.

Call `PlayerInventory.can_upgrade_weapon(weapon_pos, upgrade_pos)`. If `true`, call
`PlayerInventory.upgrade_weapon(weapon_pos, upgrade_pos)`. Returns to **Browse**.

If `can_upgrade_weapon` returns `false` (e.g. the stat is already at max), reject the
drop with visual feedback; stay in Move state.

#### Recipe combine

Conditions: held item ID and target item ID match a recipe in `RecipeRegistry`.

Check `RecipeRegistry.has_recipe(held_id, target_id)`. If `true`:
1. Note the result ID via `RecipeRegistry.get_result(held_id, target_id)`.
2. Find a valid placement position for the result item.
3. Call `PlayerInventory.remove_item_at` on both ingredients.
4. Call `PlayerInventory.place_item` with the result `ItemData`.

Returns to **Browse** state.

#### No outcome matches

The drop destination is occupied but none of the above outcomes apply. Reject the
drop with visual feedback; stay in Move state.

> **TODO — swap mechanic:** When none of the above outcomes apply and the held item's
> footprint overlaps exactly one other item, the player should be able to drop the
> held item and pick up the one it overlaps with. This requires a new `is_held` flag
> on `ItemState`. The flag tells `PlayerInventory` to skip that item in collision
> checks (generalising the existing "skip the item being moved" logic in
> `can_move_item`). At most one item has `is_held == true` at any time — enforced by
> `PlayerInventory`. The flag must not be written to save data; on load all items
> start with `is_held == false`.

### Cancel move

Player presses cancel — the item stays at its original position. Returns to
**Browse** state. No inventory calls are needed; `ItemState` was never modified.

## Examine state

A floating modal shows the item's full detail:

- Name and description (from `ItemData.ui_name` and `ItemData.description`)
- Weapon stats — power, rate of fire, reload speed, ammo capacity — and their
  min/max range (from `snapshot.weapon_stats_state` and `snapshot.data.weapon_data`);
  only rendered for `WEAPON` type items

The only valid action is **Close**, which returns to **Browse** state. The action
menu is not shown in this state.

> Note: the modal rendering is not yet implemented. For now, print the description
> to the console as a placeholder.

## Backend API summary

| UI action                  | Check                                              | Mutation                                    |
| -------------------------- | -------------------------------------------------- | ------------------------------------------- |
| Use item                   | Item type is `MED` or `INVENTORY_UPGRADE`          | `remove_item_at(pos)`                       |
| Discard item               | —                                                  | `remove_item_at(pos)`                       |
| Move to empty space        | `can_move_item(from, to)`                          | `move_item(from, to)`                       |
| Stack merge                | `can_add_to_stack(target_pos, amount)`             | `add_to_stack` + `remove_item_at`           |
| Weapon upgrade             | `can_upgrade_weapon(weapon_pos, upgrade_pos)`      | `upgrade_weapon(weapon_pos, upgrade_pos)`   |
| Recipe combine             | `RecipeRegistry.has_recipe(id_a, id_b)`            | `remove_item_at` × 2 + `place_item`         |
| Read a cell                | —                                                  | `get_slot_at(cell)` → snapshot              |
