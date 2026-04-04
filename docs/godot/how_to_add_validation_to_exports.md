
Here is an answer grounded only in this repo’s docs.

## Recommendation

Use **export annotations** (and, if needed, **`@export_custom`**) so the Inspector gets the right **property hints**. That mainly shapes **how values are edited**, not a separate “export-time validator” in GDScript.

- **Numeric min/max/step (and related UI hints)**  
  Use **`@export_range(min, max, step, ...)`**, which corresponds to **`PROPERTY_HINT_RANGE`** and a hint string of the form `"min,max"` or `"min,max,step"` with optional extra keywords (`"or_greater"`, `"or_less"`, `"exp"`, `"suffix:…"`, `"degrees"`, `"radians_as_degrees"`, `"prefer_slider"`, `"hide_control"`, etc.—see the class reference for the full list).

- **Fixed set of choices**  
  Use **`@export_enum(...)`** (backed by **`PROPERTY_HINT_ENUM`**). For strings this restricts the Inspector to the listed names; **`PROPERTY_HINT_ENUM_SUGGESTION`** (via **`@export_custom`**) only *suggests* values and still allows arbitrary strings.

- **Strings**  
  The docs in this repo describe **`@export_multiline`**, **`@export_placeholder(...)`**, path exports (`@export_file`, `@export_dir`, …), etc. They do **not** document a built-in “max string length” export variant in the same way as **`@export_range`**.

- **Anything not covered by the built-in `@export_*` helpers**  
  Use **`@export_custom(hint, hint_string, usage)`** with values from **`PropertyHint`** (`enum PropertyHint` on **`@GlobalScope`**) and the matching hint string format. Be aware: **GDScript does not validate** that syntax; bad hints can behave oddly in the Inspector.

For **hard rules** (e.g. your `ItemValidator` / immutability pattern), the documentation treats that as normal script logic (setters, validation types, etc.), not as something `@export` enforces by itself.

## Why

The exports tutorial describes **`@export_range`** as the way to **limit editor input ranges** for integers and floats (with optional hints so limits apply to the slider vs typed input). The **`@GDScript`** reference states explicitly that **`@export_custom`** passes hints through to the editor and performs **no validation in GDScript**. So “validation on export” in practice means **Inspector hints and editing behavior**, plus whatever **you** enforce in code when values are set or loaded.

## Citation

`tutorials/scripting/gdscript/gdscript_exports.rst`

> “Limiting editor input ranges  
> …  
> See `@export_range` for all of the following.  
> …  
> `@export_range(0, 20) var i`  
> …  
> The limits can be made to affect only the slider if you add the hints `"or_less"` and/or `"or_greater"`. If either these hints are used, it will be possible for the user to enter any value or drag the value with the mouse when not using the slider, even if outside the specified range.”

`tutorials/scripting/gdscript/gdscript_exports.rst`

> “When using `@export_custom`, GDScript does not perform any validation on the syntax. Invalid syntax may have unexpected behavior in the inspector.”

`classes/class_@gdscript.rst` (`@export_custom`)

> “Allows you to set a custom hint, hint string, and usage flags for the exported property. Note that there's no validation done in GDScript, it will just pass the parameters to the editor.”

`classes/class_@globalscope.rst` (`PROPERTY_HINT_RANGE`)

> “Hints that an `int` or `float` property should be within a range specified via the hint string `"min,max"` or `"min,max,step"`. The hint string can optionally include `"or_greater"` and/or `"or_less"` to allow manual input going respectively above the max or below the min values.”