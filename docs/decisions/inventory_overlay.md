# Inventory Overlay

## Rendering model

This overlay follows the project-wide pull-on-success rendering pattern.
See `docs/decisions/ui_rendering_model.md`.

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

The cursor normally highlights a single cell and moves one cell at a time.
The grid renders all placed items beneath the cursor.

### Item snapping

Whenever the cursor overlaps an item it snaps to the item's top-left corner and
expands to cover the item's full footprint. Snapping also runs on entry to the
browse state (including re-entry from Action menu, Move, or Examine) so that a
new item placed under the saved cursor position is correctly reflected.

When the cursor is on an item and the player presses a movement key, the move
originates from the item's top-left corner. If the candidate cell is still
inside the item (possible for multi-cell footprints), the cursor is pushed to
just past the item's far edge in the movement direction, then clamped to the
grid, then snapped to any item that occupies the resulting cell.

This means the cursor never sits on a non-top-left cell of an item — it either
sits at the top-left (snapped) or on an empty cell.

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

| Type                | Effect                                          |
| ------------------- | ----------------------------------------------- |
| `MED`               | Restores health                                 |
| `INVENTORY_UPGRADE` | Permanently expands inventory capacity          |
| `WEAPON`            | Equips the weapon as the player's active weapon |
| All other types     | Button is disabled — item has no use action     |

On confirm for `MED`: call `PlayerInventory.remove_item_at(snapshot.position)` to
consume the item, then apply its healing effect. Returns to **Browse** state.

On confirm for `INVENTORY_UPGRADE`: call `PlayerInventory.can_upgrade_grid()` first.
If `false`, the grid is already at maximum size — show feedback and stay in
**Action menu** state without consuming the item. If `true`, call
`PlayerInventory.remove_item_at(snapshot.position)`, then call
`PlayerInventory.upgrade_grid()`. Returns to **Browse** state.

On confirm for `WEAPON`: equip the weapon without removing it from inventory. Returns
to **Browse** state.

> **TODO:** The Use button is not yet visually disabled for item types with no use
> action (the `_:` branch in `_try_use`). The action menu must be made aware of the
> selected item's type when it is built so it can render the button in a disabled state.
> See `action_menu_state.gd`.
>
> Until the button is visually disabled, pressing Use on an item with no use action
> intentionally stays in **Action menu** state and plays the disabled-button click
> sound. No inventory mutation occurs. This is the correct runtime behaviour even
> before the visual state is implemented.

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

The actual `PlayerInventory` API is `can_add_to_stack(id, position)` — it only checks
whether the slot has _any_ remaining capacity, not whether a specific count fits. Because
the UI must merge all-or-nothing (partial merge would remove the held item and lose the
overflow units), check capacity inline:

```
(target.data.stack_size - target.stack_count) >= held.stack_count
```

If the condition holds, call `PlayerInventory.add_to_stack(held.data.id, target.position,
held.stack_count)` and `PlayerInventory.remove_item_at(held.position)`. Assert the
returned overflow is `0` with `Utils.require` — it should be unreachable given the
preceding check. Returns to **Browse**.

#### Weapon upgrade

Conditions: held item type is `WEAPON_UPGRADE`, target item type is `WEAPON`.

Call `PlayerInventory.can_upgrade_weapon(weapon_pos, upgrade_pos)`. If `true`, call
`PlayerInventory.upgrade_weapon(weapon_pos, upgrade_pos)`. Returns to **Browse**.

If `can_upgrade_weapon` returns `false` (e.g. the stat is already at max), reject the
drop with visual feedback; stay in Move state.

#### Recipe combine

Conditions: held item ID and target item ID match a recipe in `RecipeRegistry`.

Call `PlayerInventory.can_combine_items(held.position, target.position)`. If `true`,
call `PlayerInventory.combine_items(held.position, target.position)`. Returns to
**Browse** state.

`combine_items` internally looks up the recipe via `RecipeRegistry`, removes both
ingredients, and places the result item. Placement always succeeds because the result
item is guaranteed to share the same `inventory_size` as the ingredients by the
drop-action exclusivity constraint (see `item_architecture.md`).

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

Pressing confirm while the footprint is still at the item's origin cell is also
treated as a cancel. This lets the player "put it back" without reaching for the
dedicated cancel key. See `_on_drop` in `move_state.gd`.

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

| UI action                    | Check                                           | Mutation                                  |
| ---------------------------- | ----------------------------------------------- | ----------------------------------------- |
| Use item (MED)               | Item type is `MED`                              | `remove_item_at(pos)`                     |
| Use item (INVENTORY_UPGRADE) | `can_upgrade_grid()`                            | `remove_item_at(pos)` + `upgrade_grid()`  |
| Use item (WEAPON)            | Item type is `WEAPON`                           | _(equip — no inventory mutation yet)_     |
| Discard item                 | —                                               | `remove_item_at(pos)`                     |
| Move to empty space          | `can_move_item(from, to)`                       | `move_item(from, to)`                     |
| Stack merge                  | inline capacity check (see Stack merge section) | `add_to_stack` + `remove_item_at`         |
| Weapon upgrade               | `can_upgrade_weapon(weapon_pos, upgrade_pos)`   | `upgrade_weapon(weapon_pos, upgrade_pos)` |
| Recipe combine               | `can_combine_items(held_pos, target_pos)`       | `combine_items(held_pos, target_pos)`     |
| Read a cell                  | —                                               | `get_slot_at(cell)` → snapshot            |
