## Recommendation

Self-assigning a property's own name inside its setter (or named setter function)
does **not** cause infinite recursion — Godot writes directly to the backing store.

```gdscript
var my_prop: int:
    set(value):
        my_prop = value  # Safe — writes to the backing store directly.

# Named setter variant — same rule applies.
var _current_index: int = -1:
    set = _set_current_index

func _set_current_index(value: int) -> void:
    _current_index = value  # Safe — no infinite recursion.
```

Do **not** call a separate function from inside the setter that then assigns back to
the same property — that creates infinite recursion:

```gdscript
# Wrong — set_my_prop calls itself via the setter, causing infinite recursion.
var my_prop:
    set(value):
        set_my_prop(value)

func set_my_prop(value):
    my_prop = value  # Infinite recursion.
```

## Why

When you assign to the property name inside its own setter or named setter, Godot
detects the self-assignment and accesses the underlying member directly, bypassing the
setter. The exception is local to the setter — it does **not** extend to other functions
called from within the setter.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> "Using the variable's name to set it inside its own setter or to get it inside its own
> getter will directly access the underlying member, so it won't generate infinite
> recursion and saves you from explicitly declaring another variable:"

> "This also applies to the alternative syntax:"

> `func set_my_prop(value): my_prop = value # No infinite recursion.`

> "The exception does **not** propagate to other functions called in the setter/getter.
> For example, the following code **will** cause an infinite recursion:"
> `my_prop = value # Infinite recursion, since set_my_prop() is not the setter.`
