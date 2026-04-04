
## Grouping exports in the Inspector

Use these GDScript annotations (documented in `tutorials/scripting/gdscript/gdscript_exports.rst` and `classes/class_@gdscript.rst`):

### `@export_group("Name")`

Puts **every following exported property** into that group until the next group or category. End the current group with **`@export_group("")`** (tutorial) or **`@export_group("", "")`** (class ref).

Optional **second argument `prefix`**: only properties whose names **start with that prefix** are grouped; others stay outside the group.

```gdscript
@export_group("My Properties")
@export var number = 3
```

### `@export_subgroup("Name")`

Adds a **subgroup inside the current group**. Groups are **not** nested; subgroups are the way to nest visually. Requires an existing parent group.

```gdscript
@export_subgroup("Extra Properties")
@export var string = ""
```

### `@export_category("Name")`

Creates or renames **top-level Inspector categories** (separate from the normal inheritance-based sections). The docs warn that categories **break the usual inheritance ordering**—prefer **`@export_group` / `@export_subgroup`** for clarity unless you really want categories.

Class ref note on **`@export_category`**: *“For better clarity, it's recommended to use `@export_group` and `@export_subgroup`, instead.”*

## Citation

`tutorials/scripting/gdscript/gdscript_exports.rst`

> “It is possible to group your exported properties inside the Inspector with the `@export_group` annotation. Every exported property after this annotation will be added to the group. Start a new group or use `@export_group("")` to break out.”  
> “The second argument of the annotation can be used to only group properties with the specified prefix.”  
> “Groups cannot be nested, use `@export_subgroup` to create subgroups within a group.”
