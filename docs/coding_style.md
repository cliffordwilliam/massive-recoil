# Coding Style

This document is the authoritative reference for how code is written in this project.
Follow it when adding new features or reviewing existing ones.

## Philosophy

Write GDScript as GDScript. The language is dynamically typed with optional static
annotations — use the annotations everywhere but favour the golden path: assume internal callers are
correct, keep functions short, and reach for complexity only when the problem demands it.

Lean code is easier to read and maintain than defensive code. Do not add guards,
comments, or validation for scenarios that cannot happen. Trust internal code and
framework guarantees. No need to overthink, keep it simple and straight forward.

## Tooling

Format and lint every file before committing:

```bash
gdformat file.gd
gdlint file.gd
```

`gdformat` is the canonical formatter. Never hand-format a file differently from what
`gdformat` would produce — if the output looks odd, the formatter wins.

## File and folder naming

| Thing | Convention | Example |
|---|---|---|
| GDScript files | `snake_case.gd` | `item_validator.gd` |
| Scene files | `snake_case.tscn` | `ui_shop_item.tscn` |
| Folders | `snake_case/` | `ui_shop_item_list/` |
| Scene + script pairs | Same folder, same base name | `buy_overlay/buy_overlay.gd` |

Scene and script files that belong to the same node live in the same folder and share
the same base name.

## Source layout

```
src/
  autoload/      → global singletons registered in Project Settings
  custom_nodes/  → reusable Node subclasses (state machine infrastructure, etc.)
  editor/        → editor utility scripts (run once, never shipped)
  entities/      → scene objects
  overlays/      → UI overlays shown above the current scene
  resources/     → static data definitions
  state/         → runtime gameplay state
  utils.gd       → shared helper functions
```

**Layer rules:**
- `state/` objects are plain data holders.
- `resources/` classes define structure.
- `entities/` and `overlays/` read from autoloads. Pass live state to UI and trust it not to mutate.
- `autoload/` singletons own mutable shared state across the session.
- `custom_nodes/` classes are pure node infrastructure.

## Naming

| Thing | Convention | Example |
|---|---|---|
| Class names | `PascalCase` | `ItemValidator`, `UIShopItem` |
| Variables and functions | `snake_case` | `stack_count`, `find_open_position` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_NAME_LENGTH`, `_PAGE_SIZE` |
| Private members | `_snake_case` (leading underscore) | `_slots`, `_parse_slot_entry` |
| Enums | `PascalCase` name, `SCREAMING_SNAKE_CASE` values | `Type.WEAPON`, `AmmoType.HANDGUN_AMMO` |
| Signals | `snake_case`, past or present tense verb phrase | `inventory_changed`, `selection_changed` |
| `StringName` literals | `snake_case` | `&"handgun_ammo"`, `&""` |

Public members come before private members within each member category. See
[Member ordering](#member-ordering).

`StringName` is used for item IDs and other engine-facing keys compared or looked up
frequently. Use plain `String` for all user-visible text, log messages, and general
string data. See `docs/godot/how_to_use_string_name.md`.

## Member ordering

Within a script, declare members in this order:

1. Signals
2. Enums
3. Constants (`const`)
4. Exported variables (`@export`)
5. Public variables
6. Private variables
7. `@onready` variables
8. `_init` / `_ready` / other lifecycle overrides
9. Public functions
10. Private functions (`_` prefix)

Within each category, public members appear before private ones. See `docs/godot/how_to_document_gdscript.md` for complete script example.

## Documentation

Use `##` (double-hash) for doc comments. Use `#` (single hash) for inline
implementation comments. Never mix them for the same thing.

```gdscript
## Brief succinct one-line summary of what this does.
##
## Extended explanation only when needed. Reference related types with
## [ClassName] or [member ClassName.property] for IDE cross-links.
##
## See: "res://docs/decisions/some_decision.md"
func my_function() -> void:
	# This is an inline comment explaining a non-obvious step.
	pass
```

**What requires a `##` doc comment:**
- Every `class_name` (placed immediately after `extends`)
- Every public variable, constant, signal, and function only when the meaning is not obvious
- Every enum and its values when the meaning is not obvious
- Private members whose behaviour or purpose is not obvious

**What does not need a `##` doc comment:**
- `@onready` vars that are simple node references obvious from their name and type
- Anything whose name and signature make their purpose self-evident
- Anything already explained by the surrounding public API doc

**Cross-references:** When a design decision explains why something works a certain way,
add `## See: "res://docs/decisions/the_relevant_doc.md"` to the class or function doc.

See `docs/godot/how_to_document_gdscript.md` for the full doc comment syntax.

## Static typing

Type everything: variables, constants, function parameters, and return values.
Never leave a declaration untyped or use bare `Variant` unless the type genuinely
varies at runtime (e.g. JSON parsing).

```gdscript
# Correct
var grid_size: Vector2i = Vector2i(7, 11)
func get_item(id: StringName) -> ItemData:

# Wrong — untyped
var grid_size = Vector2i(7, 11)
func get_item(id):
```

For typed arrays, use `Array[T]` and convert untyped sources with `assign()` rather
than a bare cast:

```gdscript
# Correct — assign() enforces the typed array contract
var result: Array[ItemData] = []
result.assign(_items.values())

# Wrong — a bare return of values() may silently produce an untyped array
return _items.values()
```

See `docs/godot/how_to_enable_static_typing.md`.

## Error handling

Trust internal code. Do not add precondition guards on internal functions — if a caller
passes a bad value, the bug will surface during development and get fixed there. No need to overthing on edge cases, just focus on golden path.

Use `assert` only for **editor misconfiguration**: nodes or exports that must be wired
up in the Inspector and would produce a cryptic downstream error if left unset.

```gdscript
func _ready() -> void:
	assert(initial_state is BaseState, "initial_state not set in Inspector")
```

For expected failure paths, return a sentinel value — never assert:

```gdscript
# Placement that doesn't fit → return false
# Stack that is full → return the overflow count
```

## Setters and properties

Use inline `set(value):` blocks for property logic. Use the named `set = func` syntax
only when two or more properties share the exact same setter function.

Self-assigning the property name inside its own setter or named setter does **not** cause
infinite recursion — Godot writes directly to the backing store.

```gdscript
var chapter: int = DEFAULT_CHAPTER:
    set(value):
        assert(_is_valid_chapter(value))
        chapter = value  # Safe — writes to backing store directly.
```

For named setters, the same rule applies. See:
`docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md`

Do **not** call a separate function that then assigns back to the same property — that
creates infinite recursion:

```gdscript
# Wrong
var my_prop: int:
    set(value):
        _apply_my_prop(value)  # Infinite recursion if _apply_my_prop assigns my_prop.
```

## Signals

Emit a signal only when state actually changed. Do not emit defensively or
unconditionally on every call:

```gdscript
# Correct — only emits if something was added
if added > 0:
    inventory_changed.emit()

# Wrong — emits even when nothing changed
inventory_changed.emit()
```

## Autoloads

Autoloads cannot use `class_name`.

Register autoloads in the correct order — see
`docs/decisions/autoload_registration_order.md`.

No autoload other than `PlayerInventory` may create or store `ItemState` instances.
No autoload other than `OverlayRouter` may set `BaseOverlay.is_active`.

## Integer division and ceiling division

GDScript truncates toward zero when both operands are `int`. This is correct for page
index calculations (`_current_index / _PAGE_SIZE`). Annotate intentional integer
division with `@warning_ignore("integer_division")` so it is not confused with a bug.

For ceiling division (e.g. total pages), cast to `float` before dividing so `ceili`
receives a fractional value:

```gdscript
# Correct — float cast prevents truncation before ceili
var total_pages: int = ceili(float(items_size) / _PAGE_SIZE)

# Wrong — integer division truncates before ceili can apply ceiling rounding
var total_pages: int = ceili(items_size / _PAGE_SIZE)
```

See `docs/godot/how_to_do_int_division.md`.

## Unreachable return statements

GDScript's type checker sometimes requires a `return` after a branch that is
provably exhaustive. No need to add a comment marking it unreachable, trust the caller:

```gdscript
func _get_render_mode_name() -> String:
	match render_mode:
		RenderMode.BUY:
			return "buy"
		RenderMode.SELL:
			return "sell"
```
