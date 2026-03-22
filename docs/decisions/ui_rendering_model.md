# UI Rendering Model

All UI in this project uses a **pull-on-success** pattern. UI never listens to
backend signals to trigger a redraw.

After a mutation a state (or UI handler) calls the relevant refresh method
explicitly — but only after the mutation is confirmed to have succeeded. There are
no inventory or game-state signals wired to overlay or entity UI nodes.

## Why

Keeps cause and effect local to the caller. A state issues a mutation, checks the
result, calls the refresh method if appropriate, then transitions. There is no risk
of a partial redraw triggered mid-sequence by a signal fired between two dependent
mutations (e.g. `remove_item_at` emitting before the follow-up `upgrade_grid` call
in the `INVENTORY_UPGRADE` use path).

## How to apply

- After a confirmed mutation call the overlay's or entity's refresh method directly
  (e.g. `overlay.refresh_slots()`).
- Do not connect inventory or game-state signals to UI redraw methods.
- If a mutation can fail, only call the refresh method on the success branch.
