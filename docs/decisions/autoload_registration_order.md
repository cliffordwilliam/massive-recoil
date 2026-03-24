# Autoload Registration Order

## Required order

Register autoloads in **Project Settings → Globals → Autoload** in this exact order:

| #   | Autoload          | Depends on at `_ready` time |
| --- | ----------------- | --------------------------- |
| 1   | `ItemRegistry`    | —                           |
| 2   | `RecipeRegistry`  | `ItemRegistry`              |
| 3   | `GameState`       | —                           |
| 4   | `PlayerInventory` | —                           |
| 5   | `OverlayRouter`   | —                           |

## Why order matters

Godot initializes autoloads top-to-bottom. Any autoload that calls another autoload
inside its own `_ready` requires that dependency to be registered above it.

`RecipeRegistry._ready` calls `ItemRegistry.get_item_or_crash` for every recipe — so
`ItemRegistry` must be fully initialized first. Reversing their order causes a null
access crash at startup.

`GameState` and `PlayerInventory` only call other autoloads at runtime (from `load_save`
and gameplay methods, respectively) — never inside `_ready`. They are not order-sensitive
relative to each other, but are placed after the registry autoloads by convention.

`OverlayRouter._ready` only deactivates its child overlay nodes — it does not call any
other autoload. It is not order-sensitive but is placed last by convention, after all
data and state autoloads are fully initialized.

See `docs/godot/autoload_order_matters.md` for the general Godot note on why registration
order defines initialization order.
