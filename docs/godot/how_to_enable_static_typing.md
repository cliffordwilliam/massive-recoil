## Recommendation

- **Use typed GDScript syntax everywhere you want static typing**: declare types on variables, constants, parameters, and return values, e.g.  
  - `var health: int = 100`  
  - `func _process(delta: float) -> void:`  
  - `var inventory: Array[Item]`  
- **Enable editor assistance to auto-insert type hints** via `EditorSettings`:  
  - Set `text_editor/completion/add_type_hints = true` to have the editor add `: Type` and `-> Type` in common workflows (autocompletion, new script templates, connecting signals, dragging nodes as `@onready` vars).
- **Strengthen enforcement with GDScript warnings in Project Settings**:  
  - Under `Debug > GDScript` (with Advanced Settings enabled), enable `UNTYPED_DECLARATION` (and optionally `INFERRED_DECLARATION`) so untyped or inferred declarations warn you, nudging the project towards fully static typing.

## Why

- The docs describe static typing as **optional** and enabled by **using type hints in your code** rather than a single global project switch.  
- Enabling `text_editor/completion/add_type_hints` makes the editor automatically produce typed code in many situations, effectively “turning on” static typing in your workflow.  
- GDScript warnings like `UNTYPED_DECLARATION` are specifically recommended when you “always want to use static types”, helping you keep the codebase consistently typed.

## Citation

`tutorials/scripting/gdscript/static_typing.rst`

> “Static types can be used on variables, constants, functions, parameters, and return types.” (lines 15–16)  
> “To define the type of a variable, parameter, or constant, write a colon after the name, followed by its type. E.g. `var health: int`.” (lines 81–83)  
> “If you prefer static typing, we recommend enabling the **Text Editor > Completion > Add Type Hints** editor setting.” (lines 58–62)  
> “You can enable the `UNTYPED_DECLARATION` warning if you want to always use static types. Additionally, you can enable the `INFERRED_DECLARATION` warning if you prefer a more readable and reliable, but more verbose syntax.” (lines 469–475)

`classes/class_editorsettings.rst`

> “If `true`, automatically adds GDScript static typing (such as `-> void` and `: int`) in many situations where it's possible to, including when:  
> – Accepting a suggestion from code autocompletion;  
> – Creating a new script from a template;  
> – Connecting signals from the Signals dock;  
> – Creating variables prefixed with `@onready`, by dropping nodes from the Scene dock into the script editor while holding `Ctrl`.” (lines 5735–5745)