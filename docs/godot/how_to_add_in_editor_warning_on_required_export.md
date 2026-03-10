## Recommendation

Use a `@tool` script and override `Node._get_configuration_warnings()` to validate the exported property and return a warning string when it isn’t set.

- **Workflow:**
  - Add `@tool` at the top of your script so it runs in the editor.
  - Declare your export (e.g. `@export var const_script: Script`).
  - Implement `_get_configuration_warnings()` to check if the export is `null`/empty and, if so, return a `PackedStringArray` with a warning message.
  - Optionally call `update_configuration_warnings()` from the export’s setter when its value changes so the editor warning updates immediately.

This will show a warning in the Scene dock similar to the built‑in “no collision shape” warnings.

## Why

Godot’s documentation specifies that `_get_configuration_warnings()` on a `tool` script is exactly how to surface custom configuration problems in the editor: whatever strings you return are rendered as Scene dock warnings, and returning an empty array hides them. The “Godot interfaces” best‑practices tutorial gives a concrete pattern for treating an exported property as “required” by checking it in `_get_configuration_warnings()` and warning when it wasn’t initialized from the editor.

## Citation

`tutorials/best_practices/godot_interfaces.rst`

> “If you need an "export const var" (which doesn't exist), use a conditional setter for a tool script that checks if it's executing in the editor. The `@tool` annotation must be placed at the top of the script.  
> …  
> `@export var const_script: Script:`  
> &nbsp;&nbsp;&nbsp;&nbsp;`set(value):`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`if Engine.is_editor_hint():`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`const_script = value`  
> …  
> `func _get_configuration_warnings():`  
> &nbsp;&nbsp;&nbsp;&nbsp;`if not const_script:`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`return ["Must initialize property 'const_script'."]`  
> &nbsp;&nbsp;&nbsp;&nbsp;`return []`”

`classes/class_node.rst`

> “The elements in the array returned from this method are displayed as warnings in the Scene dock if the script that overrides it is a `tool` script. Returning an empty array produces no warnings. Call `update_configuration_warnings()` when the warnings need to be updated for this node.  
> …  
> `@export var energy = 0:`  
> &nbsp;&nbsp;&nbsp;&nbsp;`set(value):`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`energy = value`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`update_configuration_warnings()`  
>  
> `func _get_configuration_warnings():`  
> &nbsp;&nbsp;&nbsp;&nbsp;`if energy < 0:`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`return ["Energy must be 0 or greater."]`  
> &nbsp;&nbsp;&nbsp;&nbsp;`else:`  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`return []`”