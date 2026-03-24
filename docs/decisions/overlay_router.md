# Overlay Router

## Decision

A single `OverlayRouter` autoload manages all full-screen overlays for the duration of
the game session. It is always present in the scene tree as a `CanvasLayer` above the
game world, and it displays at most one overlay at a time.

## Structure

```
OverlayRouter (CanvasLayer, autoload)
  ├── BuyOverlay    (Node2D, BaseOverlay)
  └── InventoryOverlay  (Node2D, BaseOverlay)
```

All overlays are permanent children of `OverlayRouter` — they are never instantiated or
freed at runtime. Activation is a visibility and process-mode toggle, not a
scene-tree change.

## BaseOverlay contract

Every overlay extends `BaseOverlay`, which enforces a single lifecycle interface:

| Member          | Purpose                                                                                                     |
| --------------- | ----------------------------------------------------------------------------------------------------------- |
| `is_active`     | Written by `OverlayRouter` only. Drives `visible` and `process_mode`.                                       |
| `_hydrate_ui()` | Abstract. Called each time the overlay becomes active. Subclasses refresh their UI here.                    |
| `_on_close()`   | Abstract. Called each time the overlay transitions from active to inactive. Subclasses clean up state here. |

`_hydrate_ui` is called on every open — not once at startup — so each overlay always
reflects the current game state (chapter, inventory contents, etc.) at the moment it
appears.

`_on_close` is called on every close, but **only when the overlay was previously
active** — not during initial setup. This is the right place to reset a state machine
or clear selection state before the next open.

`OverlayRouter` never calls either method directly. It sets `is_active`, and
`BaseOverlay`'s setter dispatches to `_hydrate_ui()` or `_on_close()` accordingly.

## Opening and closing

`OverlayRouter.open_X_overlay()` only opens an overlay when none is currently open.
If an overlay is already active, additional open requests are ignored until the
current overlay is closed (there is no switching or queuing).

This is intentional — the overlay system is **first-come-first-serve with no page
navigation**. There is no back-stack, no switching between overlays, and no
programmatic close triggered by overlay logic. The player always closes the
current overlay with a single key (`cancel`). Keeping close player-driven means
any overlay can be dismissed at any time without each overlay needing to know
when it is "done".

On open: `get_tree().paused = true` halts all nodes not running
`PROCESS_MODE_ALWAYS`. On close: the tree is unpaused.

## Input handling

`OverlayRouter` uses `PROCESS_MODE_ALWAYS` so it receives input regardless of pause
state. `_unhandled_key_input` handles two global actions:

- `cancel` — closes the current overlay from anywhere.
- Opening overlays via key (`inventory` / `buy`) — only checked when no overlay is open.

Overlay-specific inputs (scrolling a list, confirming a purchase) are handled inside
each overlay's own scene.

For example, `BuyOverlay` uses the `accept` action to buy the selected shop item.

## Overlays

| Overlay   | Class              | Status   | Opens via                                    |
| --------- | ------------------ | -------- | -------------------------------------------- |
| Shop buy  | `BuyOverlay`       | Active   | `buy` key (handled by `OverlayRouter`)       |
| Inventory | `InventoryOverlay` | Scaffold | `inventory` key (handled by `OverlayRouter`) |

### InventoryOverlay: drag-and-drop with no preview

The inventory overlay uses a pick-up-and-place interaction model. The player
selects an item to hold, moves the cursor freely, and attempts to drop it at any
grid position. There is no ghost or placement preview — the player drops blind
and receives feedback only after the attempt (success moves the item; failure
leaves it held).

This means `PlayerInventory._find_open_position_excluding` (which finds the
first open position while treating held slots as removed) does not need to be
exposed as a public API. No system needs to pre-calculate a valid drop position
on the player's behalf.

## Why OverlayRouter is an autoload

Any game system can trigger an overlay (a chest opens the shop, a button opens
inventory). Making `OverlayRouter` an autoload means any node can call
`OverlayRouter.open_buy_overlay()` without needing a scene reference. There is
exactly one router for the lifetime of the session, which matches the single-overlay
constraint.
