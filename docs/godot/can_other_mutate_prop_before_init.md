## Recommendation

Keep your current pattern, and tighten it with a backing-field split:

- Keep `var _initialized: bool = false` as the backing field.
- Expose a read-only property (no setter) for external code, e.g. `var initialized: bool: get: return _initialized`.
- In `_init(...)`, assign/validate all fields, then do the single freeze transition (`_initialized = true`).
- Continue enforcing immutability in each field setter by checking `_initialized`.

Practical conclusion for your concern: with a required `_init(...)` signature, construction calls `_init` on instantiation; there is no documented workflow where other code mutates that same fresh instance *between* creation and `_init` execution.

## Why

Godot documents that initialization happens as part of instantiation lifecycle, with `_init()` in that sequence, and that property initializers are written directly (bypassing setters). So your `= false` default is safe as raw initialization, and your write-once guard in the setter enforces `false -> true` afterward.

Also, since `set` is otherwise always called, your guard-based setters are the correct place to enforce post-init immutability.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “3. If defined, the `_init()` method is called.”

> “The class constructor, called on class instantiation, is named `_init`.”

> “When a variable is initialized, the value of the initializer will be written directly to the variable.”

> “Unlike `setget` in previous Godot versions, `set` and `get` methods are **always** called (except as noted below)…”
