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

| Member          | Purpose                                                                                  |
| --------------- | ---------------------------------------------------------------------------------------- |
| `is_active`     | Written by `OverlayRouter` only. Drives `visible` and `process_mode`.                    |
| `_hydrate_ui()` | Abstract. Called each time the overlay becomes active. Subclasses refresh their UI here. |

`_hydrate_ui` is called on every open — not once at startup — so each overlay always
reflects the current game state (chapter, inventory contents, etc.) at the moment it
appears.

## Opening and closing

`OverlayRouter.open_X_overlay()` only opens an overlay when none is currently open.
If an overlay is already active, additional open requests are ignored until the
current overlay is closed (there is no switching or queuing).

On open: `get_tree().paused = true` halts all nodes not running
`PROCESS_MODE_ALWAYS`. On close: the tree is unpaused.

## Input handling

`OverlayRouter` uses `PROCESS_MODE_ALWAYS` so it receives input regardless of pause
state. `_unhandled_key_input` handles two global actions:

- `pause` — closes the current overlay from anywhere (cancel behavior).
- Opening overlays via key (`inventory` / `buy`) — only checked when no overlay is open.

Overlay-specific inputs (scrolling a list, confirming a purchase) are handled inside
each overlay's own scene.

For example, `BuyOverlay` uses the `accept` action to buy the selected shop item.

## Overlays

| Overlay   | Class              | Status   | Opens via                                    |
| --------- | ------------------ | -------- | -------------------------------------------- |
| Shop buy  | `BuyOverlay`       | Active   | `buy` key (handled by `OverlayRouter`)       |
| Inventory | `InventoryOverlay` | Scaffold | `inventory` key (handled by `OverlayRouter`) |

## Why OverlayRouter is an autoload

Any game system can trigger an overlay (a chest opens the shop, a button opens
inventory). Making `OverlayRouter` an autoload means any node can call
`OverlayRouter.open_buy_overlay()` without needing a scene reference. There is
exactly one router for the lifetime of the session, which matches the single-overlay
constraint.
