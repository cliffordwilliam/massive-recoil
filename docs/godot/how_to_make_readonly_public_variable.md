## Recommendation

Yes—your approach is the documented GDScript way to expose a *read-only* “public” value: define a property with a `get` block only, and keep the actual state in a separate internal variable that you update via a method.

So this is correct in spirit:

```gdscript
# Read-only via getter-only property.
var grid_size: Vector2i:
	get:
		return _GRID_SIZES[_grid_tier]

# Update _grid_tier elsewhere (e.g. upgrade_grid()).
var _grid_tier: int = 0
```

If `_GRID_SIZES` and `_grid_tier` fully determine `grid_size`, then callers can read `grid_size` but you control changes through `upgrade_grid()` by changing `_grid_tier`.

## Why

GDScript properties are implemented via special `set`/`get` syntax attached to a variable, and the docs describe that the code block runs when the variable is accessed or assigned. By providing only `get` (and no `set`), you omit the “assign behavior” while still allowing read access computed from internal state.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “GDScript provides a special syntax to define properties using the ``set`` and ``get`` keywords after a variable declaration. Then you can define a code block that will be executed when the variable is accessed or assigned.”  

and the corresponding example:

> “var seconds: int: get: return milliseconds / 1000 set(value): milliseconds = value * 1000”  

(See also the note: “``set`` and ``get`` methods are **always** called … when accessed inside the same class…”)
