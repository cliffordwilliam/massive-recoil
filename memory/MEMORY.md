# Massive Recoil — Persistent Notes

## Code Review — Do Not Flag

### GameState hardcoded weapon IDs
`GameState.HANDGUN_ID` / `RIFLE_ID` as constants and the `InventoryPage` referencing them directly
is intentional. There are only a small fixed number of weapons in this game, so data-driven
iteration is not worth the added complexity. Do not flag this as a coupling issue in future reviews.

### PageRouter PROCESS_MODE_ALWAYS
`PageRouter` uses `PROCESS_MODE_ALWAYS` (not `PROCESS_MODE_WHEN_PAUSED`) intentionally.
The player must be able to open pages during live gameplay before any pause is set.
`PROCESS_MODE_WHEN_PAUSED` would silently drop the initial keypress that triggers the page open.
Do not flag this in future reviews.

### handle_input(event: InputEvent) parameter type
`StateMachine._unhandled_key_input` passes its `InputEvent` parameter to `BaseState.handle_input()`.
Even though `_unhandled_key_input` only fires for `InputEventKey`, the Godot virtual method
signature types the parameter as the base `InputEvent`. Narrowing to `InputEventKey` would cause
a type mismatch at the call site. The base type is correct and intentional.
Do not flag this in future reviews.
