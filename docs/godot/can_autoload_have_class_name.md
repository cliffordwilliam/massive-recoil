## Recommendation

Do not use the same identifier for both the autoload name and the script’s `class_name`.

For your example:

```gdscript
# item_registry.gd (autoloaded)
# EITHER:
#   Remove class_name and keep the autoload name:
extends Node
# autoload name in Project Settings: "ItemRegistry"

# OR:
#   Keep class_name but give the autoload a different name:
class_name ItemRegistry
extends Node
# autoload name in Project Settings: "ItemRegistrySingleton"
```

In practice, for “pure singleton” autoloads, it’s usually simplest to **omit `class_name`** and just rely on the autoload name for access (e.g. `ItemRegistry.some_method()`).

## Why

The docs state that:

- **Named classes** declared with `class_name` are **“globally registered”** and become available as global identifiers.
- **Autoloads registered as singletons** are also treated as global types you can refer to directly.

Both mechanisms put a symbol into the same global namespace. When your script is:

```gdscript
class_name ItemRegistry
extends Node
```

and you also register that script as an autoload named `ItemRegistry`, Godot ends up with **two different global things called `ItemRegistry`**:

- A global class type `ItemRegistry` (from `class_name`).
- A global autoload singleton `ItemRegistry` (from the Globals/Autoload tab).

The parser error:

> `Class "ItemRegistry" hides an autoload singleton.`

is Godot telling you that the global class name is shadowing the singleton with the same name, which would make references like `ItemRegistry` ambiguous. Renaming one (or dropping `class_name` on the autoload) avoids that collision.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “Valid types are:  
> …  
> **- Script classes declared with the ``class_name`` keyword.**  
> **- Autoloads registered as singletons.**”

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “You can give your class a name to register it as a new type in Godot's editor. For that, you use the ``class_name`` keyword…  
> …  
> **Named classes are globally registered, which means they become available to use in other scripts without the need to ``load`` or ``preload`` them:**”

`tutorials/scripting/singletons_autoload.rst`

> “Here you can add any number of scenes or scripts. **Each entry in the list requires a name, which is assigned as the node's ``name`` property.** …  
> **If the Enable column is checked (which is the default), then the singleton can be accessed directly in GDScript:**  
>  
> ```  
> PlayerVariables.health -= 10  
> ```”
